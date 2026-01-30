import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/reader/providers/bookmarks_provider.dart';
import '../../providers/message_language_provider.dart';
import '../../providers/message_provider.dart';
import '../../utils/message_extensions.dart';
import 'read_screen.dart';
import '../../localization/app_strings.dart';

class GlobalBookmarksScreen extends ConsumerWidget {
  const GlobalBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksMap = ref.watch(bookmarksProvider);
    final messagesAsync = ref.watch(messagesWithTranslationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(context, 'bookmarks_title')),
        centerTitle: true,
      ),
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Text(
                AppStrings.of(
                  context,
                  'messages_load_error',
                ).replaceFirst('{0}', '$err'),
                textAlign: TextAlign.center,
              ),
            ),
        data: (messages) {
          if (bookmarksMap.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.of(context, 'no_global_bookmarks'),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Filter messages that actually have bookmarks
          final messagesWithBookmarks =
              messages
                  .where((m) => bookmarksMap.containsKey(m.message.id))
                  .toList();

          if (messagesWithBookmarks.isEmpty) {
            // Edge case: bookmarks exist for deleted messages?
            return Center(
              child: Text(AppStrings.of(context, 'no_bookmarks_found')),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: messagesWithBookmarks.length,
            itemBuilder: (context, index) {
              final msg = messagesWithBookmarks[index];
              final bks = bookmarksMap[msg.message.id] ?? [];
              if (bks.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header (Message Title)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    child: Text(
                      msg.message.localizedTitle(
                        ref.watch(appLanguageProvider),
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // Bookmarks List
                  ...bks.map((b) {
                    return ListTile(
                      leading: const Icon(Icons.bookmark, size: 20),
                      title: Text(
                        b.excerpt.trim().isEmpty
                            ? AppStrings.of(context, 'default_excerpt')
                            : b.excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${AppStrings.of(context, 'chapter')} ${b.chapterIndex + 1} • ${b.createdAt.toLocal().toString().split('.')[0]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {
                          ref
                              .read(bookmarksProvider.notifier)
                              .remove(msg.message.id, b);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ReadScreen(
                                  messageId: msg.message.id,
                                  initialChapterIndex: b.chapterIndex,
                                ),
                          ),
                        );
                      },
                    );
                  }),
                  const Divider(height: 1),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
