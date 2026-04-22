// lib/presentation/screens/home_screen.dart
import 'read_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// DB (brings Message type). We hide MessageWithTranslations (it comes from provider).
import '../../data/local/app_database.dart' hide MessageWithTranslations;

// Theme / Sync
import '../../providers/theme_provider.dart';
import '../../providers/sync_provider.dart'
    show
        syncServiceProvider,
        syncInFlightProvider,
        syncStatusProvider,
        SyncStatus;
import '../../providers/app_version_provider.dart';
import '../../features/reader/providers/bookmarks_provider.dart';
import 'package:share_plus/share_plus.dart';

// Language state (global + per-message override + default content language)
import '../../providers/message_language_provider.dart'
    show
        appLanguageProvider,
        messageLangOverridesProvider,
        defaultContentLanguageProvider;

// Messages + translations bundle
import '../../providers/message_provider.dart'
    show
        messagesWithTranslationsProvider,
        homeSectionsProvider,
        SectionWithMessages;

// Language list for popup (optional; has fallback)
import '../../providers/language_options_provider.dart'
    show availableLanguagesProvider;

// Utilities
import '../../utils/choose_translation_utility.dart' show pickTranslation, norm;

import '../../core/feedback_utils.dart';
import '../../providers/app_locale_provider.dart';
import '../../localization/app_strings.dart';

// Reader models + mapper + screen

// UI
import '../widgets/content_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/feature_card.dart';

import 'contact_us_screen.dart';
import '../../features/reader/services/last_read_service.dart';
import 'global_bookmarks_screen.dart';
import 'settings_screen.dart';

// ✅ Import Mock Seeder removed

