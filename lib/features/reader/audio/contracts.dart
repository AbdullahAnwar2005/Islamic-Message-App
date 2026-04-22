import 'dart:async';

/// Lightweight status enum for the mini-player UI.
enum AudioStatus { none, loading, paused, playing, completed }

/// Player interface that your UI talks to.
/// You can later plug a real implementation (e.g., just_audio) without touching UI code.
abstract class IAudioController {
  // Streams for UI to listen to
  Stream<Duration> get positionStream;
  Stream<AudioStatus> get statusStream;

  // Lifecycle
  Future<void> load({required String messageId, required Uri? audioUri}); // audioUri can be null
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setRate(double rate);

  // Snapshots
  Duration get duration;
  Duration get position;
  double get rate;
  AudioStatus get status;
}

/// Paragraph <-> time mapping service (future karaoke-style sync).
abstract class IAudioSyncService {
  /// Return paragraphKey for a given timestamp.
  String? paragraphFor(Duration position);

  /// Return timestamp for a given paragraphKey.
  Duration? timestampFor(String paragraphKey);
}
