// lib/data/repositories/sync_repository.dart
//
// H-4 FIX: Replace full in-memory http.get with streaming download
//           to avoid loading entire MP3 into RAM.
// H-5 FIX: All lastSync I/O goes through Drift SyncState table only.
//           SharedPreferences as sync timestamp store is removed.
// M-4 FIX: Removed per-translation HEAD requests. Uses updated_at
//           comparison instead to decide whether to re-download.
// L-1 FIX: All debug output guarded behind kDebugMode.

import 'dart:io';

import 'package:drift/drift.dart' show Value, BooleanExpressionOperators;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/app_database.dart';

class SyncRepository {
  final AppDatabase db;
  SyncRepository(this.db);

  final supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // H-5: Read lastSync from Drift only.
  // ---------------------------------------------------------------------------
  Future<DateTime?> _getLastSync() => db.readLastSync();
  Future<void> _setLastSync(DateTime dt) => db.writeLastSync(dt.toUtc());

  // ---------------------------------------------------------------------------
  // Main sync entry point.
  // ---------------------------------------------------------------------------
  Future<void> syncMessages({bool full = false}) async {
    final lastSync = full ? null : await _getLastSync();
    final since = lastSync?.toUtc().toIso8601String();

    final messagesRows =
        since == null
            ? await supabase.from('messages').select()
            : await supabase.from('messages').select().gt('updated_at', since);

    final translationsRows =
        since == null
            ? await supabase.from('translations').select()
            : await supabase
                .from('translations')
                .select()
                .gt('updated_at', since);

    // ---------------- messages ----------------
    for (final raw in List<Map<String, dynamic>>.from(messagesRows)) {
      final id = (raw['id'] as num).toInt();
      final title = (raw['title'] ?? '').toString();
      final titleAr = raw['title_ar'] as String?;
      final titleEn = raw['title_en'] as String?;
      final isPublished =
          raw['is_published'] is bool ? raw['is_published'] as bool : true;

      final now = DateTime.now();
      final createdAt = _safeParseDateTime(raw['created_at']) ?? now;
      final updatedAt = _safeParseDateTime(raw['updated_at']) ?? now;

      final existing =
          await (db.select(db.messages)
            ..where((t) => t.id.equals(id))).getSingleOrNull();

      final slug = _slugify(title);

      if (existing == null) {
        await db
            .into(db.messages)
            .insert(
              MessagesCompanion.insert(
                id: Value(id),
                slug: slug,
                title: title,
                titleAr: Value(titleAr),
                titleEn: Value(titleEn),
                isPublished: Value(isPublished),
                createdAt: Value(createdAt),
                updatedAt: Value(updatedAt),
              ),
            );
      } else {
        final needsUpdate =
            existing.title != title ||
            existing.titleAr != titleAr ||
            existing.titleEn != titleEn ||
            existing.slug != slug ||
            existing.isPublished != isPublished;

        if (needsUpdate) {
          await (db.update(db.messages)..where((t) => t.id.equals(id))).write(
            MessagesCompanion(
              slug: Value(slug),
              title: Value(title),
              titleAr: Value(titleAr),
              titleEn: Value(titleEn),
              isPublished: Value(isPublished),
              updatedAt: Value(updatedAt),
            ),
          );
        }
      }
    }

    // ---------------- translations ----------------
    for (final raw in List<Map<String, dynamic>>.from(translationsRows)) {
      final messageId = (raw['message_id'] as num).toInt();
      final lang = (raw['language_code'] ?? '').toString();
      final title = (raw['title'] ?? '').toString();
      final content = (raw['content'] ?? '').toString();
      final audioUrl = raw['audio_url'] as String?;

      final now = DateTime.now();
      final createdAt = _safeParseDateTime(raw['created_at']) ?? now;
      final updatedAt = _safeParseDateTime(raw['updated_at']) ?? now;

      final existing =
          await (db.select(db.translations)..where(
            (x) => x.messageId.equals(messageId) & x.languageCode.equals(lang),
          )).getSingleOrNull();

      final existingPath = existing?.audioPath ?? '';
      String localPath = existingPath;
      final hasRemote = audioUrl != null && audioUrl.isNotEmpty;

      if (!hasRemote) {
        // Audio deleted on server — remove local file
        if (localPath.isNotEmpty) {
          try {
            final f = File(localPath);
            if (await f.exists()) await f.delete();
          } catch (_) {}
        }
        localPath = '';
      } else {
        // M-4 FIX: Compare updated_at instead of sending a HEAD request per file.
        bool shouldRedownload = false;

        if (existing == null) {
          shouldRedownload = true;
        } else if (existingPath.isEmpty || !await File(existingPath).exists()) {
          shouldRedownload = true;
        } else if (existing.audioUrl != audioUrl) {
          // URL changed → re-download
          shouldRedownload = true;
        } else if (updatedAt.isAfter(existing.updatedAt)) {
          // Server side updated_at is newer → re-download
          shouldRedownload = true;
        }

        if (shouldRedownload) {
          localPath = await _downloadAudioFile(audioUrl, messageId, lang);
        }
      }

      if (existing == null) {
        await db
            .into(db.translations)
            .insert(
              TranslationsCompanion.insert(
                messageId: messageId,
                languageCode: lang,
                title: Value(title),
                content: content,
                audioUrl: Value(audioUrl),
                audioPath: Value(localPath),
                createdAt: Value(createdAt),
                updatedAt: Value(updatedAt),
              ),
            );
      } else {
        final needsUpdate =
            existing.content != content ||
            existing.title != title ||
            existing.audioUrl != audioUrl ||
            existing.audioPath != localPath;

        if (needsUpdate) {
          await (db.update(db.translations)..where(
            (x) => x.messageId.equals(messageId) & x.languageCode.equals(lang),
          )).write(
            TranslationsCompanion(
              content: Value(content),
              title: Value(title),
              audioUrl: Value(audioUrl), // null clears DB field
              audioPath: Value(localPath),
              updatedAt: Value(updatedAt),
            ),
          );
        }
      }
    }

    // H-5: write to Drift only
    await _setLastSync(DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // H-4 FIX: Streaming download — no full file in RAM.
  // ---------------------------------------------------------------------------
  Future<String> _downloadAudioFile(
    String? url,
    int messageId,
    String lang,
  ) async {
    try {
      if (url == null || url.isEmpty) return '';

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/audio_${messageId}_$lang.mp3';
      final partPath = '$path.part';

      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);
      if (response.statusCode != 200) return '';

      final sink = File(partPath).openWrite();
      await response.stream.pipe(sink);
      await sink.close();

      // Atomic swap
      final finalFile = File(path);
      if (await finalFile.exists()) await finalFile.delete();
      await File(partPath).rename(path);

      return path;
    } catch (e) {
      if (kDebugMode)
        debugPrint('[SyncRepo] Audio download error [$messageId/$lang]: $e');
      // Clean up partial file
      try {
        final dir = await getApplicationDocumentsDirectory();
        final partFile = File('${dir.path}/audio_${messageId}_$lang.mp3.part');
        if (await partFile.exists()) await partFile.delete();
      } catch (_) {}
      return '';
    }
  }

  DateTime? _safeParseDateTime(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  String _slugify(String input) => input
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s-]+', unicode: true), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp('-+'), '-');

  Future<List<String>> getSupportedLanguages() async {
    try {
      final response = await supabase
          .from('translations')
          .select('language_code');
      final rows = List<Map<String, dynamic>>.from(response);
      final codes =
          rows.map((r) => r['language_code'] as String).toSet().toList();
      return codes;
    } catch (e) {
      if (kDebugMode)
        debugPrint('[SyncRepo] Error fetching supported languages: $e');
      return ['ar', 'en'];
    }
  }
}
