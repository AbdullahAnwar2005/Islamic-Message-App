import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../localization/app_strings.dart';

class ContactDaiyahScreen extends ConsumerWidget {
  const ContactDaiyahScreen({super.key});

  Future<void> _launchUrl(BuildContext context, Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.of(
                  context,
                  'launch_error',
                ).replaceFirst('{0}', '$url'),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.of(context, 'generic_error').replaceFirst('{0}', '$e'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'contact_daiyah_title')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.of(context, 'we_here_help'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context, 'contact_desc'),
              style: const TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildContactOption(
              context,
              icon: Icons.phone_android, // WhatsApp-like icon
              title: AppStrings.of(context, 'whatsapp'),
              subtitle: AppStrings.of(context, 'whatsapp_subtitle'),
              color: const Color(0xFF25D366),
              onTap: () {
                // Replace with actual number
                final uri = Uri.parse('https://wa.me/1234567890');
                _launchUrl(context, uri);
              },
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              context,
              icon: Icons.email_outlined,
              title: AppStrings.of(context, 'email'),
              subtitle: AppStrings.of(context, 'email_subtitle'),
              color: Colors.blue,
              onTap: () {
                final uri = Uri.parse(
                  'mailto:contact@example.com?subject=استفسار عن الإسلام',
                );
                _launchUrl(context, uri);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
