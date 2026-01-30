import '../data/local/app_database.dart';
import '../providers/message_language_provider.dart';

Translation? pickTranslation(
    List<Translation> list,
    String desired, {
      String fallback = 'ar',
    }) {
  String n(String c) => normalizeLang(c);
  final want = list.firstWhere(
        (t) => n(t.languageCode) == n(desired),
    orElse: () => null as Translation, // will be caught below
  );
  if (want != null) return want;

  final fb = list.firstWhere(
        (t) => n(t.languageCode) == n(fallback),
    orElse: () => null as Translation,
  );
  return fb ?? (list.isNotEmpty ? list.first : null);
}
