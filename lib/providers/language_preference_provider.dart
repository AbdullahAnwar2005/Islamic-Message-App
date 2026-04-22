// lib/providers/language_preference_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'message_language_provider.dart' show appLanguageProvider;

/// Provider to check if user has completed initial language selection
final hasCompletedLanguageSelectionProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasCompletedLanguageSelection') ?? false;
});

/// Notifier to manage language selection completion
class LanguageSelectionNotifier extends StateNotifier<bool> {
  LanguageSelectionNotifier() : super(false);

  Future<void> markAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedLanguageSelection', true);
    state = true;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedLanguageSelection', false);
    state = false;
  }
}

final languageSelectionNotifierProvider =
    StateNotifierProvider<LanguageSelectionNotifier, bool>(
      (ref) => LanguageSelectionNotifier(),
    );

/// Helper to determine if current language is RTL
final isRtlLanguageProvider = Provider<bool>((ref) {
  final currentLang = ref.watch(appLanguageProvider);
  return const {'ar', 'ur', 'fa', 'he'}.contains(currentLang.toLowerCase());
});
