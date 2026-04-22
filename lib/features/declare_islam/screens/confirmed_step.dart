import 'package:alghaya_men_alkhalg/presentation/screens/contact_us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/app_strings.dart';
import '../providers/declare_islam_provider.dart';
import '../../../../providers/analytics_provider.dart';

class ConfirmedStepWidget extends ConsumerStatefulWidget {
  const ConfirmedStepWidget({super.key});

  @override
  ConsumerState<ConfirmedStepWidget> createState() =>
      _ConfirmedStepWidgetState();
}

class _ConfirmedStepWidgetState extends ConsumerState<ConfirmedStepWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).track('shahada_finish');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          Text(
            AppStrings.of(context, 'congrats_header'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.of(context, 'congrats_body'),
            style: const TextStyle(fontSize: 18, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
            ),
            child: Text(
              AppStrings.of(context, 'di_confirmed_official_note'),
              style: TextStyle(color: Colors.blueGrey[900], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            AppStrings.of(context, 'whats_next'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _NextStepCard(
            number: '1',
            text: AppStrings.of(context, 'next_step_1'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => Scaffold(
                        body: Center(
                          child: Text(
                            AppStrings.of(
                              context,
                              'module_coming_soon',
                            ).replaceFirst(
                              '{0}',
                              AppStrings.of(context, 'next_step_1'),
                            ),
                          ),
                        ),
                      ),
                ),
              );
            },
          ),
          _NextStepCard(
            number: '2',
            text: AppStrings.of(context, 'next_step_2'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => const Scaffold(
                        body: Center(child: Text("Quran Module - Coming Soon")),
                      ),
                ),
              );
            },
          ),
          _NextStepCard(
            number: '3',
            text: AppStrings.of(context, 'next_step_3'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
          ),

          const SizedBox(height: 48),
          TextButton(
            onPressed: () {
              ref.read(declareIslamProvider.notifier).undoDeclaration();
            },
            child: Text(
              AppStrings.of(context, 'di_undo_btn'),
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final String number;
  final String text;
  final VoidCallback onTap;

  const _NextStepCard({
    required this.number,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            number,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
