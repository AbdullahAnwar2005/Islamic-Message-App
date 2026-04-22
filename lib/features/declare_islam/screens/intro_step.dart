import 'package:alghaya_men_alkhalg/presentation/screens/contact_us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/app_strings.dart';
import '../providers/declare_islam_provider.dart';
import '../../../../providers/analytics_provider.dart';

class IntroStepWidget extends ConsumerStatefulWidget {
  const IntroStepWidget({super.key});

  @override
  ConsumerState<IntroStepWidget> createState() => _IntroStepWidgetState();
}

class _IntroStepWidgetState extends ConsumerState<IntroStepWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).track('shahada_view');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.of(context, 'welcome_header'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildSection(
            context,
            title: AppStrings.of(context, 'di_intro_meaning_title'),
            body: AppStrings.of(context, 'di_intro_meaning_body'),
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: AppStrings.of(context, 'di_intro_note_title'),
            body: AppStrings.of(context, 'di_intro_note_body'),
            icon: Icons.info_outline,
            isWarning: true,
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () {
              ref
                  .read(analyticsServiceProvider)
                  .track(
                    'shahada_step_complete',
                    properties: {'step_index': 0},
                  );
              ref
                  .read(declareIslamProvider.notifier)
                  .goToStep(DeclareIslamStep.learn);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              AppStrings.of(context, 'di_intro_btn_start'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(AppStrings.of(context, 'di_intro_btn_questions')),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String body,
    required IconData icon,
    bool isWarning = false,
  }) {
    final color =
        isWarning ? Colors.amber[900] : Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.amber[50] : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? Colors.amber.withOpacity(0.5) : Colors.transparent,
        ),
        boxShadow:
            isWarning
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(height: 1.5, fontSize: 15)),
        ],
      ),
    );
  }
}
