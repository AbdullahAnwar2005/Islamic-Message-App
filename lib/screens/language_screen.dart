import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'code': 'ar', 'label': 'العربية'},
      {'code': 'en', 'label': 'English'},
      {'code': 'fr', 'label': 'Français'},
      // أضف لغات أخرى هنا
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر اللغة'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const Divider(height: 20),
        itemBuilder: (context, index) {
          final lang = languages[index];

          return ListTile(
            title: Text(
              lang['label']!,
              style: const TextStyle(fontSize: 18),
            ),
            onTap: () async {
              final newLocale = Locale(lang['code']!);
              await context.setLocale(newLocale);

              // Navigate to message screen or home
              Navigator.pushReplacementNamed(context, '/home');
            },
            trailing: context.locale.languageCode == lang['code']
                ? const Icon(Icons.check, color: Colors.green)
                : null,
          );
        },
      ),
    );
  }
}
