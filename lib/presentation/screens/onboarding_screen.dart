import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/language_preference_provider.dart';
import '../../localization/app_strings.dart';
import 'home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
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
                    ? [scheme.surface, scheme.surfaceContainer]
                    : [scheme.surface, scheme.surfaceContainerLowest],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _OnboardingPage(
                  title: AppStrings.of(context, 'onboarding_welcome_title'),
                  description: AppStrings.of(
                    context,
                    'onboarding_welcome_desc',
                  ),
                  icon: Icons.mosque_outlined,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
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
                      elevation: 0,
                    ),
                    child: Text(
                      AppStrings.of(context, 'onboarding_get_started'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adaptive icon size: smaller on short screens
    final iconContainerPadding = screenHeight < 700 ? 28.0 : 40.0;
    final iconSize = screenHeight < 700 ? 80.0 : 100.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Illustration / Icon with decoration
                  Container(
                    padding: EdgeInsets.all(iconContainerPadding),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withOpacity(0.08),
                      border: Border.all(
                        color: scheme.primary.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Icon(icon, size: iconSize, color: scheme.primary),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
