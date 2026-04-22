import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DownloadedFile {
  final int messageId;
  final String languageCode;
  final String path;
  final int sizeBytes;

  DownloadedFile({
    required this.messageId,
    required this.languageCode,
    required this.path,
    required this.sizeBytes,
  });
}

// -------- PROGRESS PROVIDER --------
// null = idle, 0..1 = downloading
final audioDownloadProgressForFileProvider =
    StateProvider.family<double?, (int, String)>((ref, args) => null);

// M-1 FIX: .autoDispose ensures family entries are released when unobserved.
final audioLocalPathProvider = FutureProvider.autoDispose
    .family<String?, ({int id, String lang})>((ref, args) async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/audio_${args.id}_${args.lang}.mp3');
      return await file.exists() ? file.path : null;
    });

// -------- SERVICE PROVIDER --------
final audioDownloadServiceProvider = Provider<AudioDownloadService>((ref) {
  return AudioDownloadService(ref);
});

class AudioDownloadService {
  AudioDownloadService(this.ref);

  final Ref ref;
  final http.Client _client = http.Client();

  // Track active jobs: subscription + sink + cancel flag
  final Map<(int, String), StreamSubscription<List<int>>> _subs = {};
  final Map<(int, String), IOSink> _sinks = {};
  final Map<(int, String), bool> _canceled = {};

  Future<void> download(int messageId, String langCode, String url) async {
    final key = (messageId, langCode);

    // Cancel any existing job for this key first
    await cancel(messageId, langCode);

    final dir = await getApplicationDocumentsDirectory();
    final finalPath = '${dir.path}/audio_${messageId}_$langCode.mp3';
    final partPath = '$finalPath.part';
    final finalFile = File(finalPath);
    final partFile = File(partPath);

    // Ensure dir exists
    if (!await partFile.parent.exists()) {
      await partFile.parent.create(recursive: true);
    }

    // Reset and show progress
    ref.read(audioDownloadProgressForFileProvider(key).notifier).state = 0.0;

    final request = http.Request('GET', Uri.parse(url));
    request.headers['User-Agent'] = 'AlghayaApp/1.0';
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      ref.read(audioDownloadProgressForFileProvider(key).notifier).state = null;
      throw Exception('Failed to download audio: ${response.statusCode}');
    }

    final total = response.contentLength ?? 0;
    int downloaded = 0;

    final sink = partFile.openWrite();
    _sinks[key] = sink;
    _canceled[key] = false;

    final completer = Completer<void>();

    final sub = response.stream.listen(
      (chunk) {
        if (_canceled[key] == true)
          return; // ignore further chunks after cancel flag
        downloaded += chunk.length;
        sink.add(chunk);
        if (total > 0) {
          final progress = downloaded / total;
          ref.read(audioDownloadProgressForFileProvider(key).notifier).state =
              progress;
        }
      },
      onError: (e) async {
        // cleanup
        try {
          await sink.close();
        } catch (_) {}
        try {
          if (await partFile.exists()) await partFile.delete();
        } catch (_) {}
        ref.read(audioDownloadProgressForFileProvider(key).notifier).state =
            null;
        _cleanup(key);
        if (!_canceled[key]!) {
          completer.completeError(e);
        } else {
          completer.complete(); // canceled -> treat as handled
        }
      },
      onDone: () async {
        try {
          await sink.close();
        } catch (_) {}

        if (_canceled[key] == true) {
          // canceled: delete partial and clear progress
          try {
            if (await partFile.exists()) await partFile.delete();
          } catch (_) {}
          ref.read(audioDownloadProgressForFileProvider(key).notifier).state =
              null;
          _cleanup(key);
          completer.complete();
          return;
        }

        // Success: replace final file
        try {
          if (await finalFile.exists()) await finalFile.delete();
          await partFile.rename(finalPath);
        } catch (_) {
          // If rename fails, try copy+delete as fallback
          try {
            await partFile.copy(finalPath);
            await partFile.delete();
          } catch (_) {}
        }

        // Clear progress and refresh local path
        ref.read(audioDownloadProgressForFileProvider(key).notifier).state =
            null;
        ref.invalidate(audioLocalPathProvider((id: messageId, lang: langCode)));

        _cleanup(key);
        completer.complete();
      },
      cancelOnError: true,
    );

    _subs[key] = sub;

    return completer.future;
  }

  /// Immediate cancel: stop stream, close sink, delete partial, clear progress.
  Future<void> cancel(int messageId, String langCode) async {
    final key = (messageId, langCode);

    // mark canceled
    _canceled[key] = true;

    // cancel stream
    final sub = _subs[key];
    if (sub != null) {
      try {
        await sub.cancel();
      } catch (_) {}
    }

    // close sink
    final sink = _sinks[key];
    if (sink != null) {
      try {
        await sink.close();
      } catch (_) {}
    }

    // delete .part file
    try {
      final dir = await getApplicationDocumentsDirectory();
      final partPath = '${dir.path}/audio_${messageId}_$langCode.mp3.part';
      final partFile = File(partPath);
      if (await partFile.exists()) {
        await partFile.delete();
      }
    } catch (_) {}

    // clear UI instantly
    ref.read(audioDownloadProgressForFileProvider(key).notifier).state = null;

    _cleanup(key);
  }

  // M-5 FIX: Uses the same path pattern as download() — audio_ID_lang.mp3
  Future<String?> getLocalPath(int messageId, String lang) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/audio_${messageId}_$lang.mp3';
    final file = File(filePath);
    if (await file.exists()) return file.path;
    return null;
  }

  /// Delete a finished file (also cancels if in-flight)
  Future<void> remove(int messageId, String langCode) async {
    await cancel(messageId, langCode);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/audio_${messageId}_$langCode.mp3');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    ref.invalidate(audioLocalPathProvider((id: messageId, lang: langCode)));
  }

  void _cleanup((int, String) key) {
    _subs.remove(key);
    _sinks.remove(key);
    _canceled.remove(key);
  }

  Future<List<DownloadedFile>> getDownloadedFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final List<DownloadedFile> results = [];
    if (!await dir.exists()) return results;

    // Pattern: audio_{id}_{lang}.mp3
    final files = dir.listSync();
    for (final entity in files) {
      if (entity is File) {
        final name = entity.uri.pathSegments.last;
        if (name.startsWith('audio_') &&
            name.endsWith('.mp3') &&
            !name.endsWith('.part')) {
          final parts = name.replaceAll('.mp3', '').split('_');
          // parts: [audio, id, lang]
          if (parts.length >= 3) {
            final id = int.tryParse(parts[1]);
            final lang = parts[2];
            if (id != null) {
              results.add(
                DownloadedFile(
                  messageId: id,
                  languageCode: lang,
                  path: entity.path,
                  sizeBytes: entity.lengthSync(),
                ),
              );
            }
          }
        }
      }
    }
    return results;
  }
}
