import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics_provider.dart' show sharedPreferencesProvider;

/// SharedPreferences key for the "Follow Audio" toggle.
const kFollowAudioKey = 'follow_audio_enabled';

/// Whether auto-scroll should follow the active audio block.
/// Default: true. Persisted via SharedPreferences.
final followAudioEnabledProvider = NotifierProvider<FollowAudioNotifier, bool>(
  FollowAudioNotifier.new,
);

class FollowAudioNotifier extends Notifier<bool> {
  late final SharedPreferences _prefs;

  @override
  bool build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _prefs.getBool(kFollowAudioKey) ?? true;
  }

  void setEnabled(bool value) {
    state = value;
    _prefs.setBool(kFollowAudioKey, value);
  }
}
