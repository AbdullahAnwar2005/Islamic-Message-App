import 'package:flutter/material.dart';
import '../../localization/app_strings.dart';

/// Language option model for display
class LanguageOption {
  final String code;
  final String nameKey;
  final String flag;
  final bool isAvailable;

  const LanguageOption({
    required this.code,
    required this.nameKey,
    required this.flag,
    this.isAvailable = true,
  });
}

/// Reusable modal bottom sheet for language selection with search
class LanguageSelectorBottomSheet extends StatefulWidget {
  final String currentLanguage;
  final List<String> availableLanguages;
  final ValueChanged<String> onLanguageSelected;
  final String? title;
  final String? subtitle;

  /// Show "Use Default Language" option
  final bool showDefaultOption;

  /// Whether this message has an override (used for showing default option)
  final bool hasOverride;

  /// Callback when user selects to use default language
  final VoidCallback? onClearOverride;

  const LanguageSelectorBottomSheet({
    super.key,
    required this.currentLanguage,
    required this.availableLanguages,
    required this.onLanguageSelected,
    this.title,
    this.subtitle,
    this.showDefaultOption = false,
    this.hasOverride = false,
    this.onClearOverride,
  });

  @override
  State<LanguageSelectorBottomSheet> createState() =>
      _LanguageSelectorBottomSheetState();
}

class _LanguageSelectorBottomSheetState
    extends State<LanguageSelectorBottomSheet> {
  late TextEditingController _searchController;
  late List<LanguageOption> _allLanguages;
  late List<LanguageOption> _filteredLanguages;

  // Comprehensive language metadata
  static const List<LanguageOption> _languageMetadata = [
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
    LanguageOption(code: 'ja', nameKey: 'lang_ja', flag: '🇯🇵'),
    LanguageOption(code: 'ko', nameKey: 'lang_ko', flag: '🇰🇷'),
    LanguageOption(code: 'it', nameKey: 'lang_it', flag: '🇮🇹'),
    LanguageOption(code: 'nl', nameKey: 'lang_nl', flag: '🇳🇱'),
    LanguageOption(code: 'pl', nameKey: 'lang_pl', flag: '🇵🇱'),
    LanguageOption(code: 'vi', nameKey: 'lang_vi', flag: '🇻🇳'),
    LanguageOption(code: 'th', nameKey: 'lang_th', flag: '🇹🇭'),
    LanguageOption(code: 'ms', nameKey: 'lang_ms', flag: '🇲🇾'),
    LanguageOption(code: 'he', nameKey: 'lang_he', flag: '🇮🇱'),
    LanguageOption(code: 'el', nameKey: 'lang_el', flag: '🇬🇷'),
    LanguageOption(code: 'cs', nameKey: 'lang_cs', flag: '🇨🇿'),
    LanguageOption(code: 'ro', nameKey: 'lang_ro', flag: '🇷🇴'),
    LanguageOption(code: 'hu', nameKey: 'lang_hu', flag: '🇭🇺'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _buildLanguageList();
  }

  void _buildLanguageList() {
    _allLanguages =
        widget.availableLanguages.map((code) {
          final metadata = _languageMetadata.firstWhere(
            (lang) => lang.code == code,
            orElse: () => LanguageOption(code: code, nameKey: code, flag: '🌐'),
          );
          return metadata;
        }).toList();

    // Sort: current language first, then Arabic, English, then alphabetically
    _allLanguages.sort((a, b) {
      if (a.code == widget.currentLanguage) return -1;
      if (b.code == widget.currentLanguage) return 1;
      if (a.code == 'ar') return -1;
      if (b.code == 'ar') return 1;
      if (a.code == 'en') return -1;
      if (b.code == 'en') return 1;
      return a.code.compareTo(b.code);
    });

    _filteredLanguages = _allLanguages;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = _allLanguages;
      } else {
        _filteredLanguages =
            _allLanguages.where((lang) {
              final localizedName =
                  AppStrings.of(context, lang.nameKey).toLowerCase();
              final code = lang.code.toLowerCase();
              return localizedName.contains(query) || code.contains(query);
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.75,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language_rounded, color: scheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      widget.title ?? AppStrings.of(context, 'select_language'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      widget.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // "Use Default Language" option (if applicable)
          if (widget.showDefaultOption &&
              widget.hasOverride &&
              widget.onClearOverride != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: InkWell(
                onTap: () {
                  widget.onClearOverride?.call();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.restore_rounded,
                        color: scheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.of(context, 'use_default_language'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.of(context, 'search_language'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.primary, width: 2),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Language list
          Expanded(
            child:
                _filteredLanguages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: scheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.of(context, 'no_language_found'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _filteredLanguages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final lang = _filteredLanguages[index];
                        final isSelected = lang.code == widget.currentLanguage;

                        return InkWell(
                          onTap: () {
                            widget.onLanguageSelected(lang.code);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? scheme.primaryContainer
                                      : scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? scheme.primary
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang.flag,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.of(context, lang.nameKey),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                              color:
                                                  isSelected
                                                      ? scheme
                                                          .onPrimaryContainer
                                                      : scheme.onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lang.code.toUpperCase(),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color:
                                                  isSelected
                                                      ? scheme
                                                          .onPrimaryContainer
                                                          .withOpacity(0.7)
                                                      : scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: scheme.primary,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the language selector
Future<String?> showLanguageSelector({
  required BuildContext context,
  required String currentLanguage,
  required List<String> availableLanguages,
  String? title,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => LanguageSelectorBottomSheet(
          currentLanguage: currentLanguage,
          availableLanguages: availableLanguages,
          onLanguageSelected: (lang) => Navigator.pop(context, lang),
          title: title,
        ),
  );
}
