import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/reader_tables.dart';

part 'reader_daos.g.dart'; // <-- must match the file name (daOs)

//
// ────────────────────────────
//   READING SETTINGS DAO
// ────────────────────────────
//
@DriftAccessor(tables: [ReadingSettingsTable])
class ReadingSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingSettingsDaoMixin {
  ReadingSettingsDao(super.db);

  Future<int> _ensureRow() async {
    final row =
        await (select(readingSettingsTable)..limit(1)).getSingleOrNull();
    if (row != null) return row.id;
    return into(
      readingSettingsTable,
    ).insert(ReadingSettingsTableCompanion.insert());
  }

  Future<ReadingSettingsTableData> getSettings() async {
    final row =
        await (select(readingSettingsTable)..limit(1)).getSingleOrNull();
    if (row != null) return row;
    final id = await _ensureRow();
    return (select(readingSettingsTable)
      ..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateSettings({
    String? theme,
    String? pageStyle,
    double? fontSize,
    double? lineHeight,
    String? fontFamily,
  }) async {
    final row = await getSettings();
    await (update(readingSettingsTable)
      ..where((t) => t.id.equals(row.id))).write(
      ReadingSettingsTableCompanion(
        theme: theme != null ? Value(theme) : const Value.absent(),
        pageStyle: pageStyle != null ? Value(pageStyle) : const Value.absent(),
        fontSize: fontSize != null ? Value(fontSize) : const Value.absent(),
        lineHeight:
            lineHeight != null ? Value(lineHeight) : const Value.absent(),
        fontFamily:
            fontFamily != null ? Value(fontFamily) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

//
// ────────────────────────────
//   READING PROGRESS DAO
// ────────────────────────────
//
@DriftAccessor(tables: [ReadingProgressTable])
class ReadingProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingProgressDaoMixin {
  ReadingProgressDao(super.db);

  Future<void> upsert(
    String messageId,
    String textLanguageCode, {
    required double percent,
    double? scrollOffset,
    int? pageIndex,
  }) async {
    final existing =
        await (select(readingProgressTable)..where(
          (t) =>
              t.messageId.equals(messageId) &
              t.textLanguageCode.equals(textLanguageCode),
        )).getSingleOrNull();

    if (existing == null) {
      await into(readingProgressTable).insert(
        ReadingProgressTableCompanion.insert(
          messageId: messageId,
          textLanguageCode: Value(textLanguageCode),
          percent: Value(percent),
          scrollOffset: Value(scrollOffset ?? 0),
          pageIndex: Value(pageIndex ?? 0),
        ),
      );
    } else {
      await (update(readingProgressTable)
        ..where((t) => t.id.equals(existing.id))).write(
        ReadingProgressTableCompanion(
          percent: Value(percent),
          scrollOffset:
              scrollOffset != null ? Value(scrollOffset) : const Value.absent(),
          pageIndex:
              pageIndex != null ? Value(pageIndex) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<ReadingProgressTableData?> getByMessage(
    String messageId,
    String textLanguageCode,
  ) {
    return (select(readingProgressTable)..where(
      (t) =>
          t.messageId.equals(messageId) &
          t.textLanguageCode.equals(textLanguageCode),
    )).getSingleOrNull();
  }

  Future<void> reset(String messageId, [String? textLanguageCode]) async {
    if (textLanguageCode != null) {
      // Reset specific language
      await (delete(readingProgressTable)..where(
        (t) =>
            t.messageId.equals(messageId) &
            t.textLanguageCode.equals(textLanguageCode),
      )).go();
    } else {
      // Reset all languages for this message
      await (delete(readingProgressTable)
        ..where((t) => t.messageId.equals(messageId))).go();
    }
  }
}

//
// ────────────────────────────
//   AUDIO PROGRESS DAO
// ────────────────────────────
//
@DriftAccessor(tables: [AudioProgressTable])
class AudioProgressDao extends DatabaseAccessor<AppDatabase>
    with _$AudioProgressDaoMixin {
  AudioProgressDao(super.db);

  Future<void> upsert(
    String messageId,
    String audioLanguageCode, {
    required int lastAudioPositionMs,
    double playbackRate = 1.0,
  }) async {
    final existing =
        await (select(audioProgressTable)..where(
          (t) =>
              t.messageId.equals(messageId) &
              t.audioLanguageCode.equals(audioLanguageCode),
        )).getSingleOrNull();

    if (existing == null) {
      await into(audioProgressTable).insert(
        AudioProgressTableCompanion.insert(
          messageId: messageId,
          audioLanguageCode: audioLanguageCode,
          lastAudioPositionMs: Value(lastAudioPositionMs),
          playbackRate: Value(playbackRate),
        ),
      );
    } else {
      await (update(audioProgressTable)
        ..where((t) => t.id.equals(existing.id))).write(
        AudioProgressTableCompanion(
          lastAudioPositionMs: Value(lastAudioPositionMs),
          playbackRate: Value(playbackRate),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<AudioProgressTableData?> getByMessage(
    String messageId,
    String audioLanguageCode,
  ) {
    return (select(audioProgressTable)..where(
      (t) =>
          t.messageId.equals(messageId) &
          t.audioLanguageCode.equals(audioLanguageCode),
    )).getSingleOrNull();
  }

  Future<void> reset(String messageId, [String? audioLanguageCode]) async {
    if (audioLanguageCode != null) {
      // Reset specific language
      await (delete(audioProgressTable)..where(
        (t) =>
            t.messageId.equals(messageId) &
            t.audioLanguageCode.equals(audioLanguageCode),
      )).go();
    } else {
      // Reset all languages for this message
      await (delete(audioProgressTable)
        ..where((t) => t.messageId.equals(messageId))).go();
    }
  }
}

//
// ────────────────────────────
//   BOOKMARKS DAO
// ────────────────────────────
//
@DriftAccessor(tables: [BookmarksTable])
class BookmarksDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarksDaoMixin {
  BookmarksDao(super.db);

  Stream<List<BookmarksTableData>> watchByMessage(String messageId) =>
      (select(bookmarksTable)
            ..where((t) => t.messageId.equals(messageId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<void> add(String messageId, String paragraphKey) async {
    await into(bookmarksTable).insertOnConflictUpdate(
      BookmarksTableCompanion.insert(
        messageId: messageId,
        paragraphKey: paragraphKey,
      ),
    );
  }

  Future<void> remove(int id) =>
      (delete(bookmarksTable)..where((t) => t.id.equals(id))).go();
}

//
// ────────────────────────────
//   HIGHLIGHTS DAO
// ────────────────────────────
//
@DriftAccessor(tables: [HighlightsTable])
class HighlightsDao extends DatabaseAccessor<AppDatabase>
    with _$HighlightsDaoMixin {
  HighlightsDao(super.db);

  Stream<List<HighlightsTableData>> watchByMessage(String messageId) =>
      (select(highlightsTable)
        ..where((t) => t.messageId.equals(messageId))).watch();

  Future<int> add({
    required String messageId,
    required String startParagraphKey,
    required String endParagraphKey,
    required int startCharOffset,
    required int endCharOffset,
    String color = 'yellow',
  }) {
    return into(highlightsTable).insert(
      HighlightsTableCompanion.insert(
        messageId: messageId,
        startParagraphKey: startParagraphKey,
        endParagraphKey: endParagraphKey,
        startCharOffset: startCharOffset,
        endCharOffset: endCharOffset,
        color: Value(color),
      ),
    );
  }

  Future<void> remove(int id) =>
      (delete(highlightsTable)..where((t) => t.id.equals(id))).go();
}

//
// ────────────────────────────
//   AUDIO DAO
// ────────────────────────────
//
@DriftAccessor(tables: [AudioSessionsTable, AudioCuesTable])
class AudioDao extends DatabaseAccessor<AppDatabase> with _$AudioDaoMixin {
  AudioDao(super.db);

  Future<void> upsertSession(
    String messageId, {
    required int lastPositionMs,
    double rate = 1.0,
  }) async {
    final row =
        await (select(audioSessionsTable)
          ..where((t) => t.messageId.equals(messageId))).getSingleOrNull();

    if (row == null) {
      await into(audioSessionsTable).insert(
        AudioSessionsTableCompanion.insert(
          messageId: messageId,
          lastPositionMs: Value(lastPositionMs),
          playbackRate: Value(rate),
        ),
      );
    } else {
      await (update(audioSessionsTable)
        ..where((t) => t.id.equals(row.id))).write(
        AudioSessionsTableCompanion(
          lastPositionMs: Value(lastPositionMs),
          playbackRate: Value(rate),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<List<AudioCuesTableData>> cuesFor(String messageId) =>
      (select(audioCuesTable)
            ..where((t) => t.messageId.equals(messageId))
            ..orderBy([(t) => OrderingTerm.asc(t.startMs)]))
          .get();
}
