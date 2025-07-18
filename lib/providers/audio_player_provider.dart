import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const AudioPlayerState({
    required this.isPlaying,
    required this.position,
    required this.duration,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  factory AudioPlayerState.initial() => const AudioPlayerState(
    isPlaying: false,
    position: Duration.zero,
    duration: Duration.zero,
  );
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final _player = AudioPlayer();
  String? _currentAssetPath;

  AudioPlayerNotifier() : super(AudioPlayerState.initial()) {
    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });
    _player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
    });
  }

  String? get currentAssetPath => _currentAssetPath;

  Future<void> setAsset(String assetPath) async {
    if (_currentAssetPath == assetPath) return;
    try {
      print('🎧 Loading audio asset: $assetPath');
      await _player.setAsset(assetPath);
      _currentAssetPath = assetPath;
    } catch (e) {
      print('❌ Failed to load asset: $e');
    }
  }

  void play() => _player.play();
  void pause() => _player.pause();
  void stop() => _player.stop();
  void seek(Duration position) => _player.seek(position);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioPlayerProvider = StateNotifierProvider.family<AudioPlayerNotifier, AudioPlayerState, int>(
      (ref, messageId) => AudioPlayerNotifier(),
);
