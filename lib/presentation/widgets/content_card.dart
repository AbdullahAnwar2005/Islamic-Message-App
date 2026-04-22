// lib/presentation/widgets/content_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/app_strings.dart';
import 'language_selector_bottom_sheet.dart';

import '../../core/app_colors.dart';

import '../screens/audio_player_screen.dart';

class ContentCard extends ConsumerWidget {
  final int messageId;
  final String title;
  final String content;
  final String langCode;
  final String? titleLangCode;
  final String? audioUrl;
  final ValueChanged<String?> onChangeLanguage;
  final List<String> languageOptions;
  final VoidCallback onRead;

  /// Controls showing the language chips (hide when only one language)
  final bool showLanguageButton;

  /// Optional width for horizontal scrolling
  final double? width;

  /// Whether this message has a language override
  final bool hasOverride;

  /// Callback to clear the language override for this message
  final VoidCallback? onClearOverride;

  const ContentCard({
    super.key,
    required this.messageId,
    required this.title,
    required this.content,
    required this.langCode,
    this.titleLangCode,
    required this.audioUrl,
    required this.onChangeLanguage,
    required this.languageOptions,
    required this.onRead,
    this.showLanguageButton = true,
    this.width,
    this.hasOverride = false,
    this.onClearOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final cardBorder = BorderSide(
      color:
          theme.brightness == Brightness.light
              ? AppColors.lightCardBoarder
              : scheme.outlineVariant,
      width: 2.0,
    );

    return Container(
      width: width,
      child: Card(
        color: theme.cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(
          side: cardBorder,
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language selector button at top
              if (showLanguageButton && languageOptions.length > 1)
                _buildLanguageSelector(context, scheme),

              if (showLanguageButton && languageOptions.length > 1)
                const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // Increased from 18 to 22
                ),
                textDirection:
                    _isRtl(titleLangCode ?? langCode)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                _extractDescription(content),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 15, // Slightly larger than default (usually 14)
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textDirection:
                    _isRtl(langCode) ? TextDirection.rtl : TextDirection.ltr,
              ),

              const SizedBox(height: 16),

              // Action buttons row
              Row(
                children: [
                  // Listen button (secondary action)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.headphones_outlined,
                      label: AppStrings.of(context, 'listen'),
                      isEnabled: audioUrl != null && audioUrl!.isNotEmpty,
                      onTap: () {
                        if (audioUrl != null && audioUrl!.isNotEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      AudioPlayerScreen(messageId: messageId),
                            ),
                          );
                        } else {
                          // Show audio unavailable dialog
                          _showAudioUnavailableDialog(context);
                        }
                      },
                      onDisabledTap: () => _showAudioUnavailableDialog(context),
                      isPrimary: false,
                      scheme: scheme,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Read button
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.menu_book_outlined,
                      label: AppStrings.of(context, 'read'),
                      isEnabled: true,
                      onTap: onRead,
                      isPrimary: true,
                      scheme: scheme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, ColorScheme scheme) {
    return InkWell(
      onTap: () async {
        await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => LanguageSelectorBottomSheet(
                currentLanguage: langCode,
                availableLanguages: languageOptions,
                onLanguageSelected: onChangeLanguage,
                title: AppStrings.of(context, 'language_picker_title'),
                subtitle: AppStrings.of(context, 'language_picker_subtitle'),
                showDefaultOption: true,
                hasOverride: hasOverride,
                onClearOverride: onClearOverride,
              ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.outline.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded, size: 16, color: scheme.primary),
            const SizedBox(width: 6),
            Text(
              AppStrings.of(context, 'lang_$langCode'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            // Show "Custom" badge when override exists
            if (hasOverride) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppStrings.of(context, 'custom_override_badge'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: scheme.tertiary,
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  bool _isRtl(String code) =>
      const {'ar', 'ur', 'fa', 'he'}.contains(code.toLowerCase());

  void _showAudioUnavailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(AppStrings.of(context, 'audio_unavailable_label')),
            content: Text(
              languageOptions.length > 1
                  ? AppStrings.of(context, 'audio_unavailable_label')
                  : AppStrings.of(context, 'no_audio_source'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppStrings.of(context, 'dialog_ok')),
              ),
              if (languageOptions.length > 1)
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => LanguageSelectorBottomSheet(
                            currentLanguage: langCode,
                            availableLanguages: languageOptions,
                            onLanguageSelected: onChangeLanguage,
                          ),
                    );
                  },
                  child: Text(AppStrings.of(context, 'change_language_action')),
                ),
            ],
          ),
    );
  }

  String _extractDescription(String fullText) {
    final lines = fullText.split('\n');
    bool seenTitle = false;
    final b = StringBuffer();
    for (final raw in lines) {
      var l = raw.trim();
      if (l.startsWith('##')) {
        seenTitle = true;
        continue;
      }
      if (seenTitle && l.isNotEmpty) {
        // Strip leading bullets while preserving valid punctuation
        l = l.replaceFirst(RegExp(r'^[•\*\-–—]\s*'), '');
        b.writeln(l);
        if (b.length > 200) break;
      }
    }
    return b.toString().trim();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final ColorScheme scheme;
  final bool isEnabled;
  final VoidCallback? onDisabledTap; // Called when tapping disabled button

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.scheme,
    this.isEnabled = true,
    this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    // If disabled, use disabled colors
    final fgColor =
        isEnabled
            ? (isPrimary ? scheme.onPrimary : scheme.onSurface)
            : scheme.onSurface.withOpacity(0.38);

    final bgColor =
        isEnabled
            ? (isPrimary ? scheme.primary : Colors.transparent)
            : (isPrimary
                ? scheme.onSurface.withOpacity(0.12)
                : Colors.transparent);

    final borderColor =
        isEnabled
            ? scheme.outline.withOpacity(0.5)
            : scheme.outline.withOpacity(0.2);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isEnabled ? onTap : onDisabledTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                isPrimary ? null : Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: fgColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