/// Holds the ID of the currently selected section.
final _selectedSectionProvider = StateProvider.autoDispose<int?>((ref) => null);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(syncStatusProvider, (prev, next) {
      if (next == SyncStatus.failed && prev != SyncStatus.failed) {
        showTopSnackBar(
          context,
          AppStrings.of(context, 'offline_first_run_banner'),
          isError: true,
        );
      }
    });

    final themeMode = ref.watch(themeProvider);
    final bundles = ref.watch(messagesWithTranslationsProvider);
    final langsAsync = ref.watch(availableLanguagesProvider);

    final globalLang = ref.watch(appLanguageProvider);
    final appLocale = ref.watch(appLocaleProvider);
    final overrides = ref.watch(messageLangOverridesProvider);

    // نحدّد خيارات اللغات للدرج (إن لم تأتِ من المزود، نضع افتراضًا)
    List<String> drawerLanguageOptions = const ['ar', 'en', 'fr'];
    langsAsync.whenData((opts) {
      if (opts.isNotEmpty) drawerLanguageOptions = opts;
    });

    // Auto-sync is now handled in main._triggerBackgroundSync (START-01).
    // No longer needed here.

    final sectionsAsync = ref.watch(homeSectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'appTitle')),
        centerTitle: true,
      ),

      drawer: AppDrawer(
        appTitle: AppStrings.of(context, 'appTitle'),
        subtitle: AppStrings.of(context, 'ready_offline'),
        currentLanguageCode: globalLang,
        currentAppLocale: appLocale,
        onAppLanguageChanged: (locale) {
          ref.read(appLocaleProvider.notifier).setLocale(locale);
        },
        languageOptions: drawerLanguageOptions,
        isDarkMode: themeMode == ThemeMode.dark,
        isSepiaMode: false,
        // TRUST-05: live bookmark count from provider
        bookmarksCount:
            ref.watch(bookmarksProvider).values.expand((b) => b).length,
        // TRUST-03: version from package_info, not hardcoded
        versionLabel: ref.watch(appVersionProvider).valueOrNull,

        onContinueReading: () async {
          final last = await ref.read(lastReadServiceProvider).get();
          if (context.mounted) {
            if (last != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ReadScreen(
                        messageId: last.messageId,
                        initialChapterIndex: last.chapterIndex,
                      ),
                ),
              );
            } else {
              showTopSnackBar(
                context,
                AppStrings.of(context, 'no_read_history'),
              );
            }
          }
        },

        onOpenBookmarks: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GlobalBookmarksScreen()),
          );
        },

        onOpenSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },

        // onResetContent removed
        onOpenAbout: () {
          showAboutDialog(
            context: context,
            applicationName: AppStrings.of(context, 'about_app_name'),
            // TRUST-03: use real version from package_info_plus
            applicationVersion: ref.read(appVersionProvider).valueOrNull ?? '—',
            applicationIcon: const Icon(Icons.auto_stories_rounded, size: 48),
            applicationLegalese: AppStrings.of(context, 'about_legalese'),
          );
        },
        onContactDaiyah: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactUsScreen()),
          );
        },
        onRateApp: () async {
          final uri = Uri.parse(
            'market://details?id=com.alghaya.islamicmessage',
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            // Fallback to web
            final web = Uri.parse(
              'https://play.google.com/store/apps/details?id=com.alghaya.islamicmessage',
            );
            if (await canLaunchUrl(web)) await launchUrl(web);
          }
        },
        // TRUST-02: real share — localized text only; no placeholder store URL.
        // When AppConfig.playStoreId is confirmed, append it to the shareText.
        onShareApp: () {
          final shareText = AppStrings.of(context, 'share_app_message');
          SharePlus.instance.share(ShareParams(text: shareText));
        },
        onToggleThemeCycle: () {
          final next =
              themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
          ref.read(themeProvider.notifier).setTheme(next);
        },
      ),

      body: sectionsAsync.when(
        loading:
            () => const _CenteredScrollable(child: CircularProgressIndicator()),
        error: (err, stack) {
          debugPrint('🔥 homeSectionsProvider error: $err\n$stack');
          return _ErrorScrollable(
            message: '⚠️ ${AppStrings.of(context, 'loading_error')}',
            onRetry: () => ref.invalidate(homeSectionsProvider),
          );
        },
        data: (sections) {
          // START-01: 3-state first-run handling.
          // (a) Skeleton: DB empty + sync in flight
          // (b) Offline/retry: DB empty + not syncing
          // (c) Normal: has sections data
          final syncInFlight = ref.watch(syncInFlightProvider);

          if (sections.isEmpty) {
            if (syncInFlight) {
              // State (a): show full-screen skeleton loading
              return _HomeSyncingState(
                message: AppStrings.of(context, 'home_loading_content'),
              );
            } else {
              // State (b): offline/error — show actionable retry
              return _HomeOfflineState(
                title: AppStrings.of(context, 'offline_first_run_title'),
                body: AppStrings.of(context, 'offline_first_run_body'),
                retryLabel: AppStrings.of(context, 'retry'),
                onRetry: () {
                  // Re-trigger the sync via syncServiceProvider
                  ref.read(syncInFlightProvider.notifier).state = true;
                  ref
                      .read(syncServiceProvider)
                      .run(initial: true)
                      .then((_) {
                        ref.invalidate(homeSectionsProvider);
                      })
                      .whenComplete(() {
                        ref.read(syncInFlightProvider.notifier).state = false;
                      });
                },
              );
            }
          }

          return langsAsync.when(
            loading:
                () => _SectionsList(
                  sections: sections,
                  globalLang: globalLang,
                  overrides: overrides,
                  languageOptions: const ['ar', 'en', 'fr'],
                ),
            error:
                (_, __) => _SectionsList(
                  sections: sections,
                  globalLang: globalLang,
                  overrides: overrides,
                  languageOptions: const ['ar', 'en', 'fr'],
                ),
            data:
                (options) => _SectionsList(
                  sections: sections,
                  globalLang: globalLang,
                  overrides: overrides,
                  languageOptions: options,
                ),
          );
        },
      ),
    );
  }
}

class _SectionsList extends ConsumerWidget {
  const _SectionsList({
    required this.sections,
    required this.globalLang,
    required this.overrides,
    required this.languageOptions,
  });

  final List<SectionWithMessages> sections;
  final String globalLang;
  final Map<int, String> overrides;
  final List<String> languageOptions;

  String _resolveSectionTitle(BuildContext context, Section section) {
    final key = 'section_${section.slug}';
    final localized = AppStrings.of(context, key);
    // If localization is missing (returns key), fallback to DB title
    if (localized == key) return section.title;
    return localized;
  }

