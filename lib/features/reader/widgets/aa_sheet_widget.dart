import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/message_language_provider.dart';
import '../../../../utils/choose_translation_utility.dart';

import '../../../../providers/message_provider.dart';
import '../providers/reader_settings_provider.dart';
import '../../../localization/app_strings.dart';

class AaSheet extends ConsumerWidget {
  const AaSheet({super.key, required this.messageId});
  final int messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final notifier = ref.read(readerSettingsProvider.notifier);
    final theme = Theme.of(context);

    // Language state
    final langOverrides = ref.watch(messageLangOverridesProvider);
    final appLang = ref.watch(appLanguageProvider);
    final currentLang = norm(langOverrides[messageId] ?? appLang);
    final langNotifier = ref.read(messageLangOverridesProvider.notifier);

    // Fetch available languages for this message
    final messagesAsync = ref.watch(messagesWithTranslationsProvider);
    final availableLangs = <String>{'ar', 'en'}; // Default fallback
    if (messagesAsync.hasValue) {
      final list = messagesAsync.value!;
      try {
        final bundle = list.firstWhere((e) => e.message.id == messageId);
        availableLangs.clear();
        availableLangs.addAll(
          bundle.translations
              .map((t) => norm(t.languageCode))
              .whereType<String>(),
        );
      } catch (_) {}
    }
    final sortedLangs =
        availableLangs.toList()..sort((a, b) {
          if (a == 'ar') return -1;
          if (b == 'ar') return 1;
          return a.compareTo(b);
        });

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            AppStrings.of(context, 'appearance_title'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // View Mode Toggle (Segmented)
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(AppStrings.of(context, 'view_scroll')),
                  icon: Icon(Icons.view_stream_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(AppStrings.of(context, 'view_pager')),
                  icon: Icon(Icons.menu_book_outlined),
                ),
              ],
              selected: {settings.isPageView},
              onSelectionChanged: (Set<bool> newSelection) {
                notifier.setPageView(newSelection.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            AppStrings.of(context, 'text_settings'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // حجم الخط
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.of(context, 'font_size'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.remove,
                    color: theme.colorScheme.primary,
                    onPressed: () => notifier.adjustFontSize(-1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      settings.fontSize.toStringAsFixed(0),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto', // Monospace-ish for numbers
                      ),
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.add,
                    color: theme.colorScheme.primary,
                    onPressed: () => notifier.adjustFontSize(1),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // تباعد الأسطر
          Text(
            AppStrings.of(context, 'line_height'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: settings.lineHeight,
              min: 1.0,
              max: 2.5,
              divisions: 6, // 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5
              label: settings.lineHeight.toStringAsFixed(2),
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.primaryContainer,
              onChanged: notifier.setLineHeight,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            AppStrings.of(context, 'language_settings'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Language Selector using Chips or Segmented Button
          // Let's use SegmentedButton for clarity if few options, or Wrap of ChoiceChips
          Wrap(
            spacing: 8,
            children:
                sortedLangs.map((code) {
                  final isSelected = (currentLang == code);
                  return ChoiceChip(
                    label: Text(
                      AppStrings.of(context, 'lang_$code'),
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : null,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        langNotifier.setLanguage(messageId, code);
                      }
                    },
                    showCheckmark: false,
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                    ),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    avatar:
                        isSelected
                            ? Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                            : null,
                  );
                }).toList(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
      ),
    );
  }
}
