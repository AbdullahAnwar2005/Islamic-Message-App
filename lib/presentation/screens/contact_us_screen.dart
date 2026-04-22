import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/contact_repository.dart';
import '../../localization/app_strings.dart';
import '../../providers/database_provider.dart';
import '../../providers/analytics_provider.dart';

final _contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = Supabase.instance.client;
  return ContactRepository(db, supabase);
});

/// Contact Us screen with category selection and message input
class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Track View
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).track('contact_view');
    });
  }

  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCategory = 'question';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'question',
    'feedback',
    'bug_report',
    'feature_request',
    'other',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(_contactRepositoryProvider);

      final success = await repository.submitContactMessage(
        category: _selectedCategory,
        message: _messageController.text.trim(),
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context, 'contact_sent_success')),
            backgroundColor: Colors.green,
          ),
        );
        // Track Success
        ref.read(analyticsServiceProvider).track('contact_submit_success');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context, 'contact_saved_offline')),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Clear form and pop
      _messageController.clear();
      _emailController.clear();
      setState(() => _selectedCategory = 'question');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.of(context, 'generic_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'contact_us_title')),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Icon(Icons.mail_outline_rounded, size: 64, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context, 'contact_us_subtitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(context, 'contact_us_description'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Category Selector
            Text(
              AppStrings.of(context, 'contact_category'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: const Icon(Icons.category_rounded),
              ),
              items:
                  _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(AppStrings.of(context, 'category_$category')),
                    );
                  }).toList(),
              onChanged:
                  _isSubmitting
                      ? null
                      : (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
            ),
            const SizedBox(height: 24),

            // Message Field
            Text(
              AppStrings.of(context, 'contact_message'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: AppStrings.of(context, 'contact_message_hint'),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 6,
              enabled: !_isSubmitting,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.of(context, 'contact_message_required');
                }
                if (value.trim().length < 10) {
                  return AppStrings.of(context, 'contact_message_too_short');
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Email Field (Optional)
            Text(
              '${AppStrings.of(context, 'contact_email')} (${AppStrings.of(context, 'optional')})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: AppStrings.of(context, 'contact_email_hint'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isSubmitting,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  // Basic email validation
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return AppStrings.of(context, 'contact_email_invalid');
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            FilledButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        AppStrings.of(context, 'contact_submit'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
            const SizedBox(height: 16),

            // Disclaimer
            Text(
              AppStrings.of(context, 'contact_disclaimer'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
