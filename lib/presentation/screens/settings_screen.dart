import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localization/app_strings.dart';
import '../../providers/theme_provider.dart';
import '../../providers/app_locale_provider.dart';
import '../../providers/app_version_provider.dart';
import '../../providers/message_language_provider.dart'
    show defaultContentLanguageProvider;
import '../widgets/language_selector_bottom_sheet.dart';

/// Consolidated settings screen with all app preferences
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // Available content languages
  static const List<String> _contentLanguages = [
    'ar',
    'en',
    'fr',
    'ur',
    'fa',
    'id',
    'sw',
    'am',
    'hi',
    'tl',
    'bn',
    'tr',
    'ru',
    'zh',
    'es',
    'pt',
    'de',
    'ja',
    'ko',
    'it',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeMode = ref.watch(themeProvider);
    final appLocale = ref.watch(appLocaleProvider);
    final defaultContentLang = ref.watch(defaultContentLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Language Section
          _SectionHeader(title: AppStrings.of(context, 'language_settings')),

          // App Language (UI Language)
          _SettingsTile(
            icon: Icons.language_rounded,
            title: AppStrings.of(context, 'appLanguage'),
            trailing: DropdownButton<Locale>(
              value: appLocale,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down_rounded),
              isDense: true,
              onChanged: (newLocale) {
                if (newLocale != null) {
                  ref.read(appLocaleProvider.notifier).setLocale(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
              ],
            ),
          ),

          // Default Content Language
          _SettingsTile(
            icon: Icons.translate_rounded,
            title: AppStrings.of(context, 'default_content_language'),
            subtitle:
                defaultContentLang != null
                    ? AppStrings.of(context, 'lang_$defaultContentLang')
                    : AppStrings.of(context, 'not_set'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (ctx) => LanguageSelectorBottomSheet(
                      currentLanguage: defaultContentLang ?? 'ar',
                      availableLanguages: _contentLanguages,
                      onLanguageSelected: (lang) {
                        ref
                            .read(defaultContentLanguageProvider.notifier)
                            .setDefault(lang);
                      },
                      title: AppStrings.of(context, 'default_content_language'),
                    ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _SectionHeader(title: AppStrings.of(context, 'appearance_title')),

          // Theme Switchers
          SwitchListTile(
            secondary: Icon(
              Icons.brightness_auto_rounded,
              color: scheme.primary,
            ),
            title: Text(AppStrings.of(context, 'theme_system')),
            subtitle: Text(AppStrings.of(context, 'dark_mode_subtitle')),
            value: themeMode == ThemeMode.system,
            onChanged: (isSystem) {
              if (isSystem) {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
              } else {
                final platformBrightness = MediaQuery.platformBrightnessOf(
                  context,
                );
                ref
                    .read(themeProvider.notifier)
                    .setTheme(
                      platformBrightness == Brightness.dark
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    );
              }
            },
            activeColor: scheme.primary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          ),

          if (themeMode != ThemeMode.system)
            SwitchListTile(
              secondary: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: scheme.primary,
              ),
              title: Text(AppStrings.of(context, 'drawer_dark_mode')),
              value: themeMode == ThemeMode.dark,
              onChanged: (isDark) {
                ref
                    .read(themeProvider.notifier)
                    .setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
              },
              activeColor: scheme.primary,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
            ),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: AppStrings.of(context, 'about_app_header')),

          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: AppStrings.of(context, 'drawer_about'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppStrings.of(context, 'about_app_name'),
                // TRUST-03: real version from package_info_plus
                applicationVersion:
                    ref.read(appVersionProvider).valueOrNull ?? '—',
                applicationIcon: const Icon(
                  Icons.auto_stories_rounded,
                  size: 48,
                ),
                applicationLegalese: AppStrings.of(context, 'about_legalese'),
              );
            },
          ),

          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.of(context, 'drawer_privacy'),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text(AppStrings.of(context, 'dialog_privacy')),
                      content: SingleChildScrollView(
                        child: Text(
                          AppStrings.of(context, 'privacy_policy_content'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(AppStrings.of(context, 'dialog_ok')),
                        ),
                      ],
                    ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Version label - from single source of truth
          Consumer(
            builder: (context, ref, _) {
              final versionAsync = ref.watch(appVersionProvider);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${AppStrings.of(context, 'version')} ${versionAsync.valueOrNull ?? '...'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withOpacity(0.6),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
