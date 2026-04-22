import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/audio_service_providers.dart'
    show
        audioHandlerProvider,
        isPlayingStreamProvider,
        positionStreamProvider,
        durationStreamProvider;

import '../../../providers/audio_player_provider.dart' show audioPlayerProvider;
import '../../../providers/audio_download_progress_provider.dart'
    show
        audioDownloadProgressForFileProvider,
        audioDownloadServiceProvider,
        audioLocalPathProvider;
import '../../core/feedback_utils.dart';
import '../../localization/app_strings.dart';

final _scrubMsProvider = StateProvider<int?>((ref) => null);
// simple local speed state (for menu highlight + badge)
final _speedProvider = StateProvider<double>((ref) => 1.0);
final _downloadPendingProvider = StateProvider.family<bool, String>(
  (ref, key) => false,
);

class GlobalAudioBar extends ConsumerWidget {
  const GlobalAudioBar({
    super.key,
    this.messageId,
    this.lang,
    this.title,
    this.remoteUrl,
    this.isEmbedded = false,
  });

  final int? messageId;
  final String? lang;
  final String? title;
  final String? remoteUrl;
  final bool isEmbedded;

  static const double height = 56;

  bool get _hasPerMessage => messageId != null && lang != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // ——— Per-message mode (reader/card) ———
    if (_hasPerMessage) {
      final playerState = ref.watch(audioPlayerProvider);
      final isActive = playerState.activeMessageId == messageId;

      final sPos = isActive ? playerState.position : Duration.zero;
      final sDur = isActive ? playerState.duration : Duration.zero;
      final sIsPlaying = isActive ? playerState.isPlaying : false;
      final sSource = isActive ? playerState.sourcePath : null;

      final localPathAsync = ref.watch(
        audioLocalPathProvider((id: messageId!, lang: lang!)),
      );
      final scrubMs = ref.watch(_scrubMsProvider);

      return localPathAsync.when(
        loading:
            () => _shell(
              context,
              cs: cs,
              isPlaying: false,
              pos: Duration.zero,
              dur: const Duration(milliseconds: 1),
              scrubMs: (scrubMs ?? 0),
              onToggle: null,
              onSeekRel: null,
              onScrubCommit: null,
              trailing: _SpeedMenu(
                mode: _SpeedMode.perMessage,
                messageId: messageId!,
              ),
              forcePrimaryIconColor: true,
            ),
        error:
            (_, __) => _shell(
              context,
              cs: cs,
              isPlaying: false,
              pos: Duration.zero,
              dur: const Duration(milliseconds: 1),
              scrubMs: 0,
              onToggle: null,
              onSeekRel: null,
              onScrubCommit: null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SpeedMenu(
                    mode: _SpeedMode.perMessage,
                    messageId: messageId!,
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.error_outline, color: cs.error),
                ],
              ),
              forcePrimaryIconColor: true,
            ),
        data: (localPath) {
          final hasLocal = localPath != null && localPath.isNotEmpty;
          final dur =
              sDur <= Duration.zero ? const Duration(milliseconds: 1) : sDur;
          final pos = sPos;

          Future<void> ensureLoadedAndToggle() async {
            final ctrl = ref.read(audioPlayerProvider.notifier);
            try {
              if (hasLocal) {
                if (sSource != localPath) {
                  await ctrl.loadSource(
                    messageId: messageId!,
                    mediaId: '${messageId!}:${lang!}',
                    path: localPath!,
                    title: title ?? 'Audio',
                  );
                }
              } else if (remoteUrl != null && remoteUrl!.isNotEmpty) {
                if (sSource != remoteUrl) {
                  await ctrl.loadSource(
                    messageId: messageId!,
                    mediaId: '${messageId!}:${lang!}',
                    path: remoteUrl!,
                    title: title ?? 'Audio',
                  );
                }
              }
              sIsPlaying ? ctrl.pause() : ctrl.play();
            } catch (e) {
              if (context.mounted) {
                showTopSnackBar(
                  context,
                  AppStrings.of(
                    context,
                    'audio_playback_error',
                  ).replaceFirst('{0}', '$e'),
                  isError: true,
                );
              }
            }
          }

          Future<void> seekRelative(Duration delta) async {
            final ctrl = ref.read(audioPlayerProvider.notifier);
            final raw = pos + delta;
            final target =
                raw < Duration.zero
                    ? Duration.zero
                    : (sDur > Duration.zero && raw > sDur ? sDur : raw);
            await ctrl.seek(target);
          }

          Future<void> commitScrub(int ms) async {
            final ctrl = ref.read(audioPlayerProvider.notifier);
            final raw = Duration(milliseconds: ms);
            final target =
                raw < Duration.zero
                    ? Duration.zero
                    : (sDur > Duration.zero && raw > sDur ? sDur : raw);
            await ctrl.seek(target);
          }

          // Optional download/progress action
          Widget? dl;
          if (!hasLocal && (remoteUrl ?? '').isNotEmpty) {
            final prog = ref.watch(
              audioDownloadProgressForFileProvider((messageId!, lang!)),
            );
            final isPending = ref.watch(
              _downloadPendingProvider('${messageId}:${lang}'),
            );

            if ((prog != null && prog > 0 && prog < 1) || isPending) {
              dl = SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  value:
                      (isPending && (prog == null || prog == 0))
                          ? null
                          : prog?.clamp(0.0, 1.0),
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              );
            } else {
              dl = IconButton(
                tooltip: AppStrings.of(context, 'download_button'),
                icon: Icon(
                  Icons.download_for_offline_rounded,
                  color: cs.primary,
                ),
                onPressed: () async {
                  final k = '${messageId}:${lang}';
                  ref.read(_downloadPendingProvider(k).notifier).state = true;
                  try {
                    await ref
                        .read(audioDownloadServiceProvider)
                        .download(messageId!, lang!, remoteUrl!);
                    if (context.mounted) {
                      showTopSnackBar(
                        context,
                        AppStrings.of(context, 'download_completed'),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showTopSnackBar(
                        context,
                        AppStrings.of(context, 'audio_download_error'),
                        isError: true,
                      );
                    }
                  } finally {
                    ref.read(_downloadPendingProvider(k).notifier).state =
                        false;
                  }
                },
              );
            }
          }

          final trailingPack = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SpeedMenu(mode: _SpeedMode.perMessage, messageId: messageId!),
              if (dl != null) const SizedBox(width: 6),
              if (dl != null) dl,
            ],
          );

          final sliderMs =
              ((scrubMs ?? pos.inMilliseconds).clamp(
                0,
                dur.inMilliseconds <= 0 ? 1 : dur.inMilliseconds,
              )).toInt();

          return _shell(
            context,
            cs: cs,
            isPlaying: sIsPlaying,
            pos: pos,
            dur: dur,
            scrubMs: sliderMs,
            onToggle: hasLocal ? ensureLoadedAndToggle : null,
            onSeekRel: hasLocal ? seekRelative : null,
            onScrubChange: (v) => ref.read(_scrubMsProvider.notifier).state = v,
            onScrubStart: (v) => ref.read(_scrubMsProvider.notifier).state = v,
            onScrubCommit: (v) async {
              ref.read(_scrubMsProvider.notifier).state = null;
              await commitScrub(v);
            },
            trailing: trailingPack,
            forcePrimaryIconColor: true,
          );
        },
      );
    }

    // ——— Global service mode (fallback) ———
    final isPlaying = ref.watch(isPlayingStreamProvider).value ?? false;
    final pos = ref.watch(positionStreamProvider).value ?? Duration.zero;
    final dur =
        ref.watch(durationStreamProvider).value ??
        const Duration(milliseconds: 1);
    final scrubMs = ref.watch(_scrubMsProvider);

    Future<void> seekRel(Duration d) async {
      await ref.read(audioHandlerProvider).seekRelative(d);
    }

    return _shell(
      context,
      cs: cs,
      isPlaying: isPlaying,
      pos: pos,
      dur: dur.inMilliseconds <= 0 ? const Duration(milliseconds: 1) : dur,
      scrubMs: (scrubMs ?? pos.inMilliseconds).clamp(
        0,
        dur.inMilliseconds <= 0 ? 1 : dur.inMilliseconds,
      ),
      onToggle: () async {
        final h = ref.read(audioHandlerProvider);
        isPlaying ? h.pause() : h.play();
      },
      onSeekRel: seekRel,
      onScrubChange: (v) => ref.read(_scrubMsProvider.notifier).state = v,
      onScrubStart: (v) => ref.read(_scrubMsProvider.notifier).state = v,
      onScrubCommit: (v) async {
        ref.read(_scrubMsProvider.notifier).state = null;
        await ref.read(audioHandlerProvider).seek(Duration(milliseconds: v));
      },
      trailing: const _SpeedMenu(mode: _SpeedMode.global),
      forcePrimaryIconColor: true,
    );
  }

  Widget _shell(
    BuildContext context, {
    required ColorScheme cs,
    required bool isPlaying,
    required Duration pos,
    required Duration dur,
    required int scrubMs,
    required Future<void> Function()? onToggle,
    required Future<void> Function(Duration delta)? onSeekRel,
    Future<void> Function(int ms)? onScrubCommit,
    void Function(int ms)? onScrubChange,
    void Function(int ms)? onScrubStart,
    Widget? trailing,
    bool forcePrimaryIconColor = false,
  }) {
    final iconColor =
        forcePrimaryIconColor ? cs.primary : Theme.of(context).iconTheme.color;

    final content = Row(
      children: [
        // -10 button (left)
        IconButton(
          tooltip: '-10s',
          icon: Icon(CupertinoIcons.gobackward_10, color: iconColor),
          onPressed:
              onSeekRel == null
                  ? null
                  : () => onSeekRel(const Duration(seconds: -10)),
        ),

        // Play/Pause button (middle)
        IconButton(
          icon: Icon(
            isPlaying
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_filled_rounded,
            color: iconColor,
          ),
          iconSize: 34,
          onPressed: onToggle,
        ),

        // +10 button (right)
        IconButton(
          tooltip: '+10s',
          icon: Icon(CupertinoIcons.goforward_10, color: iconColor),
          onPressed:
              onSeekRel == null
                  ? null
                  : () => onSeekRel(const Duration(seconds: 10)),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: cs.primary,
                  inactiveTrackColor: cs.primary.withValues(alpha: 0.25),
                  thumbColor: cs.primary,
                  overlayColor: cs.primary.withValues(alpha: 0.15),
                ),
                child: Slider(
                  min: 0,
                  max:
                      (dur.inMilliseconds <= 0 ? 1 : dur.inMilliseconds)
                          .toDouble(),
                  value: scrubMs.toDouble(),
                  onChangeStart:
                      onScrubStart == null
                          ? null
                          : (v) => onScrubStart(v.toInt()),
                  onChanged:
                      onScrubChange == null
                          ? null
                          : (v) => onScrubChange(v.toInt()),
                  onChangeEnd:
                      onScrubCommit == null
                          ? null
                          : (v) => onScrubCommit(v.toInt()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fmt(Duration(milliseconds: scrubMs)),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                    Text(
                      _fmt(dur),
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 6),
            child: trailing,
          ),
      ],
    );

    if (isEmbedded) {
      return Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: content,
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Material(
          elevation: 10,
          color: cs.surface.withValues(alpha: 0.96),
          shadowColor: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: content,
          ),
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

enum _SpeedMode { perMessage, global }

class _SpeedMenu extends ConsumerWidget {
  const _SpeedMenu({required this.mode, this.messageId});
  final _SpeedMode mode;
  final int? messageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    const speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    final current = ref.watch(_speedProvider);

    Future<void> set(double v) async {
      ref.read(_speedProvider.notifier).state = v;

      if (mode == _SpeedMode.perMessage && messageId != null) {
        // REQUIRE: add setSpeed(double) to your audioPlayerProvider notifier (see patch below)
        await ref.read(audioPlayerProvider.notifier).setSpeed(v);
      } else {
        await ref.read(audioHandlerProvider).setSpeed(v);
      }
    }

    // speed icon with tiny badge showing current value
    Widget iconWithBadge() {
      final label =
          '${current.toStringAsFixed(current.truncateToDouble() == current ? 0 : 1)}x';
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.speed, color: cs.primary),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return PopupMenuButton<double>(
      tooltip: AppStrings.of(context, 'speed_label').split('\n')[0],
      icon: iconWithBadge(),
      onSelected: (v) => set(v),
      itemBuilder:
          (context) => [
            for (final s in speeds)
              PopupMenuItem<double>(
                value: s,
                child: Row(
                  children: [
                    if ((s - current).abs() < 0.001)
                      Icon(Icons.check, size: 16, color: cs.primary)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${s}x',
                      style: TextStyle(
                        fontWeight:
                            (s - current).abs() < 0.001
                                ? FontWeight.w700
                                : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
          ],
    );
  }
}
