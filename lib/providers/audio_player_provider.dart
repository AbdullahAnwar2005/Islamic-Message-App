// lib/providers/audio_player_provider.dart
//
// B-3 FIX: There is now ONE AudioPlayer, owned by AppAudioHandler.
// This provider drives UI state by subscribing to the handler's streams,
// so notification controls (lock screen, headset buttons) and the UI
// are always in sync.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import 'audio_download_progress_provider.dart';
import 'audio_service_providers.dart';
import 'playback_speed_provider.dart';

/// Immutable UI state snapshot.
@immutable
class AudioPlayerState {
  final bool isLoading;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;
  final String? sourcePath; // local or remote URI
  final int? activeMessageId; // currently loaded message

  const AudioPlayerState({
    this.isLoading = false,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.sourcePath,
    this.activeMessageId,
  });

  AudioPlayerState copyWith({
    bool? isLoading,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
    String? sourcePath,
    int? activeMessageId,
  }) => AudioPlayerState(
    isLoading: isLoading ?? this.isLoading,
    isPlaying: isPlaying ?? this.isPlaying,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    speed: speed ?? this.speed,
    sourcePath: sourcePath ?? this.sourcePath,
    activeMessageId: activeMessageId ?? this.activeMessageId,
  );
}

/// Global audio UI state — reads from AppAudioHandler streams.
/// B-3: There is NO second AudioPlayer created here.
final audioPlayerProvider =
    NotifierProvider<_AudioPlayerNotifier, AudioPlayerState>(
      _AudioPlayerNotifier.new,
    );

class _AudioPlayerNotifier extends Notifier<AudioPlayerState> {
  @override
  AudioPlayerState build() {
    final handler = ref.read(audioHandlerProvider);

    // Subscribe to the SINGLE player's streams via the handler.
    final posSub = handler.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    final durSub = handler.durationStream.listen((dur) {
      if (dur != null) state = state.copyWith(duration: dur);
    });

    final playingSub = handler.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    // Map PlaybackState.processingState → isLoading
    final pbSub = handler.playbackState.listen((pb) {
      final loading =
          pb.processingState == AudioProcessingState.loading ||
          pb.processingState == AudioProcessingState.buffering;
      state = state.copyWith(isLoading: loading, isPlaying: pb.playing);
    });

    // Cleanup: cancel all subscriptions. Do NOT dispose handler — it outlives
    // this provider and is managed by main().
    ref.onDispose(() {
      posSub.cancel();
      durSub.cancel();
      playingSub.cancel();
      pbSub.cancel();
    });

    // Listen to persisted speed changes
    ref.listen(playbackSpeedProvider, (prev, next) {
      if (prev != next) {
        handler.setSpeed(next);
        state = state.copyWith(speed: next);
      }
    });

    return AudioPlayerState(speed: ref.read(playbackSpeedProvider));
  }

  // ---------------------------------------------------------------------------
  // Speed
  // ---------------------------------------------------------------------------
  Future<void> setSpeed(double v) async {
    try {
      await ref.read(playbackSpeedProvider.notifier).setSpeed(v);
    } catch (e) {
      if (kDebugMode) debugPrint('[AudioPlayer] Failed to set speed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Load a source and prepare for playback.
  // If the same message+path is already loaded, this is a no-op.
  // ---------------------------------------------------------------------------
  Future<void> loadSource({
    required int messageId,
    required String path,
    required String mediaId,
    required String title,
  }) async {
    // Same track already loaded → nothing to do.
    if (state.activeMessageId == messageId && state.sourcePath == path) return;

    state = state.copyWith(isLoading: true, activeMessageId: messageId);

    try {
      await ref
          .read(audioHandlerProvider)
          .loadAndPlaySingle(id: mediaId, title: title, sourcePath: path);
      // Handler will emit playbackState which updates isLoading/isPlaying.
      state = state.copyWith(isLoading: false, sourcePath: path);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Transport controls — delegate to handler
  // ---------------------------------------------------------------------------
  Future<void> play() => ref.read(audioHandlerProvider).play();
  Future<void> pause() => ref.read(audioHandlerProvider).pause();
  Future<void> seek(Duration pos) => ref.read(audioHandlerProvider).seek(pos);

  bool get isPlaying => state.isPlaying;
}

// ---------------------------------------------------------------------------
// Helper: resolve local path if downloaded, else fall back to remote URL.
// M-1 FIX: uses .autoDispose.family so entries are released when unused.
// ---------------------------------------------------------------------------
typedef AudioLookupParams = ({int messageId, String lang, String? remoteUrl});

final audioPlayablePathProvider = FutureProvider.autoDispose
    .family<String?, AudioLookupParams>((ref, p) async {
      final local = await ref.read(
        audioLocalPathProvider((id: p.messageId, lang: p.lang)).future,
      );
      if (local != null && local.isNotEmpty) return local;
      return p.remoteUrl; // may be null
    });
