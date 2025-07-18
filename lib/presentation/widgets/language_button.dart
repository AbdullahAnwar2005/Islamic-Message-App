import 'package:flutter/material.dart';

class LanguageButton extends StatelessWidget {
  final String currentLanguageLabel;
  final String currentLanguageCode;
  final void Function(String) onLanguageSelected;

  const LanguageButton({
    super.key,
    required this.currentLanguageLabel,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      borderRadius: BorderRadius.circular(5),
      color: theme.cardColor,
      onSelected: onLanguageSelected,
      tooltip: 'Change language',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'ar',
          child: Row(
            children: [
              const Icon(Icons.language),
              const SizedBox(width: 8),
              const Text('العربية'),
              if (currentLanguageCode == 'ar') const Spacer(),
              if (currentLanguageCode == 'ar') const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              const Icon(Icons.language),
              const SizedBox(width: 8),
              const Text('English'),
              if (currentLanguageCode == 'en') const Spacer(),
              if (currentLanguageCode == 'en') const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'fr',
          child: Row(
            children: [
              const Icon(Icons.language),
              const SizedBox(width: 8),
              const Text('Français'),
              if (currentLanguageCode == 'fr') const Spacer(),
              if (currentLanguageCode == 'fr') const Icon(Icons.check, size: 16),
            ],
          ),
        ),
      ],
      child: Row(
        children: [
          const Icon(Icons.language, size: 18),
          const SizedBox(width: 6),
          Text(
            currentLanguageLabel,
            style: theme.textTheme.bodySmall,
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }
}
