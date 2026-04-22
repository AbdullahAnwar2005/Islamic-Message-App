import 'package:flutter/material.dart';
import 'dart:async';

/// Sticky bottom audio player with playback controls
/// Includes slider, time labels, rewind/forward 10s, play/pause, and settings
class StickyAudioPlayerWidget extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onRewind10s;
  final VoidCallback onForward10s;
  final VoidCallback onSettings;

  const StickyAudioPlayerWidget({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    this.isLoading = false,
    required this.onPlayPause,
    required this.onSeek,
    required this.onRewind10s,
    required this.onForward10s,
    required this.onSettings,
  });

  @override
  State<StickyAudioPlayerWidget> createState() =>
      _StickyAudioPlayerWidgetState();
}

class _StickyAudioPlayerWidgetState extends State<StickyAudioPlayerWidget> {
  double? _draggingValue;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);
    final isRTL = textDirection == TextDirection.rtl;

    final durMs = widget.duration.inMilliseconds;
    final posMs = widget.position.inMilliseconds;
    final sliderValue =
        durMs > 0
            ? (_draggingValue ?? (posMs.toDouble() / durMs).clamp(0.0, 1.0))
            : 0.0;

    final elapsedText = _formatDuration(widget.position);
    final remainingDuration = widget.duration - widget.position;
    final remainingText = '-${_formatDuration(remainingDuration)}';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress slider with time labels
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: colorScheme.surfaceVariant,
                      thumbColor: colorScheme.primary,
                      overlayColor: colorScheme.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: sliderValue,
                      onChanged:
                          durMs > 0
                              ? (v) => setState(() => _draggingValue = v)
                              : null,
                      onChangeEnd:
                          durMs > 0
                              ? (v) {
                                final newMs = (v * durMs).round();
                                widget.onSeek(Duration(milliseconds: newMs));
                                setState(() => _draggingValue = null);
                              }
                              : null,
                    ),
                  ),
                  // Time labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          elapsedText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          remainingText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Control buttons row
            Padding(
              padding: const EdgeInsets.only(
                bottom: 12.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rewind 10s button (RTL-aware)
                  _buildControlButton(
                    context: context,
                    icon: Icons.replay_10,
                    label: 'Rewind 10 seconds',
                    onPressed: widget.onRewind10s,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(width: 8),

                  // Play/Pause button (always centered)
                  _buildControlButton(
                    context: context,
                    icon:
                        widget.isLoading
                            ? Icons.hourglass_empty
                            : (widget.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow),
                    label: widget.isPlaying ? 'Pause' : 'Play',
                    onPressed: widget.isLoading ? null : widget.onPlayPause,
                    colorScheme: colorScheme,
                    isPrimary: true,
                  ),

                  const SizedBox(width: 8),

                  // Forward 10s button (RTL-aware)
                  _buildControlButton(
                    context: context,
                    icon: Icons.forward_10,
                    label: 'Forward 10 seconds',
                    onPressed: widget.onForward10s,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(width: 16),

                  // Settings button
                  _buildControlButton(
                    context: context,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onPressed: widget.onSettings,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required ColorScheme colorScheme,
    bool isPrimary = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      child: Material(
        color: isPrimary ? colorScheme.primaryContainer : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: isPrimary ? 28 : 24,
              color:
                  onPressed != null
                      ? (isPrimary
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface)
                      : colorScheme.onSurface.withOpacity(0.38),
            ),
          ),
        ),
      ),
    );
  }

  // Get the approximate height of this widget for padding calculations
  static double get estimatedHeight => 120.0; // Adjust based on actual layout
}
