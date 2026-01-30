import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contact_daiyah_screen.dart';
import '../../localization/app_strings.dart';

class AcceptIslamScreen extends ConsumerStatefulWidget {
  const AcceptIslamScreen({super.key});

  @override
  ConsumerState<AcceptIslamScreen> createState() => _AcceptIslamScreenState();
}

class _AcceptIslamScreenState extends ConsumerState<AcceptIslamScreen> {
  bool _hasAccepted = false;

  void _onAccept() {
    setState(() {
      _hasAccepted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'declare_islam')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _hasAccepted ? _buildWelcomeView() : _buildShahadaView(),
        ),
      ),
    );
  }

  Widget _buildShahadaView() {
    return Column(
      key: const ValueKey('shahada'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppStrings.of(context, 'welcome_header'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.of(context, 'islam_definition'),
          style: const TextStyle(fontSize: 16, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppStrings.of(context, 'shahada_arabic'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      'Amiri', // Assuming Amiri or similar is available, else default
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              Text(
                AppStrings.of(context, 'shahada_english'),
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _onAccept,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'أُعلن دخولي في الإسلام',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.of(context, 'declare_disclaimer'),
          style: TextStyle(
            color: Theme.of(context).disabledColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWelcomeView() {
    return Column(
      key: const ValueKey('welcome'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        Text(
          AppStrings.of(context, 'congrats_header'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.of(context, 'congrats_body'),
          style: const TextStyle(fontSize: 18, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  AppStrings.of(context, 'whats_next'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStepItem('1', AppStrings.of(context, 'next_step_1')),
                _buildStepItem('2', AppStrings.of(context, 'next_step_2')),
                _buildStepItem('3', AppStrings.of(context, 'next_step_3')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactDaiyahScreen(),
              ),
            );
          },
          icon: const Icon(Icons.support_agent),
          label: Text(AppStrings.of(context, 'contact_daiyah')),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
