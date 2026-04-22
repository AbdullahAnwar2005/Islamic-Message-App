import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>(
      (ref) => FontSizeNotifier(),
);

class FontSizeNotifier extends StateNotifier<double> {
  static const _key = 'font_size';

  FontSizeNotifier() : super(16) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSize = prefs.getDouble(_key);
    if (savedSize != null) {
      state = savedSize;
    }
  }

  Future<void> setFontSize(double newSize) async {
    state = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, newSize);
  }
}
