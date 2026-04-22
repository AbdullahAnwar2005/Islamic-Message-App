import 'package:flutter/material.dart';
import '../../utils/arabic_language_names.dart';
import '../../localization/app_strings.dart';

/// Production-ready settings sheet for audio playback speed and language.
///
/// Changes:
/// - Removed progress reset options.
/// - Added proper scrolling to prevent overflow.
/// - Used 'arabicLanguageName' for proper display.
/// - Ensures immediate UI feedback for speed/language selection.
/// - Follows Material 3 styling.
/// - FIXED: Removed DraggableScrollableSheet wrapper (handled by showModalBottomSheet)
class AudioSettingsSheet extends StatefulWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;
  final String currentLanguage;
  final List<String> availableLanguages;
  final ValueChanged<String> onLanguageChanged;
  final bool isDownloading;
  final String? downloadingLanguage;

  const AudioSettingsSheet({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
    required this.currentLanguage,
    required this.availableLanguages,
    required this.onLanguageChanged,
    this.isDownloading = false,
    this.downloadingLanguage,
  });

  @override
  State<AudioSettingsSheet> createState() => _AudioSettingsSheetState();
}

class _AudioSettingsSheetState extends State<AudioSettingsSheet> {
  // 0.5 can be added back if product requests it
  static const List<double> _speedOptions = [0.75, 1.0, 1.25, 1.5, 2.0];

  // Local state to support optimistic UI updates
  late double _selectedSpeed;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.currentSpeed;
    _selectedLanguage = widget.currentLanguage;
  }

  @override
  void didUpdateWidget(covariant AudioSettingsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSpeed != widget.currentSpeed) {
      _selectedSpeed = widget.currentSpeed;
    }
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _selectedLanguage = widget.currentLanguage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Use AppStrings or fallback
    final title = AppStrings.of(context, 'settings_label') ?? 'إعدادات الصوت';
    final speedLabel =
        'سرعة التشغيل'; // Localized ideally, hardcoded per context
    final langLabel = 'لغة الصوت'; // Localized ideally

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for modal bottom sheet
          children: [
            // 1. Drag Handle
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 2. Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ),

            // 3. Content (Scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SPEED SECTION ---
                    Text(
                      speedLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSpeedGrid(scheme),
                    const SizedBox(height: 32),

                    // --- LANGUAGE SECTION ---
                    Text(
                      langLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Downloading Indicator
                    if (widget.isDownloading &&
                        widget.downloadingLanguage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 0,
                          color: scheme.primaryContainer.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'جاري تحميل ${arabicLanguageName(widget.downloadingLanguage!)}...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Language List
                    ...widget.availableLanguages.map(
                      (lang) => _buildLanguageTile(
                        lang,
                        _selectedLanguage == lang,
                        scheme,
                        theme,
                      ),
                    ),

                    // Extra bottom padding for safety
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedGrid(ColorScheme scheme) {
    return Wrap(
      spacing: 12, // Consistent M3 spacing
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children:
          _speedOptions.map((speed) {
            final isSelected = (_selectedSpeed - speed).abs() < 0.01;
            return InkWell(
              onTap: () {
                setState(
                  () => _selectedSpeed = speed,
                ); // Immediate visual feedback
                widget.onSpeedChanged(speed);
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? scheme.secondaryContainer
                          : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? scheme.outline : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${speed}x',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color:
                        isSelected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildLanguageTile(
    String code,
    bool isSelected,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color:
            isSelected
                ? scheme.secondaryContainer.withOpacity(0.4)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              setState(() => _selectedLanguage = code); // Immediate feedback
              widget.onLanguageChanged(code);
              // Keep open as requested/default behavior
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Radio Icon
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: 16),

                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arabicLanguageName(code),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: scheme.onSurface,
                        ),
                      ),
                      // Optional: Code subtitle
                      Text(
                        code.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark (redundant with radio but requested "check/radio")
                if (isSelected)
                  Icon(Icons.check, color: scheme.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
