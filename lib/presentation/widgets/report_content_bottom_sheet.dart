import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/content_report_repository.dart';
import '../../localization/app_strings.dart';
import '../../providers/database_provider.dart';

final _contentReportRepositoryProvider = Provider<ContentReportRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final supabase = Supabase.instance.client;
  return ContentReportRepository(db, supabase);
});

/// Bottom sheet for reporting content issues
class ReportContentBottomSheet extends ConsumerStatefulWidget {
  final int messageId;
  final String languageCode;

  const ReportContentBottomSheet({
    super.key,
    required this.messageId,
    required this.languageCode,
  });

  @override
  ConsumerState<ReportContentBottomSheet> createState() =>
      _ReportContentBottomSheetState();
}

class _ReportContentBottomSheetState
    extends ConsumerState<ReportContentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  String _selectedReportType = 'translation_error';
  bool _isSubmitting = false;

  final List<String> _reportTypes = [
    'translation_error',
    'missing_audio',
    'technical_issue',
    'inappropriate_content',
    'other',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(_contentReportRepositoryProvider);

      final success = await repository.submitReport(
        messageId: widget.messageId,
        languageCode: widget.languageCode,
        reportType: _selectedReportType,
        comment:
            _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context, 'report_sent_success')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context, 'report_saved_offline')),
            backgroundColor: Colors.orange,
          ),
        );
      }

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
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.7,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
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

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.of(context, 'report_content_title'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    AppStrings.of(context, 'report_content_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Report Type
                  Text(
                    AppStrings.of(context, 'report_type'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedReportType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(Icons.label_outlined),
                    ),
                    items:
                        _reportTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(AppStrings.of(context, 'report_$type')),
                          );
                        }).toList(),
                    onChanged:
                        _isSubmitting
                            ? null
                            : (value) {
                              if (value != null) {
                                setState(() => _selectedReportType = value);
                              }
                            },
                  ),
                  const SizedBox(height: 24),

                  // Comment (Optional)
                  Text(
                    '${AppStrings.of(context, 'report_comment')} (${AppStrings.of(context, 'optional')})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: AppStrings.of(context, 'report_comment_hint'),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                    enabled: !_isSubmitting,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.of(context, 'report_info'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submitReport,
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
                              AppStrings.of(context, 'report_submit'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show the report bottom sheet
Future<void> showReportContentSheet({
  required BuildContext context,
  required int messageId,
  required String languageCode,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => ReportContentBottomSheet(
          messageId: messageId,
          languageCode: languageCode,
        ),
  );
}
