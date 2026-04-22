import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/message_language_provider.dart';
import '../../providers/app_locale_provider.dart';
import '../../providers/sync_provider.dart';
import '../../localization/app_strings.dart';
import 'onboarding_screen.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  // Content language selection
  String? _selectedContentLang;
  bool _isLoadingContentLangs = true;

  List<LanguageOption> _supportedContentLanguages = [];

  // Static definition of potential languages to map codes to flags/titles
  static final List<LanguageOption> _allPossibleLanguages = [
    LanguageOption(code: 'ar', nameKey: 'lang_ar', flag: '🇸🇦'),
    LanguageOption(code: 'en', nameKey: 'lang_en', flag: '🇬🇧'),
    LanguageOption(code: 'fr', nameKey: 'lang_fr', flag: '🇫🇷'),
    LanguageOption(code: 'es', nameKey: 'lang_es', flag: '🇪🇸'),
    LanguageOption(code: 'pt', nameKey: 'lang_pt', flag: '🇵🇹'),
    LanguageOption(code: 'de', nameKey: 'lang_de', flag: '🇩🇪'),
    LanguageOption(code: 'ru', nameKey: 'lang_ru', flag: '🇷🇺'),
    LanguageOption(code: 'tr', nameKey: 'lang_tr', flag: '🇹🇷'),
    LanguageOption(code: 'ur', nameKey: 'lang_ur', flag: '🇵🇰'),
    LanguageOption(code: 'fa', nameKey: 'lang_fa', flag: '🇮🇷'),
    LanguageOption(code: 'id', nameKey: 'lang_id', flag: '🇮🇩'),
    LanguageOption(code: 'sw', nameKey: 'lang_sw', flag: '🇹🇿'),
    LanguageOption(code: 'am', nameKey: 'lang_am', flag: '🇪🇹'),
    LanguageOption(code: 'hi', nameKey: 'lang_hi', flag: '🇮🇳'),
    LanguageOption(code: 'tl', nameKey: 'lang_tl', flag: '🇵🇭'),
    LanguageOption(code: 'bn', nameKey: 'lang_bn', flag: '🇧🇩'),
    LanguageOption(code: 'zh', nameKey: 'lang_zh', flag: '🇨🇳'),
  ];

  @override
  void initState() {
    super.initState();
    // Default content language to 'ar' initially
    _selectedContentLang = 'ar';
    _fetchSupportedLanguages();
  }

  Future<void> _fetchSupportedLanguages() async {
    try {
      final service = ref.read(syncServiceProvider);
      // Timeout after 5 seconds to prevent infinite loading
      final codes = await service.getSupportedLanguages().timeout(
        const Duration(seconds: 5),
      );

      if (!mounted) return;

      final List<LanguageOption> loaded = [];
      for (final code in codes) {
        // Find metadata for this code
        final match = _allPossibleLanguages.firstWhere(
          (opt) => opt.code == code,
          orElse: () => LanguageOption(code: code, nameKey: code, flag: '🌐'),
        );
        loaded.add(match);
      }

      // Add Arabic/English if missing (fallback safety)
      if (!loaded.any((l) => l.code == 'ar')) {
        loaded.add(_allPossibleLanguages.firstWhere((l) => l.code == 'ar'));
      }
      if (!loaded.any((l) => l.code == 'en')) {
        loaded.add(_allPossibleLanguages.firstWhere((l) => l.code == 'en'));
      }

      // Sort: Arabic first, then English, then others
      loaded.sort((a, b) {
        if (a.code == 'ar') return -1;
        if (b.code == 'ar') return 1;
        if (a.code == 'en') return -1;
        if (b.code == 'en') return 1;
        return 0;
      });

      setState(() {
        _supportedContentLanguages =
            loaded; // No deduplication needed if logic is sound
        _isLoadingContentLangs = false;
      });
    } catch (e) {
      // Fallback
      if (mounted) {
        setState(() {
          _supportedContentLanguages = [
            _allPossibleLanguages.firstWhere((l) => l.code == 'ar'),
            _allPossibleLanguages.firstWhere((l) => l.code == 'en'),
          ];
          _isLoadingContentLangs = false;
        });
      }
    }
  }

  Future<void> _confirmSelection() async {
    if (_selectedContentLang == null) return;

    // Set the content language
    ref.read(appLanguageProvider.notifier).state = _selectedContentLang!;

    // Save persistence for content language
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('content_language_code', _selectedContentLang!);

    if (!mounted) return;

    // Navigate to Onboarding Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appLocale = ref.watch(appLocaleProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Add a subtle top gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4],
            colors: [
              scheme.primary.withOpacity(0.08),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // --- Header ---
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icon/Islamic_message_app_launcher_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.of(context, 'appTitle'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // --- App Language Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.of(context, 'appLanguage'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Custom Toggle Container
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _AppLangSegment(
                                title: 'English',
                                isSelected: appLocale.languageCode == 'en',
                                onTap:
                                    () => ref
                                        .read(appLocaleProvider.notifier)
                                        .setLocale(const Locale('en')),
                              ),
                            ),
                            Expanded(
                              child: _AppLangSegment(
                                title: 'العربية',
                                isSelected: appLocale.languageCode == 'ar',
                                onTap:
                                    () => ref
                                        .read(appLocaleProvider.notifier)
                                        .setLocale(const Locale('ar')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Content Language Section ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppStrings.of(context, 'contentLanguage'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: AppStrings.of(
                            context,
                            'content_language_desc',
                          ),
                          triggerMode: TooltipTriggerMode.tap,
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: scheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // List of Content Languages
              Expanded(
                child:
                    _isLoadingContentLangs
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _supportedContentLanguages.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final lang = _supportedContentLanguages[index];
                            final isSelected =
                                _selectedContentLang == lang.code;
                            return _ContentLangTile(
                              lang: lang,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedContentLang = lang.code;
                                });
                              },
                            );
                          },
                        ),
              ),

              // Confirm Button Area
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: _confirmSelection,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.of(context, 'confirm_continue'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isRtl
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLangSegment extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppLangSegment({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: isSelected ? scheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title, // ... text style remains similar
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ContentLangTile extends StatelessWidget {
  final LanguageOption lang;
  final bool isSelected;
  final VoidCallback onTap;

  const _ContentLangTile({
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Get localized name using key (or fallback to code/key if missing)
    final localizedName = AppStrings.of(context, lang.nameKey);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? scheme.primaryContainer : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                localizedName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color:
                      isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: scheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String nameKey;
  final String flag;

  LanguageOption({
    required this.code,
    required this.nameKey,
    required this.flag,
  });
}
