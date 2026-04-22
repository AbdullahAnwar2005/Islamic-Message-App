// utils/choose_translation_utility.dart
import 'package:alghaya_men_alkhalg/data/local/app_database.dart';

String norm(String c) {
  final x = c.toLowerCase();
  if (x.startsWith('ar')) return 'ar';
  if (x.startsWith('en')) return 'en';
  return x;
}

Translation? pickTranslation(
    List<Translation> list,
    String desired, {
      String fallback = 'ar',
    }) {
  final want = list.where((t) => norm(t.languageCode) == norm(desired));
  if (want.isNotEmpty) return want.first;

  final fb = list.where((t) => norm(t.languageCode) == norm(fallback));
  if (fb.isNotEmpty) return fb.first;

  return list.isNotEmpty ? list.first : null;
}
