import 'package:flutter/material.dart';

/// Quick resume actions widget showing "Continue Reading" and "Continue Listening" buttons
/// Appears when user has saved progress for scroll position or audio playback
class QuickResumeWidget extends StatelessWidget {
  final double? readingProgressPercent;
  final int? audioPositionMs;
  final VoidCallback? onContinueReading;
  final VoidCallback? onContinueListening;

  const QuickResumeWidget({
    super.key,
    this.readingProgressPercent,
    this.audioPositionMs,
    this.onContinueReading,
    this.onContinueListening,
  });

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Don't show widget if no progress exists
    final hasReadingProgress =
        readingProgressPercent != null && readingProgressPercent! > 0.01;
    final hasAudioProgress = audioPositionMs != null && audioPositionMs! > 0;

    if (!hasReadingProgress && !hasAudioProgress) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Continue Reading" button
          if (hasReadingProgress && onContinueReading != null)
            _buildResumeButton(
              context: context,
              icon: Icons.visibility_outlined,
              label: 'Continue Reading',
              subtitle:
                  '${readingProgressPercent!.toStringAsFixed(0)}% complete',
              onTap: onContinueReading!,
              colorScheme: colorScheme,
            ),

          // Spacing between buttons
          if (hasReadingProgress &&
              hasAudioProgress &&
              onContinueReading != null &&
              onContinueListening != null)
            const SizedBox(height: 8),

          // "Continue Listening" button
          if (hasAudioProgress && onContinueListening != null)
            _buildResumeButton(
              context: context,
              icon: Icons.headphones_outlined,
              label: 'Continue Listening',
              subtitle: 'Resume at ${_formatDuration(audioPositionMs!)}',
              onTap: onContinueListening!,
              colorScheme: colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildResumeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '$label - $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Icon(icon, size: 24, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
