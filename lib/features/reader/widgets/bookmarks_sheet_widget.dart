import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmarks_provider.dart';

// Needed for chapter titles
import '../../../providers/message_provider.dart';
import '../../../providers/message_language_provider.dart';
import '../../reader/mappers/translation_to_message_content.dart';
import '../../reader/models/reader_content.dart';
import '../../../utils/choose_translation_utility.dart';
import '../../../utils/message_extensions.dart';
import '../../../core/feedback_utils.dart';
import '../../../localization/app_strings.dart';

class BookmarksSheet extends ConsumerWidget {
  const BookmarksSheet({super.key, required this.messageId});
  final int messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get bookmarks
    final bookmarks = ref.watch(
      bookmarksProvider.select((m) => m[messageId] ?? const []),
    );

    // 2. Get chapter titles
    final messagesAsync = ref.watch(messagesWithTranslationsProvider);
    Map<int, String> chapterTitles = {};

    if (messagesAsync.hasValue) {
      try {
        final list = messagesAsync.value!;
        final bundle = list.firstWhere(
          (e) => e.message.id == messageId,
          orElse: () => list.first,
        );

        final rawLang =
            ref.read(messageLangOverridesProvider)[messageId] ??
            ref.read(appLanguageProvider);
        final displayLang = norm(rawLang!);
        final tr = _pickBestTranslation(bundle, displayLang);
        final content = _buildContentRobust(
          bundle: bundle,
          translation: tr,
          langCode: displayLang,
        );

        for (int i = 0; i < content.chapters.length; i++) {
          final title = content.chapters[i].title?.trim();
          if (title != null && title.isNotEmpty) {
            chapterTitles[i] = title;
          }
        }
      } catch (_) {
        // fail silently regarding titles
      }
    }

    if (bookmarks.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              AppStrings.of(context, 'no_bookmarks_hint'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    // 3. Group by chapter
    final Map<int, List<Bookmark>> grouped = {};
    for (final b in bookmarks) {
      grouped.putIfAbsent(b.chapterIndex, () => []).add(b);
    }

    // Sort chapters by index
    final sortedChapterIndices = grouped.keys.toList()..sort();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.bookmarks_outlined),
                const SizedBox(width: 8),
                Text(
                  AppStrings.of(context, 'bookmarks_title'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: sortedChapterIndices.length,
              itemBuilder: (context, i) {
                final chapterIndex = sortedChapterIndices[i];
                final chapterBookmarks = grouped[chapterIndex]!;
                final chapterTitle =
                    chapterTitles[chapterIndex] ??
                    '${AppStrings.of(context, 'chapter')} ${chapterIndex + 1}';

                return _ChapterBookmarksGroup(
                  chapterTitle: chapterTitle,
                  bookmarks: chapterBookmarks,
                  messageId: messageId,
                  onTap: (b) => Navigator.of(context).maybePop(b),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers copied from ReadScreen/ChaptersSheet (DRY refactor would be nice later) ---
  dynamic _pickBestTranslation(
    MessageWithTranslations bundle,
    String displayLang,
  ) {
    final picked = pickTranslation(bundle.translations, displayLang);
    if (picked != null) return picked;
    try {
      return bundle.translations.firstWhere(
        (t) => norm(t.languageCode) == displayLang,
        orElse:
            () => bundle.translations.firstWhere(
              (t) => norm(t.languageCode).startsWith(displayLang),
            ),
      );
    } catch (_) {
      return null;
    }
  }

  MessageContent _buildContentRobust({
    required MessageWithTranslations bundle,
    required dynamic translation,
    required String langCode,
  }) {
    if (translation == null) {
      return MessageContent(chapters: const [], languageCode: langCode);
    }
    MessageContent? built;
    try {
      built = toMessageContent(
        translation,
        messageId: bundle.message.id,
        messageTitle: bundle.message.localizedTitle(langCode),
      );
    } catch (_) {}
    if (built == null || built.chapters.isEmpty) {
      try {
        built = toMessageContent(
          translation.content,
          messageId: bundle.message.id,
          messageTitle: bundle.message.localizedTitle(langCode),
        );
      } catch (_) {}
    }
    return built ?? MessageContent(chapters: const [], languageCode: langCode);
  }
}

class _ChapterBookmarksGroup extends ConsumerWidget {
  const _ChapterBookmarksGroup({
    required this.chapterTitle,
    required this.bookmarks,
    required this.messageId,
    required this.onTap,
  });

  final String chapterTitle;
  final List<Bookmark> bookmarks;
  final int messageId;
  final ValueChanged<Bookmark> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapter Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Text(
            chapterTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        // Bookmarks in this chapter
        ...bookmarks.map((b) {
          return Dismissible(
            key: ValueKey(
              '${b.messageId}_${b.createdAt.toIso8601String()}_${b.paragraphKey}',
            ),
            background: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete_outline),
            ),
            secondaryBackground: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete_outline),
            ),
            onDismissed: (_) {
              ref.read(bookmarksProvider.notifier).remove(messageId, b);
              showTopSnackBar(
                context,
                AppStrings.of(context, 'bookmark_deleted'),
              );
            },
            child: ListTile(
              leading: const Icon(Icons.bookmark, size: 20),
              title: Text(
                b.excerpt.trim().isNotEmpty == true
                    ? b.excerpt.trim()
                    : AppStrings.of(context, 'bookmark_default_title'),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                _formatTime(context, b.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => onTap(b),
            ),
          );
        }),
      ],
    );
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return AppStrings.of(context, 'time_now');
    if (d.inMinutes < 60)
      return AppStrings.of(
        context,
        'time_min_ago',
      ).replaceFirst('{0}', '${d.inMinutes}');
    if (d.inHours < 24)
      return AppStrings.of(
        context,
        'time_hour_ago',
      ).replaceFirst('{0}', '${d.inHours}');
    return AppStrings.of(
      context,
      'time_day_ago',
    ).replaceFirst('{0}', '${d.inDays}');
  }
}
