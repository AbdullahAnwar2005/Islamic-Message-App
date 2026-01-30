import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_download_progress_provider.dart'; // For service and DownloadedFile
import '../../providers/message_provider.dart';
import '../../providers/message_language_provider.dart';
import '../../utils/message_extensions.dart';
import '../../utils/arabic_language_names.dart';
import '../../localization/app_strings.dart';
import 'read_screen.dart';
import '../../core/feedback_utils.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});

  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  late Future<List<DownloadedFile>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = ref.read(audioDownloadServiceProvider).getDownloadedFiles();
    });
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesWithTranslationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'downloads_title')),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DownloadedFile>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppStrings.of(
                  context,
                  'generic_error',
                ).replaceFirst('{0}', '${snapshot.error}'),
              ),
            );
          }

          final files = snapshot.data ?? [];

          return messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, s) => Center(
                  child: Text(
                    AppStrings.of(
                      context,
                      'data_error',
                    ).replaceFirst('{0}', '$e'),
                  ),
                ),
            data: (messages) {
              if (files.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.of(context, 'no_downloads'),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: files.length,
                itemBuilder: (ctx, i) {
                  final file = files[i];
                  // Find message title
                  final msg = messages
                      .cast<MessageWithTranslations?>()
                      .firstWhere(
                        (m) => m?.message.id == file.messageId,
                        orElse: () => null,
                      );

                  final title =
                      msg?.message.localizedTitle(
                        ref.read(appLanguageProvider),
                      ) ??
                      AppStrings.of(
                        context,
                        'message_default_title',
                      ).replaceFirst('{0}', '${file.messageId}');
                  final langName = arabicLanguageName(file.languageCode);

                  return ListTile(
                    leading: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.teal,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '$langName • ${_formatSize(file.sizeBytes)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: Text(
                                  AppStrings.of(context, 'delete_file_title'),
                                ),
                                content: Text(
                                  AppStrings.of(
                                    context,
                                    'delete_file_confirmation',
                                  ).replaceFirst('{0}', title),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      AppStrings.of(context, 'cancel'),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      AppStrings.of(context, 'delete'),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await ref
                              .read(audioDownloadServiceProvider)
                              .remove(file.messageId, file.languageCode);
                          if (mounted) {
                            showTopSnackBar(
                              context,
                              AppStrings.of(context, 'deleted_success'),
                            );
                            _refresh();
                          }
                        }
                      },
                    ),
                    onTap: () {
                      if (msg != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ReadScreen(messageId: msg.message.id),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
