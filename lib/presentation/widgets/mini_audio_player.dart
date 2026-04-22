import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_player_provider.dart';
import '../screens/audio_player_screen.dart';
import '../../localization/app_strings.dart';

class MiniAudioPlayer extends ConsumerWidget {
  final int messageId;
  final String title;
  final VoidCallback? onExpand;

  const MiniAudioPlayer({
    super.key,
    required this.messageId,
    required this.title,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final playerState = ref.watch(audioPlayerProvider);

    final isActive = playerState.activeMessageId == messageId;
    final isPlaying = isActive && playerState.isPlaying;

    // Mode 1: Audio is active (Playing or Paused) for THIS message
    if (isActive) {
      final duration = playerState.duration;
      final position = playerState.position;
      final progress =
          (duration.inMilliseconds > 0)
              ? (position.inMilliseconds / duration.inMilliseconds)
              : 0.0;

      return GestureDetector(
        onTap: () => _openFullPlayer(context),
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Play/Pause Button
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: scheme.primary,
                ),
                onPressed: () {
                  final ctrl = ref.read(audioPlayerProvider.notifier);
                  if (isPlaying) {
                    ctrl.pause();
                  } else {
                    ctrl.play();
                  }
                },
              ),

              // Progress and Title
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: scheme.onSurfaceVariant.withOpacity(0.1),
                      color: scheme.primary,
                      minHeight: 2,
                    ),
                  ],
                ),
              ),

              // Expand Action
              IconButton(
                icon: const Icon(Icons.open_in_full_rounded, size: 20),
                tooltip: 'فتح المشغل', // Should use AppStrings ideally
                onPressed: () => _openFullPlayer(context),
              ),
            ],
          ),
        ),
      );
    }

    // Mode 2: Audio is NOT active (Idle) -> Simple "Listen" CTA
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FilledButton.icon(
        onPressed: () => _openFullPlayer(context),
        icon: const Icon(Icons.headphones_outlined),
        label: Text(AppStrings.of(context, 'listen_action')),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _openFullPlayer(BuildContext context) {
    if (onExpand != null) {
      onExpand!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AudioPlayerScreen(messageId: messageId),
        ),
      );
    }
  }
}
