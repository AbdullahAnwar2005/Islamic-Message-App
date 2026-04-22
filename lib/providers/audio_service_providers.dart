import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../data/audio/app_audio_handler.dart';

// Injected from main() to guarantee single init
final audioHandlerProvider = Provider<AppAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main()');
});

// Lightweight UI streams
final isPlayingStreamProvider = StreamProvider<bool>((ref) {
  final h = ref.watch(audioHandlerProvider);
  return h.playingStream;
});

final positionStreamProvider = StreamProvider<Duration>((ref) {
  final h = ref.watch(audioHandlerProvider);
  return h.positionStream;
});

final durationStreamProvider = StreamProvider<Duration?>((ref) {
  final h = ref.watch(audioHandlerProvider);
  return h.durationStream;
});

final mediaItemStreamProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});