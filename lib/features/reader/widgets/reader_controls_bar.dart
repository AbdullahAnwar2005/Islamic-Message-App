import 'package:flutter/material.dart';

class ReaderControlsBar extends StatelessWidget {
  const ReaderControlsBar({
    super.key,
    required this.onChaptersTap,
    required this.onSettingsTap,
    required this.onBookmarksListTap,
    required this.onBookmarkAddTap,
    this.bottomContent,
  });

  final VoidCallback onChaptersTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onBookmarksListTap;
  final VoidCallback onBookmarkAddTap;
  final Widget? bottomContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Chapters
                IconButton(
                  icon: const Icon(Icons.list),
                  color: color,
                  tooltip: 'الفصول',
                  onPressed: onChaptersTap,
                ),

                // Appearance (Aa)
                IconButton(
                  icon: const Icon(Icons.text_fields),
                  color: color,
                  tooltip: 'الإعدادات',
                  onPressed: onSettingsTap,
                ),

                // Bookmarks (List)
                IconButton(
                  icon: const Icon(Icons.bookmarks_outlined),
                  color: color,
                  tooltip: 'المذكرات',
                  onPressed: onBookmarksListTap,
                ),

                // Add Bookmark (Quick Action)
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  color: theme.colorScheme.primary,
                  tooltip: 'حفظ الموضع',
                  onPressed: onBookmarkAddTap,
                ),
              ],
            ),
            if (bottomContent != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: bottomContent,
              ),
          ],
        ),
      ),
    );
  }
}
