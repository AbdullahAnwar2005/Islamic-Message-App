import 'package:flutter/material.dart';
import '../../reader/models/reader_content.dart' show Chapter;
import '../../../localization/app_strings.dart';

class ChaptersSheet extends StatefulWidget {
  const ChaptersSheet({
    super.key,
    required this.chapters,
    this.currentChapterIndex,
    this.completedChapters,
  });

  final List<Chapter> chapters;
  final int? currentChapterIndex;
  final Set<int>? completedChapters;

  @override
  State<ChaptersSheet> createState() => _ChaptersSheetState();
}

class _ChaptersSheetState extends State<ChaptersSheet> {
  final ScrollController _scrollCtx = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentChapterIndex != null &&
          widget.currentChapterIndex! > 2) {
        _scrollToIndex(widget.currentChapterIndex!);
      }
    });
  }

  void _scrollToIndex(int index) {
    if (!_scrollCtx.hasClients) return;
    // Estimate item height ~ 72px + spacing
    final offset = ((index - 1) * 80.0).clamp(
      0.0,
      _scrollCtx.position.maxScrollExtent,
    );
    _scrollCtx.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollCtx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = widget.chapters.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        // We link internal controller to sheet controller if possible,
        // but explicit scrolling works better with primary controller.
        // For draggable sheet, we usually use the provided controller.
        // We'll wrap our logic to use the provided one for dragging.
        return Material(
          color: theme.scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                AppStrings.of(context, 'chapters_title'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  controller: scrollController, // Use sheet controller
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: count,
                  itemBuilder: (context, i) {
                    final chapter = widget.chapters[i];
                    final isCurrent = i == widget.currentChapterIndex;
                    final isRead =
                        widget.completedChapters?.contains(i) ?? false;

                    return _ChapterTile(
                      index: i,
                      chapter: chapter,
                      isCurrent: isCurrent,
                      isRead: isRead,
                      onTap: () => Navigator.of(context).pop(i),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.index,
    required this.chapter,
    required this.isCurrent,
    required this.isRead,
    required this.onTap,
  });

  final int index;
  final Chapter chapter;
  final bool isCurrent;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final bg =
        isCurrent
            ? color.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent;

    final border =
        isCurrent
            ? Border.all(
              color: color.primary.withValues(alpha: 0.5),
              width: 1.5,
            )
            : Border.all(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 1,
            );

    final title =
        chapter.title ?? '${AppStrings.of(context, 'chapter')} ${index + 1}';
    final preview = _chapterPreview(chapter);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _IndexIndicator(
                index: index + 1,
                isCurrent: isCurrent,
                isRead: isRead,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.w600,
                        color:
                            isCurrent
                                ? color.primary
                                : theme.textTheme.titleMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (preview != null && preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isCurrent)
                Icon(Icons.equalizer, color: color.primary, size: 20)
              else if (isRead)
                Icon(
                  Icons.check_circle_outline,
                  color: color.secondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _chapterPreview(Chapter ch) {
    for (final p in ch.paragraphs) {
      final t = p.text.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }
}

class _IndexIndicator extends StatelessWidget {
  const _IndexIndicator({
    required this.index,
    required this.isCurrent,
    required this.isRead,
  });
  final int index;
  final bool isCurrent;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color:
            isCurrent
                ? theme.colorScheme.primary
                : (isRead
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.surfaceContainerHighest),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: TextStyle(
          color:
              isCurrent
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
