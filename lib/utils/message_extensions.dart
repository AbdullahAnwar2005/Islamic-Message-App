import '../data/local/app_database.dart';

extension LocalizedMessageTitle on Message {
  /// Returns the title in the requested [appLangCode], falling back to English/Arabic title if available,
  /// and finally to the default [title].
  /// [appLangCode] should be normalized (e.g., 'ar', 'en').
  String localizedTitle(String appLangCode) {
    // Normalize logic if needed, but assuming caller provides 'ar' or 'en'
    final lang = appLangCode.toLowerCase();

    if (lang.startsWith('ar') &&
        titleAr != null &&
        titleAr!.trim().isNotEmpty) {
      return titleAr!;
    }
    if (lang.startsWith('en') &&
        titleEn != null &&
        titleEn!.trim().isNotEmpty) {
      return titleEn!;
    }

    // Fallback: if we are in 'en' but no titleEn, try titleAr ?? title
    // Actually standard fallback is just 'title' which is the default column
    return title;
  }
}
