import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final playbackSpeedProvider =
    StateNotifierProvider<PlaybackSpeedNotifier, double>(
      (ref) => PlaybackSpeedNotifier(),
    );

class PlaybackSpeedNotifier extends StateNotifier<double> {
  static const _key = 'audio_playback_speed';

  PlaybackSpeedNotifier() : super(1.0) {
    _loadSpeed();
  }

  Future<void> _loadSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble(_key);
    if (savedSpeed != null) {
      if (mounted) {
        state = savedSpeed;
      }
    }
  }

  Future<void> setSpeed(double newSpeed) async {
    state = newSpeed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, newSpeed);
  }
}
