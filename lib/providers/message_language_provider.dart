import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide default language (used when no per-message override exists)
final appLanguageProvider = StateProvider<String>((_) => 'ar');

/// messageId -> langCode (normalized: 'ar' / 'en')
/// Now persists to SharedPreferences for offline persistence
class MessageLangOverrides extends Notifier<Map<int, String>> {
  static const String _prefKey = 'message_language_preferences';

  @override
  Map<int, String> build() {
    // Load from SharedPreferences on initialization
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefKey);
    if (json != null && json.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(json);
        final Map<int, String> loaded = {};
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          if (id != null && value is String) {
            loaded[id] = value;
          }
        });
        state = loaded;
      } catch (e) {
        // Ignore JSON errors, start with empty map
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert Map<int, String> to Map<String, String> for JSON
    final Map<String, String> toSave = {};
    state.forEach((key, value) {
      toSave[key.toString()] = value;
    });
    await prefs.setString(_prefKey, jsonEncode(toSave));
  }

  void setOverride(int id, String lang) {
    state = {...state, id: _norm(lang)};
    _saveToPrefs(); // Persist to SharedPreferences
  }

  void setLanguage(int id, String lang) => setOverride(id, lang);

  void clearOverride(int id) {
    final m = {...state}..remove(id);
    state = m;
    _saveToPrefs(); // Persist to SharedPreferences
  }

  String _norm(String c) {
    final low = c.toLowerCase();
    if (low.startsWith('ar')) return 'ar';
    if (low.startsWith('en')) return 'en';
    return low;
  }
}

final messageLangOverridesProvider =
    NotifierProvider<MessageLangOverrides, Map<int, String>>(
      MessageLangOverrides.new,
    );

/// Persisted default content language (nullable - not set initially)
/// When set, all messages without override use this language
class DefaultContentLanguageNotifier extends StateNotifier<String?> {
  static const String _prefKey = 'default_content_language';

  DefaultContentLanguageNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_prefKey);
  }

  Future<void> setDefault(String? langCode) async {
    state = langCode?.toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    if (langCode == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, langCode.toLowerCase());
    }
  }

  Future<void> clear() async {
    await setDefault(null);
  }
}

final defaultContentLanguageProvider =
    StateNotifierProvider<DefaultContentLanguageNotifier, String?>(
      (ref) => DefaultContentLanguageNotifier(),
    );
