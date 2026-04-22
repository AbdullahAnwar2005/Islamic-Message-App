import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioController {
  bool get isPlaying => false;
  void play() {}
  void pause() {}
}

final audioControllerProvider =
Provider<AudioController>((ref) => AudioController());
