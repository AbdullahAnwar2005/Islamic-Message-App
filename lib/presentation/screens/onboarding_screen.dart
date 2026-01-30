import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../providers/language_preference_provider.dart';
import '../../localization/app_strings.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Mark the user as having completed the language/onboarding flow
    await ref
        .read(languageSelectionNotifierProvider.notifier)
        .markAsCompleted();

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Define pages dynamically inside build to access context for localization
    final List<OnboardingPageModel> pages = [
      OnboardingPageModel(
        title: AppStrings.of(context, 'onboarding_welcome_title'),
        description: AppStrings.of(context, 'onboarding_welcome_desc'),
        icon: Icons.mosque_outlined,
      ),
      OnboardingPageModel(
        title: AppStrings.of(context, 'onboarding_language_title'),
        description: AppStrings.of(context, 'onboarding_language_desc'),
        icon: Icons.translate_rounded,
      ),
      OnboardingPageModel(
        title: AppStrings.of(context, 'onboarding_audio_title'),
        description: AppStrings.of(context, 'onboarding_audio_desc'),
        icon: Icons.headphones_outlined,
      ),
    ];

    // Adjust gradient based on theme brightness
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [
                      scheme.surface,
                      scheme
                          .surfaceContainer, // Darker/Lighter depending on material 3
                    ]
                    : [
                      scheme.surface,
                      scheme.surfaceContainerLowest, // Lighter for light mode
                    ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.secondary,
                    ),
                    child: Text(
                      AppStrings.of(context, 'onboarding_skip'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _isLastPage = index == pages.length - 1;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _OnboardingPage(page: pages[index]);
                  },
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: pages.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        activeDotColor: scheme.primary,
                        dotColor: scheme.primary.withOpacity(0.2),
                      ),
                      // TextDirection handling for indicator if needed,
                      // mostly auto-handled or we can explicitly set it.
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                    ),

                    // Next / Get Started Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child:
                          _isLastPage
                              ? FilledButton(
                                onPressed: _completeOnboarding,
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  elevation: 4,
                                  shadowColor: scheme.primary.withOpacity(0.4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStrings.of(
                                        context,
                                        'onboarding_get_started',
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Auto-mirrored icon for RTL
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              )
                              : FloatingActionButton(
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                elevation: 2,
                                backgroundColor: scheme.primaryContainer,
                                foregroundColor: scheme.onPrimaryContainer,
                                shape: const CircleBorder(),
                                child: const Icon(Icons.arrow_forward_rounded),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageModel page;

  const _OnboardingPage({required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration / Icon with decoration
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withOpacity(0.08),
              border: Border.all(
                color: scheme.primary.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Icon(page.icon, size: 100, color: scheme.primary),
          ),

          const SizedBox(height: 56),

          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant.withOpacity(0.8),
              height: 1.6,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPageModel {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.icon,
  });
}
