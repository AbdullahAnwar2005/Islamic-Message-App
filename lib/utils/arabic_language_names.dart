// lib/utils/arabic_language_names.dart
import 'choose_translation_utility.dart' show norm;

/// Arabic display names for language codes
const Map<String, String> _arabicLanguageNames = {
  'ar': 'العربية',
  'en': 'الإنجليزية',
  'fr': 'الفرنسية',
  'ur': 'الأردية',
  'fa': 'الفارسية',
  'id': 'الإندونيسية',

  // ✅ Extra languages you mentioned:
  'am': 'الأمهرية',
  'hi': 'الهندية',
  'sw': 'السواحيلية',
  'tl': 'التاغالوغية',

  // You can keep extending as needed:
  'bn': 'البنغالية',
  'tr': 'التركية',
  'ru': 'الروسية',
  'zh': 'الصينية',
  'es': 'الإسبانية',
  'pt': 'البرتغالية',
  'de': 'الألمانية',
};

String arabicLanguageName(String code) {
  final base = norm(code); // e.g. "ar-SA" -> "ar"
  return _arabicLanguageNames[base] ?? base.toUpperCase();
}
