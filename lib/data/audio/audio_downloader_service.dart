// lib/data/audio/audio_downloader_service.dart
import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../local/app_database.dart';

class DownloadedFile {
  final int messageId;
  final String title;
  final String languageCode;
  final String path;
  final int sizeBytes;

  DownloadedFile({
    required this.messageId,
    required this.title,
    required this.languageCode,
    required this.path,
    required this.sizeBytes,
  });
}

/// Handles downloading, caching, and removing audio files.
/// - Saves files under: <AppDocuments>/audio/<messageId>_<lang>.<ext>
/// - Updates Drift: `translations.audioPath`
/// - Enforces Wi-Fi only per task via `requiresWiFi: true`
class AudioDownloadService {
  final AppDatabase db;

  // background_downloader v9.x
  final FileDownloader _downloader = FileDownloader();

  // Optional: simple progress stream keyed by taskId
  final _progress = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get progressStream => _progress.stream;

  AudioDownloadService(this.db) {
    // No global configure needed on v9.2.3 – per-task flags are enough.

    // Register callbacks once for this instance
    _downloader.registerCallbacks(
      taskStatusCallback: (TaskStatusUpdate update) async {
        final status = update.status;
        final task = update.task;

        // Bubble up status
        _progress.add({
          'type': 'status',
          'taskId': task.taskId,
          'status': status.name,
        });

        if (status == TaskStatus.complete) {
          // Recover our metadata to know which row to update
          final (messageId, lang, ext) = _decodeMeta(task.metaData);

          final filePath = await _targetPath(messageId, lang, ext);

          await db.upsertTranslation(
            TranslationsCompanion(
              messageId: Value(messageId),
              languageCode: Value(lang),
              audioPath: Value(filePath),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
        }
      },
      taskProgressCallback: (TaskProgressUpdate update) {
        _progress.add({
          'type': 'progress',
          'taskId': update.task.taskId,
          'progress': update.progress, // 0.0 .. 1.0
        });
      },
    );
  }

  /// Returns the local file path if already downloaded and present; otherwise null.
  Future<String?> getLocalPath(int messageId, String lang) async {
    final row =
        await (db.select(db.translations)..where(
          (t) => t.messageId.equals(messageId) & t.languageCode.equals(lang),
        )).getSingleOrNull();

    if (row == null) return null;
    if (row.audioPath.isEmpty) return null;

    final f = File(row.audioPath);
    return await f.exists() ? row.audioPath : null;
  }

  /// Queue a Wi-Fi-only background download.
  /// [audioUrl] must be public or a valid signed URL.
  Future<Task> download(int messageId, String lang, String audioUrl) async {
    final ext = _inferExt(audioUrl) ?? 'mp3';
    final filename = '${messageId}_$lang.$ext';

    // Ensure directory exists (the completion handler will write here)
    await _ensureAudiosDir();

    final task = DownloadTask(
      url: audioUrl,
      filename: filename,
      baseDirectory: BaseDirectory.applicationDocuments,
      directory: 'audio', // <Documents>/audio/...
      updates: Updates.statusAndProgress,
      retries: 2,
      requiresWiFi: true, // <-- Wi-Fi only
      metaData: _encodeMeta(messageId, lang, ext),
    );

    await _downloader.enqueue(task);
    return task;
  }

  /// Remove local cached file and clear audioPath in DB.
  Future<void> remove(int messageId, String lang) async {
    final row =
        await (db.select(db.translations)..where(
          (t) => t.messageId.equals(messageId) & t.languageCode.equals(lang),
        )).getSingleOrNull();
    if (row == null) return;

    if (row.audioPath.isNotEmpty) {
      final f = File(row.audioPath);
      if (await f.exists()) {
        await f.delete();
      }
    }

    await db.upsertTranslation(
      TranslationsCompanion(
        messageId: Value(messageId),
        languageCode: Value(lang),
        audioPath: const Value(''),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// List all downloaded files with their message info.
  Stream<List<DownloadedFile>> watchDownloads() {
    final query = db.select(db.translations).join([
      innerJoin(
        db.messages,
        db.messages.id.equalsExp(db.translations.messageId),
      ),
    ])..where(db.translations.audioPath.length.isBiggerThanValue(0));

    return query.watch().map((rows) {
      return rows
          .map((row) {
            final tr = row.readTable(db.translations);
            final msg = row.readTable(db.messages);
            final file = File(tr.audioPath);
            final size = file.existsSync() ? file.lengthSync() : 0;
            return DownloadedFile(
              messageId: tr.messageId,
              title: msg.title,
              languageCode: tr.languageCode,
              path: tr.audioPath,
              sizeBytes: size,
            );
          })
          .where((item) => item.sizeBytes > 0)
          .toList();
    });
  }

  // ======================
  // Helpers
  // ======================

  Future<String> _targetPath(int messageId, String lang, String ext) async {
    final dir = await getApplicationDocumentsDirectory();
    final audiosDir = Directory(p.join(dir.path, 'audio'));
    return p.join(audiosDir.path, '${messageId}_$lang.$ext');
  }

  Future<void> _ensureAudiosDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final audiosDir = Directory(p.join(dir.path, 'audio'));
    if (!await audiosDir.exists()) {
      await audiosDir.create(recursive: true);
    }
  }

  String? _inferExt(String url) {
    final u = url.toLowerCase();
    if (u.contains('.mp3')) return 'mp3';
    if (u.contains('.m4a')) return 'm4a';
    if (u.contains('.aac')) return 'aac';
    if (u.contains('.wav')) return 'wav';
    return null;
  }

  String _encodeMeta(int id, String lang, String ext) => '$id|$lang|$ext';
  (int, String, String) _decodeMeta(String? meta) {
    if (meta == null || !meta.contains('|')) return (0, '', 'mp3');
    final parts = meta.split('|');
    final id = int.tryParse(parts[0]) ?? 0;
    final lang = parts.length > 1 ? parts[1] : '';
    final ext = parts.length > 2 ? parts[2] : 'mp3';
    return (id, lang, ext);
  }

  void dispose() {
    _progress.close();
  }
}