  String _resolveTitle(
    BuildContext context,
    Message msg,
    Translation? tr,
    String uiLang,
    String contentLang,
  ) {
    // 1. Priority: Match the UI language (App Locale)
    // This ensures that the list feels localized to the app's interface.
    if (uiLang == 'ar' &&
        msg.displayTitleAr != null &&
        msg.displayTitleAr!.isNotEmpty) {
      return msg.displayTitleAr!;
    }
    if (uiLang == 'en' &&
        msg.displayTitleEn != null &&
        msg.displayTitleEn!.isNotEmpty) {
      return msg.displayTitleEn!;
    }

    // 2. Priority: Match the Content Language (if different from UI)
    if (contentLang == 'ar' &&
        msg.displayTitleAr != null &&
        msg.displayTitleAr!.isNotEmpty) {
      return msg.displayTitleAr!;
    }
    if (contentLang == 'en' &&
        msg.displayTitleEn != null &&
        msg.displayTitleEn!.isNotEmpty) {
      return msg.displayTitleEn!;
    }

    // 3. Fallback: Translation title
    if (tr != null && tr.displayTitle.isNotEmpty) {
      return tr.displayTitle;
    }

    // 4. Ultimate fallback
    if (msg.displayTitleAr != null && msg.displayTitleAr!.isNotEmpty)
      return msg.displayTitleAr!;
    if (msg.displayTitleEn != null && msg.displayTitleEn!.isNotEmpty)
      return msg.displayTitleEn!;

    return msg.displayTitle;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sections.isEmpty) {
      return Center(child: Text(AppStrings.of(context, 'no_content')));
    }

    // Capture the current UI locale for title resolution
    final appLocale = ref.watch(appLocaleProvider);
    final uiLang = appLocale.languageCode;

    // 1. Determine selected section
    final selectedId = ref.watch(_selectedSectionProvider);
    // If selectedId is null, it means "All"

