import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/message_provider.dart' show MessageWithTranslations;

/// Minimal, modern reader bottom bar (no audio button).
/// Designed to float visually above the GlobalAudioBar.
///
/// Extras:
/// - Optional `onJumpToLastChapter` action (shows only if provided)
class BottomReaderBar extends ConsumerWidget {
  const BottomReaderBar({
    super.key,
    required this.messageId,
    required this.bundle,
    required this.onOpenAa,
    required this.onOpenBookmarks,
    required this.onOpenChapters,
    required this.onToggleAudio, // kept for API compatibility
    this.onJumpToLastChapter, // optional; shows a flag button if set
  });

  final int messageId;
  final MessageWithTranslations bundle;

  final VoidCallback onOpenAa;
  final VoidCallback onOpenBookmarks;
  final VoidCallback onOpenChapters;
  final VoidCallback
  onToggleAudio; // not rendered here, only kept to avoid breaking callers
  final VoidCallback? onJumpToLastChapter;

  static const double height = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Build the core actions, conditionally inserting the "last read" button.
    final actions = <Widget>[
      _ActionIcon(
        icon: Icons.text_fields_rounded,
        tooltip: 'إعدادات النص',
        color: cs.primary,
        onTap: onOpenAa,
      ),
      _Divider(color: cs.outlineVariant),
      _ActionIcon(
        icon: Icons.bookmark_border_rounded,
        tooltip: 'العلامات المرجعية',
        color: cs.primary,
        onTap: onOpenBookmarks,
      ),
      _Divider(color: cs.outlineVariant),
      _ActionIcon(
        icon: Icons.menu_book_outlined,
        tooltip: 'الفصول',
        color: cs.primary,
        onTap: onOpenChapters,
      ),
    ];

    if (onJumpToLastChapter != null) {
      actions.addAll([
        _Divider(color: cs.outlineVariant),
        _ActionIcon(
          icon: Icons.flag_circle_outlined,
          tooltip: 'آخر فصل مقروء',
          color: cs.primary,
          onTap: onJumpToLastChapter!,
        ),
      ]);
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SizedBox(
                height: height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: actions,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      color: color.withValues(alpha: 0.35),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 250),
      child: InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        radius: 26,
        borderRadius: BorderRadius.circular(12),
        containedInkWell: true,
        splashColor: color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
