import 'dart:async';
import 'contracts.dart';

/// A no-audio mock so the UI works now.
/// Status will be `none` when audioUri is null → controls disabled in UI.
class MockAudioController implements IAudioController {
  final _pos = StreamController<Duration>.broadcast();
  final _status = StreamController<AudioStatus>.broadcast();

  Duration _posVal = Duration.zero;
  Duration _durVal = const Duration(minutes: 30);
  double _rate = 1.0;
  AudioStatus _statusVal = AudioStatus.none;

  @override Stream<Duration> get positionStream => _pos.stream;
  @override Stream<AudioStatus> get statusStream => _status.stream;

  @override Duration get duration => _durVal;
  @override Duration get position => _posVal;
  @override double get rate => _rate;
  @override AudioStatus get status => _statusVal;

  @override
  Future<void> load({required String messageId, required Uri? audioUri}) async {
    // If there's no URI, disable controls.
    _statusVal = audioUri == null ? AudioStatus.none : AudioStatus.paused;
    _status.add(_statusVal);
    _posVal = Duration.zero;
    _pos.add(_posVal);
  }

  @override
  Future<void> play() async {
    if (_statusVal == AudioStatus.none) return;
    _statusVal = AudioStatus.playing;
    _status.add(_statusVal);
    // (No ticker here; UI progress bar just shows a static fraction)
  }

  @override
  Future<void> pause() async {
    if (_statusVal == AudioStatus.none) return;
    _statusVal = AudioStatus.paused;
    _status.add(_statusVal);
  }

  @override
  Future<void> seek(Duration position) async {
    _posVal = position.inMilliseconds.clamp(0, _durVal.inMilliseconds) == position.inMilliseconds
        ? position
        : Duration(milliseconds: position.inMilliseconds.clamp(0, _durVal.inMilliseconds));
    _pos.add(_posVal);
  }

  @override
  Future<void> setRate(double rate) async {
    _rate = rate;
  }
}
