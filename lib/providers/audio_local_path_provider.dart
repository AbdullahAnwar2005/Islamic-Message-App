// lib/providers/audio_local_path_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Returns the local file path for a given (messageId, lang) if it exists; else null.
final audioLocalPathProvider =
FutureProvider.family<String?, ({int id, String lang})>((ref, args) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/audio_${args.id}_${args.lang}.mp3');
  return await file.exists() ? file.path : null;
});
