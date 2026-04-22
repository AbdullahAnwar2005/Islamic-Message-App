import 'dart:io';

import 'package:alghaya_men_alkhalg/data/local/tables/message_table.dart';
import 'package:alghaya_men_alkhalg/data/local/tables/section_table.dart';
import 'package:alghaya_men_alkhalg/data/local/tables/reader_tables.dart';
import 'package:alghaya_men_alkhalg/data/local/tables/translations_table.dart';
import 'package:alghaya_men_alkhalg/data/local/tables/outbox_tables.dart';
import 'package:alghaya_men_alkhalg/analytics/data/analytics_queue_table.dart';
import 'package:alghaya_men_alkhalg/analytics/data/analytics_queue_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../providers/database_provider.dart';
import 'daos/message_dao.dart';
import 'daos/reader_daos.dart';

part 'app_database.g.dart';

/// Stores small sync metadata (UTC).
class SyncState extends Table {
  TextColumn get key => text()(); // e.g., 'last_sync_at'
  DateTimeColumn get value => dateTime()(); // store in UTC
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Messages,
    Translations,
    Sections,
    SyncState,
    ReadingSettingsTable,
    ReadingProgressTable,
    AudioProgressTable,
    BookmarksTable,
    HighlightsTable,
    AudioSessionsTable,
    AudioCuesTable,
    ContactOutbox,
    ContentReportsOutbox,
    AnalyticsEventQueue,
  ],
  daos: [
    MessageDao,
    ReadingSettingsDao,
    ReadingProgressDao,
    AudioProgressDao,
    BookmarksDao,
    HighlightsDao,
    AudioDao,
    AnalyticsQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Use this constructor in production code.
  /// It opens the DB in a background isolate to avoid UI jank.
  AppDatabase.background() : super(_open()) {
    // Debug-only construction log (won't run in release).
    assert(() {
      // ignore: avoid_print
      // print('AppDatabase constructed (background)\n${StackTrace.current}');
      return true;
    }());
  }

  /// Optional: convenient in-memory DB for tests.
  AppDatabase.inMemory() : super(NativeDatabase.memory()) {
    assert(() {
      // ignore: avoid_print
      // print('AppDatabase constructed (inMemory)\n${StackTrace.current}');
      return true;
    }());
  }

  // If you still want direct access:
  @override
  MessageDao get messageDao => MessageDao(this);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.createTable(readingSettingsTable);
        await m.createTable(readingProgressTable);
        await m.createTable(bookmarksTable);
        await m.createTable(highlightsTable);
        await m.createTable(audioSessionsTable);
        await m.createTable(audioCuesTable);
      }
      if (from < 4) {
        await m.createTable(sections);
        await m.addColumn(messages, messages.sectionId);
      }
      if (from < 5) {
        await m.addColumn(translations, translations.title);
      }
      if (from < 6) {
        await m.addColumn(messages, messages.titleAr);
        await m.addColumn(messages, messages.titleEn);
      }
      if (from < 7) {
        await m.createTable(contactOutbox);
        await m.createTable(contentReportsOutbox);
      }
      if (from < 8) {
        await m.createTable(analyticsEventQueue);
      }
      if (from < 9) {
        // Add textLanguageCode column to ReadingProgressTable with default 'ar'
        await m.addColumn(
          readingProgressTable,
          readingProgressTable.textLanguageCode,
        );
        // Create new AudioProgressTable
        await m.createTable(audioProgressTable);
      }
    },
  );

  /// Convenience: wipe all content (keeps tables)
  Future<void> deleteAllData() async {
    await transaction(() async {
      await batch((b) {
        b.deleteWhere(translations, (_) => const Constant(true));
        b.deleteWhere(messages, (_) => const Constant(true));
        b.deleteWhere(syncState, (_) => const Constant(true));
      });
    });
  }

  // =======================
  // Sync helpers (tiny DAO)
  // =======================

  Future<DateTime?> readLastSync() async {
    final row =
        await (select(syncState)
          ..where((t) => t.key.equals('last_sync_at'))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeLastSync(DateTime tsUtc) async {
    await into(syncState).insertOnConflictUpdate(
      SyncStateCompanion.insert(key: 'last_sync_at', value: tsUtc.toUtc()),
    );
  }

  Future<void> upsertMessage(MessagesCompanion data) async {
    await into(messages).insertOnConflictUpdate(data);
  }

  Future<void> upsertTranslation(TranslationsCompanion data) async {
    await into(translations).insertOnConflictUpdate(data);
  }
}

extension MessageTitleClean on Message {
  String get displayTitle => title.replaceAll(RegExp(r'^#+\s*'), '');
  String? get displayTitleAr => titleAr?.replaceAll(RegExp(r'^#+\s*'), '');
  String? get displayTitleEn => titleEn?.replaceAll(RegExp(r'^#+\s*'), '');
}

extension TranslationTitleClean on Translation {
  String get displayTitle => title.replaceAll(RegExp(r'^#+\s*'), '');
}

class MessageWithTranslations {
  final Message message;
  final List<Translation> translations;
  const MessageWithTranslations({
    required this.message,
    required this.translations,
  });
}

Future<bool> isDbEmpty(ProviderContainer container) async {
  final db = container.read(appDatabaseProvider);
  // Count messages (adapt to your DAO if you have one)
  final msgCount =
      await db.customSelect('SELECT COUNT(*) AS c FROM messages').getSingle();
  final trCount =
      await db
          .customSelect('SELECT COUNT(*) AS c FROM translations')
          .getSingle();

  final m = (msgCount.data['c'] as int?) ?? 0;
  final t = (trCount.data['c'] as int?) ?? 0;

  if (kDebugMode) {
    // print('[startup] DB counts → messages=$m, translations=$t');
  }
  return m == 0 || t == 0;
}

/// Open a persistent database in app documents dir.
LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'alghaya.db'));
    // Runs queries on a background isolate to avoid blocking the UI thread.
    return NativeDatabase.createInBackground(file);
  });
}
