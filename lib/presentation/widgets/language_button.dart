import 'package:flutter/material.dart';
import '../../utils/choose_translation_utility.dart' show norm;
import '../../utils/arabic_language_names.dart' show arabicLanguageName;

class LanguageButton extends StatelessWidget {
  const LanguageButton({
    super.key,
    required this.currentLanguageCode,
    required this.currentLanguageLabel,
    required this.options,
    required this.onLanguageSelected,
  });

  final String currentLanguageCode;     // e.g. 'ar' or 'ar-SA'
  final String currentLanguageLabel;    // e.g. 'العربية'
  final List<String> options;           // e.g. ['ar','en','fr','am','hi','sw','tl']
  final ValueChanged<String?> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final normalizedCurrent = norm(currentLanguageCode);

    final seen = <String>{};
    final normalizedOptions = <String>[];
    for (final c in options.map(norm)) {
      if (seen.add(c)) normalizedOptions.add(c);
    }

    if (!normalizedOptions.contains(normalizedCurrent)) {
      normalizedOptions.insert(0, normalizedCurrent);
    }

    const pref = ['ar','en','fr','ur','fa','id'];
    int rank(String c) => !pref.contains(c) ? 999 : pref.indexOf(c);
    normalizedOptions.sort((a, b) => rank(a).compareTo(rank(b)));

    return PopupMenuButton<String>(
      tooltip: 'تغيير اللغة',
      color: theme.scaffoldBackgroundColor,
      initialValue: normalizedCurrent,
      onSelected: onLanguageSelected,
      itemBuilder: (context) {
        return normalizedOptions.map((code) {
          final selected = code == normalizedCurrent;
          return CheckedPopupMenuItem<String>(
            value: code,
            checked: selected,
            padding: const EdgeInsets.all(5),
            child: Text(arabicLanguageName(code)),  // 👈 Arabic name in menu
          );
        }).toList();
      },
      // Button UI
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.translate, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(arabicLanguageName(normalizedCurrent)), // 👈 Arabic name on button
        ],
      ),
    );
  }
}
