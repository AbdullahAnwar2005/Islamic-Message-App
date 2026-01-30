import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application-wide locale (UI language).
/// independent of the content language.
final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((
  ref,
) {
  return AppLocaleNotifier();
});

class AppLocaleNotifier extends StateNotifier<Locale> {
  // Default to Arabic
  AppLocaleNotifier() : super(const Locale('ar')) {
    _loadLocale();
  }

  static const String _kLocaleKey = 'app_locale';

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kLocaleKey);
      if (code != null) {
        state = Locale(code);
      }
    } catch (_) {
      // fallback to initial state (ar)
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}