    return CustomScrollView(
      slivers: [
        // Header
        const SliverToBoxAdapter(child: _HomeHeader()),

        // Filter Chips - Improved touch targets and scrolling
        SliverToBoxAdapter(
          child: SizedBox(
            height: 56, // Extra height for comfortable touch
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              // +1 for "All"
              itemCount: sections.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                // "All" Tab
                if (index == 0) {
                  final isSelected = selectedId == null;
                  final colorScheme = Theme.of(context).colorScheme;

                  return Center(
                    child: SizedBox(
                      height: 48, // Explicit 48dp touch target
                      child: FilterChip(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        label: Text(
                          AppStrings.of(context, 'all'),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          ref.read(_selectedSectionProvider.notifier).state =
                              null;
                        },
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        selectedColor: colorScheme.primary,
                        checkmarkColor: colorScheme.onPrimary,
                        showCheckmark: false,
                        side:
                            isSelected
                                ? BorderSide.none
                                : BorderSide(
                                  color: colorScheme.outline.withOpacity(0.3),
                                ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  );
                }

                final section = sections[index - 1].section;
                final isSelected = section.id == selectedId;
                final colorScheme = Theme.of(context).colorScheme;

                return Center(
                  child: SizedBox(
                    height: 48, // Explicit 48dp touch target
                    child: FilterChip(
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      label: Text(
                        _resolveSectionTitle(context, section),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(_selectedSectionProvider.notifier).state =
                            section.id;
                      },
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      selectedColor: colorScheme.primary,
                      checkmarkColor: colorScheme.onPrimary,
                      showCheckmark: false,
                      side:
                          isSelected
                              ? BorderSide.none
                              : BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Content
        if (selectedId == null)
          // Show ALL sections
          ...sections.map((sectionData) {
            final section = sectionData.section;
            final items = sectionData.items;
            if (items.isEmpty) return const SliverToBoxAdapter();

            return SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      _resolveSectionTitle(context, section),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildMessageItem(
                      context,
                      ref,
                      items[index],
                      overrides,
                      globalLang,
                      uiLang,
                    ),
                    childCount: items.length,
                  ),
                ),
              ],
            );
          })
        else
          // Show SELECTED section only
          () {
            final activeData = sections.firstWhere(
              (s) => s.section.id == selectedId,
              orElse: () => sections.first,
            );
            final items = activeData.items;

            if (items.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(AppStrings.of(context, 'empty_section')),
                  ),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMessageItem(
                  context,
                  ref,
                  items[index],
                  overrides,
                  globalLang,
                  uiLang,
                ),
                childCount: items.length,
              ),
            );
          }(),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    WidgetRef ref,
    dynamic bundle, // MessageWithTranslations
    Map<int, String> overrides,
    String globalLang,
    String uiLang,
  ) {
    final Message msg = bundle.message;
    final trs = bundle.translations;
    final opts = _optionsFor(trs);

    if (opts.isEmpty) return const SizedBox.shrink();

    // Check if this message has a specific override
    final hasOverride = overrides.containsKey(msg.id);

    // Resolution order: override → default content language → app locale → fallback
    String langForThis = overrides[msg.id] ?? '';
    if (langForThis.isEmpty || !opts.contains(langForThis)) {
      final defaultLang = ref.read(defaultContentLanguageProvider);
      if (defaultLang != null && opts.contains(defaultLang)) {
        langForThis = defaultLang;
      } else if (opts.contains(globalLang)) {
        langForThis = globalLang;
      } else {
        langForThis = _bestPreferred(opts);
      }
    }

    final tr = pickTranslation(
      trs,
      langForThis,
      fallback: _bestPreferred(opts),
    );

    VoidCallback? onRead;
    if (tr != null) {
      onRead = () {
        ref
            .read(messageLangOverridesProvider.notifier)
            .setOverride(msg.id, langForThis);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReadScreen(messageId: msg.id)),
        );
      };
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ContentCard(
        key: ValueKey<int>(msg.id),
        messageId: msg.id,
        title: _resolveTitle(context, msg, tr, uiLang, globalLang),
        content: tr?.content ?? '',
        langCode: langForThis,
        titleLangCode: uiLang,
        audioUrl: tr?.audioUrl,
        hasOverride: hasOverride,
        onRead:
            onRead ??
            () {
              showTopSnackBar(
                context,
                AppStrings.of(context, 'no_translation'),
                isError: true,
              );
            },
        onChangeLanguage:
            (code) => ref
                .read(messageLangOverridesProvider.notifier)
                .setOverride(msg.id, code ?? langForThis),
        onClearOverride:
            hasOverride
                ? () => ref
                    .read(messageLangOverridesProvider.notifier)
                    .clearOverride(msg.id)
                : null,
        languageOptions: opts,
        showLanguageButton: opts.length > 1,
      ),
    );
  }
}

// Keep only ONE copy of these helpers in the file
List<String> _optionsFor(List<dynamic> translations) {
  final set = <String>{};
  for (final t in translations) {
    set.add(norm((t as dynamic).languageCode as String));
  }
  final options = set.toList();

  const preferred = ['ar', 'en', 'fr', 'ur', 'fa', 'id'];
  int rank(String c) {
    final i = preferred.indexOf(c);
    return i == -1 ? 999 : i;
  }

  options.sort((a, b) => rank(a).compareTo(rank(b)));
  return options;
}

String _bestPreferred(List<String> opts) {
  const preferred = ['ar', 'en', 'fr', 'ur', 'fa', 'id'];
  for (final p in preferred) {
    if (opts.contains(p)) return p;
  }
  return opts.isNotEmpty ? opts.first : 'en';
}

class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 160),
        Center(child: child),
        const SizedBox(height: 400),
      ],
    );
  }
}

class _ErrorScrollable extends StatelessWidget {
  const _ErrorScrollable({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 160),
        Center(
          child: Column(
            children: [
              Text(message),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppStrings.of(context, 'retry')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 400),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions Section Header
          Text(
            AppStrings.of(context, 'quick_actions_header'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          FeatureCard(
            title: AppStrings.of(context, 'contact_daiyah'),
            subtitle: AppStrings.of(context, 'daiyah_desc'),
            icon: Icons.support_agent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          // Content Section Header - Simple, no heavy dividers
          Text(
            AppStrings.of(context, 'content_header'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// START-01: State (a) — Skeleton shown while first-run sync is in flight.
// Full-screen experience with animated shimmer cards + status message.
// ----------------------------------------------------------------------------
class _HomeSyncingState extends StatelessWidget {
  final String message;
  const _HomeSyncingState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Shimmer-style placeholder cards
              for (int i = 0; i < 3; i++) _SkeletonCard(theme: theme),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final ThemeData theme;
  const _SkeletonCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = theme.colorScheme.surfaceContainerHighest;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        color: shimmerColor,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// START-01: State (b) — Offline/timeout state with prominent Retry button.
// ----------------------------------------------------------------------------
class _HomeOfflineState extends StatelessWidget {
  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;

  const _HomeOfflineState({
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
