import 'package:flutter/material.dart';
import '../../localization/app_strings.dart';

class AppDrawer extends StatelessWidget {
  final String appTitle;
  final String? subtitle;
  final String currentLanguageCode; // Content Language
  final Locale currentAppLocale; // App Language
  final List<String> languageOptions;
  final bool isDarkMode;
  final bool isSepiaMode;
  final int bookmarksCount;
  final String? versionLabel;

  // Actions
  final VoidCallback onContinueReading;
  final VoidCallback onOpenBookmarks;
  final VoidCallback onOpenSettings;
  // final VoidCallback onResetContent; // Removed
  final VoidCallback onOpenAbout;
  final VoidCallback onRateApp;
  final VoidCallback onShareApp;
  final VoidCallback? onContactDaiyah;

  final ValueChanged<Locale> onAppLanguageChanged;
  final VoidCallback onToggleThemeCycle;

  const AppDrawer({
    super.key,
    required this.appTitle,
    this.subtitle,
    required this.currentLanguageCode,
    required this.currentAppLocale,
    required this.languageOptions,
    required this.isDarkMode,
    required this.isSepiaMode,
    this.bookmarksCount = 0,
    this.versionLabel,
    required this.onContinueReading,
    required this.onOpenBookmarks,
    required this.onOpenSettings,
    required this.onOpenAbout,
    required this.onRateApp,
    required this.onShareApp,
    required this.onAppLanguageChanged,
    required this.onToggleThemeCycle,
    this.onContactDaiyah,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDark = theme.brightness == Brightness.dark;

    // Header gradient:
    // Light: Brand Color -> Lighter Container
    // Dark: Deep Brand Color -> Dark Surface (to keep White text readable)
    final headerStartColor = isDark ? const Color(0xFF004D40) : cs.primary;
    final headerEndColor =
        isDark ? const Color(0xFF00251A) : cs.primaryContainer;

    return Drawer(
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Custom Modern Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [headerStartColor, headerEndColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 32,
                      // Access primary color safely, in dark mode force the teal if needed
                      color: isDark ? const Color(0xFF004D40) : cs.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(context, 'appTitle'),
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.of(context, 'ready_offline'),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Drawer Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                _DrawerItem(
                  icon: Icons.history_edu_rounded,
                  label: AppStrings.of(context, 'drawer_continue'),
                  onTap: onContinueReading,
                  highlighted: true,
                ),

                const SizedBox(height: 4),

                _DrawerItem(
                  icon: Icons.bookmark_rounded,
                  label: AppStrings.of(context, 'drawer_bookmarks'),
                  onTap: onOpenBookmarks,
                  badge: bookmarksCount > 0 ? bookmarksCount.toString() : null,
                ),

                const SizedBox(height: 4),

                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: AppStrings.of(context, 'settings'),
                  onTap: onOpenSettings,
                ),

                const SizedBox(height: 16),
                const Divider(indent: 16, endIndent: 16, height: 1),
                const SizedBox(height: 16),

                _SectionHeader(
                  title: AppStrings.of(context, 'about_app_header'),
                ),
                _DrawerItem(
                  icon: Icons.share_rounded,
                  label: AppStrings.of(context, 'drawer_share'),
                  onTap: onShareApp,
                ),
                // Removed duplicate "تواصل مع داعية" - it's already a quick action on Home
                _DrawerItem(
                  icon: Icons.rate_review_rounded,
                  label: AppStrings.of(context, 'drawer_rate'),
                  onTap: onRateApp,
                ),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: AppStrings.of(context, 'drawer_about'),
                  onTap: onOpenAbout,
                ),

                if (versionLabel != null) ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      '${AppStrings.of(context, 'version')} $versionLabel',
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.badge,
    this.trailing,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badge;
  final Widget? trailing;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor:
            highlighted
                ? cs.primary.withOpacity(0.12)
                : null, // Easier on eyes than primaryContainer sometimes
        onTap: onTap,
        leading: Icon(
          icon,
          color: highlighted ? cs.primary : cs.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            color: highlighted ? cs.primary : cs.onSurface,
          ),
        ),
        trailing:
            trailing ??
            (badge != null
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : null),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
