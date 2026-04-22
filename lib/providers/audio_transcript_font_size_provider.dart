import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final audioTranscriptFontSizeProvider =
    StateNotifierProvider<AudioTranscriptFontSizeNotifier, double>(
      (ref) => AudioTranscriptFontSizeNotifier(),
    );

class AudioTranscriptFontSizeNotifier extends StateNotifier<double> {
  static const _key = 'audio_transcript_font_size';

  AudioTranscriptFontSizeNotifier() : super(20.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSize = prefs.getDouble(_key);
    if (savedSize != null) {
      if (mounted) {
        state = savedSize;
      }
    }
  }

  Future<void> setFontSize(double newSize) async {
    state = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, newSize);
  }
}
