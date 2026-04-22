import 'package:alghaya_men_alkhalg/presentation/screens/contact_us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/app_strings.dart';
import '../providers/declare_islam_provider.dart';
import '../../../../providers/analytics_provider.dart';

class ReadinessStepWidget extends ConsumerWidget {
  const ReadinessStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(declareIslamProvider);
    final notifier = ref.read(declareIslamProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.of(context, 'di_readiness_title'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _CheckboxTile(
            label: AppStrings.of(context, 'di_readiness_check_1'),
            value: state.checkUnderstood,
            onChanged: (v) => notifier.toggleCheckUnderstood(v ?? false),
          ),
          _CheckboxTile(
            label: AppStrings.of(context, 'di_readiness_check_2'),
            value: state.checkChoice,
            onChanged: (v) => notifier.toggleCheckChoice(v ?? false),
          ),
          _CheckboxTile(
            label: AppStrings.of(context, 'di_readiness_check_3'),
            value: state.checkSaid,
            onChanged: (v) => notifier.toggleCheckSaid(v ?? false),
          ),

          const SizedBox(height: 48),

          FilledButton(
            onPressed:
                state.canConfirm
                    ? () {
                      ref
                          .read(analyticsServiceProvider)
                          .track(
                            'shahada_step_complete',
                            properties: {
                              'step_index': 2,
                            }, // Completed Readiness Step
                          );
                      final lang = Localizations.localeOf(context).languageCode;
                      notifier.confirmDeclaration(lang);
                    }
                    : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green[700],
            ),
            child: Text(
              AppStrings.of(context, 'di_btn_confirm'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              notifier.goToStep(DeclareIslamStep.learn);
            },
            child: Text(AppStrings.of(context, 'back')),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
            child: Text(AppStrings.of(context, 'di_intro_btn_questions')),
          ),
        ],
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              value
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
