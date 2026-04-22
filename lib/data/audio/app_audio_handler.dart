// lib/data/audio/app_audio_handler.dart
//
// B-3 FIX: This is the SINGLE AudioPlayer owner.
// The UI (audio_player_provider.dart) subscribes to this handler's streams
// rather than creating its own AudioPlayer.
// M-6 FIX: Audio session interruptions (phone calls) are handled here.

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../analytics/analytics_service.dart';

class AppAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  AnalyticsService? _analytics;

  // Interruption subscription
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;

  // Track playback session for analytics
  DateTime? _playStartTime;
  String? _currentMessageId;
  String? _currentLang;

  void setAnalytics(AnalyticsService service) {
    _analytics = service;
  }

  AppAudioHandler() {
    _initAudioSession();
    _initPlayerEvents();
  }

  // ---------------------------------------------------------------------------
  // M-6: Audio session interruption handling (phone calls, notifications)
  // ---------------------------------------------------------------------------
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      _interruptionSub = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          // Interruption started (e.g., phone call)
          if (_player.playing) {
            _player.pause();
          }
        } else {
          // Interruption ended — only resume if we were playing
          if (event.type == AudioInterruptionType.pause &&
              _player.processingState == ProcessingState.ready) {
            _player.play();
          }
        }
      });
    } catch (e) {
      if (kDebugMode)
        debugPrint('[AppAudioHandler] Could not set up audio session: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Wire player events → playbackState (visible to OS notification + screens)
  // ---------------------------------------------------------------------------
  void _initPlayerEvents() {
    _player.playbackEventStream.listen(
      (event) {
        final playing = _player.playing;

        // Analytics: session start
        if (playing && _playStartTime == null) {
          _playStartTime = DateTime.now();
          if (_currentMessageId != null && _currentLang != null) {
            _analytics?.track(
              'audio_play_start',
              properties: {
                'message_id': _currentMessageId,
                'language_code': _currentLang,
              },
            );
          }
        } else if (!playing && _playStartTime != null) {
          _trackPlayEnd(completed: false);
        }

        playbackState.add(
          playbackState.value.copyWith(
            controls: [
              MediaControl.rewind,
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.stop,
              MediaControl.fastForward,
            ],
            systemActions: const {
              MediaAction.seek,
              MediaAction.seekForward,
              MediaAction.seekBackward,
              MediaAction.setSpeed,
            },
            androidCompactActionIndices: const [0, 1, 3],
            processingState: _toProcessingState(_player.processingState),
            playing: playing,
            updatePosition: _player.position,
            bufferedPosition: _player.bufferedPosition,
            speed: _player.speed,
          ),
        );

        if (_player.processingState == ProcessingState.completed) {
          _trackPlayEnd(completed: true);
        }
      },
      onError: (Object e) {
        _analytics?.track(
          'audio_error',
          properties: {
            'error_code': e.toString(),
            'message_id': _currentMessageId,
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Load a source and set the media item. Does NOT auto-play.
  // Callers must call play() explicitly after loadAndPlaySingle.
  // ---------------------------------------------------------------------------
  Future<void> loadAndPlaySingle({
    required String id,
    required String title,
    String? artist,
    String? artUri,
    required String sourcePath,
    bool autoPlay = true,
  }) async {
    final item = MediaItem(
      id: id,
      album: 'رسالة الإسلام',
      title: title,
      artist: artist ?? 'رسالة الإسلام',
      artUri: artUri != null ? Uri.parse(artUri) : null,
      duration: null,
      extras: {'sourcePath': sourcePath},
    );

    mediaItem.add(item);

    final source = AudioSource.uri(Uri.parse(sourcePath), tag: item);
    await _player.setAudioSource(source);

    // Parse ID for analytics: "123-ar" or "123:ar"
    try {
      final sep = id.contains(':') ? ':' : '-';
      final parts = id.split(sep);
      if (parts.length >= 2) {
        _currentMessageId = parts[0];
        _currentLang = parts[1];
      }
    } catch (_) {}

    if (autoPlay) {
      await _player.play();
    }
  }

  // ---------------------------------------------------------------------------
  // BaseAudioHandler overrides
  // ---------------------------------------------------------------------------
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekRelative(Duration delta) async {
    final newPos = _player.position + delta;
    final safe = newPos < Duration.zero ? Duration.zero : newPos;
    await _player.seek(safe);
  }

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  // ---------------------------------------------------------------------------
  // Streams + getters that UI layer subscribes to (B-3)
  // ---------------------------------------------------------------------------
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<bool> get playingStream => _player.playingStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;
  double get speed => _player.speed;

  // ---------------------------------------------------------------------------
  // Dispose: clean up player AND interruption subscription
  // ---------------------------------------------------------------------------
  Future<void> dispose() async {
    _trackPlayEnd(completed: false);
    await _interruptionSub?.cancel();
    await _player.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------
  static AudioProcessingState _toProcessingState(ProcessingState s) {
    switch (s) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  void _trackPlayEnd({required bool completed}) {
    if (_playStartTime == null) return;

    final durationMs =
        DateTime.now().difference(_playStartTime!).inMilliseconds;
    _playStartTime = null;

    double ratio = 0.0;
    final total = _player.duration?.inMilliseconds;
    final pos = _player.position.inMilliseconds;
    if (total != null && total > 0) {
      ratio = completed ? 1.0 : (pos / total).clamp(0.0, 1.0);
    }

    final effectiveCompleted = completed || ratio >= 0.9;

    if (_currentMessageId != null) {
      _analytics?.track(
        'audio_play_end',
        properties: {
          'message_id': _currentMessageId,
          'language_code': _currentLang,
          'time_listened_ms': durationMs,
          'completion_ratio': ratio,
          'completed': effectiveCompleted,
        },
      );
    }
  }
}
