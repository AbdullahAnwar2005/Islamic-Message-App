// providers/sync_provider.dart
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/app_database.dart';
import 'database_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(appDatabaseProvider); // H-3: was ref.read
  final supabase = Supabase.instance.client;
  return SyncService(db: db, supabase: supabase);
});

/// True while a startup sync is actively running (post-runApp).
/// HomeScreen uses this to distinguish: (a) loading, (b) offline/failed, (c) data.
final syncInFlightProvider = StateProvider<bool>((ref) => false);

/// Tracks the outcome of the last background sync
enum SyncStatus { initial, success, failed }

final syncStatusProvider = StateProvider<SyncStatus>(
  (ref) => SyncStatus.initial,
);

class SyncService {
  final AppDatabase db;
  final SupabaseClient supabase;
  SyncService({required this.db, required this.supabase});

  Future<void> run({bool initial = false}) async {
    // 1) Fetch
    final secs = await supabase
        .from('sections')
        .select()
        .order('sort_order', ascending: true);
    final msgs = await supabase.from('messages').select();
    final trs = await supabase.from('translations').select();

    if (kDebugMode) {
      debugPrint(
        '[sync] fetched sections=${secs.length}, messages=${msgs.length}, translations=${trs.length}',
      );
    }

    // 2) Insert with companions
    await db.transaction(() async {
      if (initial) {
        // Full replace strategy
        await db.customStatement('DELETE FROM translations;');
        await db.customStatement('DELETE FROM messages;');
        await db.customStatement('DELETE FROM sections;');
      }

      // ---------------- SECTIONS ----------------
      for (final s in secs) {
        try {
          final id = (s['id'] as num?)?.toInt();
          final title = s['title'] as String?;
          final slug = s['slug'] as String?;

          if (id == null || title == null || slug == null) {
            if (kDebugMode) debugPrint('[sync] Skipping invalid section: $s');
            continue;
          }

          await db
              .into(db.sections)
              .insertOnConflictUpdate(
                SectionsCompanion(
                  id: Value(id),
                  title: Value(title),
                  slug: Value(slug),
                  sortOrder: Value((s['sort_order'] as num?)?.toInt() ?? 0),
                ),
              );
        } catch (e) {
          if (kDebugMode) debugPrint('[sync] Error importing section $s: $e');
        }
      }

      // ---------------- MESSAGES ----------------
      for (final m in msgs) {
        try {
          final id = (m['id'] as num?)?.toInt();
          final slug = m['slug'] as String?;
          final title = m['title'] as String?;
          final titleAr = m['title_ar'] as String?;
          final titleEn = m['title_en'] as String?;

          if (id == null || slug == null || title == null) {
            if (kDebugMode) debugPrint('[sync] Skipping invalid message: $m');
            continue;
          }

          await db
              .into(db.messages)
              .insertOnConflictUpdate(
                MessagesCompanion(
                  id: Value(id),
                  slug: Value(slug),
                  title: Value(title),
                  titleAr: Value(titleAr),
                  titleEn: Value(titleEn),
                  isPublished: Value((m['is_published'] as bool?) ?? true),
                  sectionId: Value((m['section_id'] as num?)?.toInt()),
                  createdAt: Value(
                    _safeParseDateTime(m['created_at']) ?? DateTime.now(),
                  ),
                  updatedAt: Value(
                    _safeParseDateTime(m['updated_at']) ?? DateTime.now(),
                  ),
                ),
              );
        } catch (e) {
          if (kDebugMode) debugPrint('[sync] Error importing message $m: $e');
        }
      }

      // ---------------- TRANSLATIONS ----------------
      for (final t in trs) {
        try {
          final msgId = (t['message_id'] as num?)?.toInt();
          final lang = t['language_code'] as String?;

          if (msgId == null || lang == null) {
            if (kDebugMode)
              debugPrint('[sync] Skipping invalid translation: $t');
            continue;
          }

          await db
              .into(db.translations)
              .insertOnConflictUpdate(
                TranslationsCompanion(
                  messageId: Value(msgId),
                  languageCode: Value(lang),
                  title: Value((t['title'] as String?) ?? ''),
                  content: Value((t['content'] as String?) ?? ''),
                  audioUrl: Value(t['audio_url'] as String?),
                  createdAt: Value(
                    _safeParseDateTime(t['created_at']) ?? DateTime.now(),
                  ),
                  updatedAt: Value(
                    _safeParseDateTime(t['updated_at']) ?? DateTime.now(),
                  ),
                ),
              );
        } catch (e) {
          if (kDebugMode)
            debugPrint('[sync] Error importing translation $t: $e');
        }
      }
    });

    if (kDebugMode) {
      final mc =
          await db.customSelect('SELECT COUNT(*) c FROM messages').getSingle();
      final tc =
          await db
              .customSelect('SELECT COUNT(*) c FROM translations')
              .getSingle();
      debugPrint(
        '[sync] after insert → messages=${mc.data["c"]}, translations=${tc.data["c"]}',
      );
    }
  }

  DateTime? _safeParseDateTime(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getSupportedLanguages() async {
    try {
      // Query distinct language_codes from translations table
      final response = await supabase
          .from('translations')
          .select('language_code');

      final rows = List<Map<String, dynamic>>.from(response);
      final codes =
          rows.map((r) => r['language_code'] as String).toSet().toList();

      // If empty, fallback to basic
      if (codes.isEmpty) return ['ar', 'en'];

      return codes;
    } catch (e) {
      if (kDebugMode)
        debugPrint('[sync] Error fetching supported languages: $e');
      return ['ar', 'en'];
    }
  }
}
