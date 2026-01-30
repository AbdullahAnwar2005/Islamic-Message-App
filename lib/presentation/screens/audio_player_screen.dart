// lib/presentation/screens/audio_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/local/app_database.dart';

import '../../providers/audio_download_progress_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/message_language_provider.dart';
import '../../providers/message_provider.dart';
import '../../utils/arabic_language_names.dart';
import '../../utils/choose_translation_utility.dart';
import '../../utils/message_extensions.dart'; // import extensions
import '../../core/feedback_utils.dart';
import '../../localization/app_strings.dart';

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final int messageId;

  const AudioPlayerScreen({super.key, required this.messageId});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen> {
  double? _scrubValue;
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final messagesAsync = ref.watch(messagesWithTranslationsProvider);
    final langOverrides = ref.watch(messageLangOverridesProvider);
    final appLang = ref.watch(appLanguageProvider);

    ref.listen<Map<int, String>>(messageLangOverridesProvider, (prev, next) {
      final old = prev?[widget.messageId];
      final newL = next[widget.messageId];
      if (newL != null && newL != old) {
        _onLanguageChanged(newL);
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: messagesAsync.when(
          data: (list) {
            final bundle = list.firstWhere(
              (e) => e.message.id == widget.messageId,
              orElse: () => list.first,
            );

            final rawLang = langOverrides[widget.messageId] ?? appLang;
            final displayLang = norm(rawLang!);

            final currentIndex = list.indexWhere(
              (e) => e.message.id == widget.messageId,
            );

            // Helper to find next/prev with audio
            int? findPlayableIndex(int start, int direction) {
              int i = start + direction;
              while (i >= 0 && i < list.length) {
                final item = list[i];
                final t = pickTranslation(item.translations, displayLang);
                final url = _extractAudioUrl(t);
                if (url != null && url.isNotEmpty) {
                  return i;
                }
                i += direction;
              }
              return null;
            }

            final prevIndex = findPlayableIndex(currentIndex, -1);
            final nextIndex = findPlayableIndex(currentIndex, 1);

            // Get available languages
            final availableLangs =
                bundle.translations
                    .map((t) => norm(t.languageCode))
                    .whereType<String>()
                    .toSet()
                    .toList();

            final playerState = ref.watch(audioPlayerProvider);
            // Only show active state if this screen's message is the one playing
            final isActive = playerState.activeMessageId == widget.messageId;

            // Create a "view" of the state for this screen
            final player =
                isActive
                    ? playerState
                    : const AudioPlayerState(); // Default/Idle state for non-active messages
            final localPathAsync = ref.watch(
              audioLocalPathProvider((id: widget.messageId, lang: displayLang)),
            );

            final tr = pickTranslation(bundle.translations, displayLang);
            final audioUrl = _extractAudioUrl(tr);

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  _buildHeader(
                    context,
                    bundle.message.localizedTitle(appLang),
                    displayLang,
                    scheme,
                  ),

                  const SizedBox(height: 24),

                  // Album art / Play button area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildAlbumArt(
                      context,
                      ref,
                      player,
                      localPathAsync,
                      audioUrl,
                      bundle.message.localizedTitle(appLang),
                      displayLang,
                      scheme,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Message title and description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bundle.message.localizedTitle(appLang),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _extractDescription(tr?.content ?? ''),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Language selector chips
                  if (availableLangs.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.of(context, 'audio_language_label'),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLanguageChips(
                            availableLangs,
                            displayLang,
                            scheme,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildProgressBar(player, scheme),
                  ),

                  const SizedBox(height: 16),

                  // Playback controls
                  // Playback controls
                  _buildPlaybackControls(
                    context,
                    ref,
                    player,
                    localPathAsync,
                    audioUrl,
                    bundle.message.localizedTitle(appLang),
                    displayLang,
                    scheme,
                    hasPrev: prevIndex != null,
                    hasNext: nextIndex != null,
                    onPrev: () {
                      if (prevIndex != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AudioPlayerScreen(
                                  messageId: list[prevIndex].message.id,
                                ),
                          ),
                        );
                      }
                    },
                    onNext: () {
                      if (nextIndex != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AudioPlayerScreen(
                                  messageId: list[nextIndex].message.id,
                                ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Additional controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildAdditionalControls(
                      scheme,
                      player,
                      displayLang,
                      audioUrl,
                      localPathAsync,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, st) => Center(
                child: Text(
                  AppStrings.of(
                    context,
                    'audio_loading_error',
                  ).replaceFirst('{0}', '$e'),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title,
    String langCode,
    ColorScheme scheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              langCode.toUpperCase(),
              style: TextStyle(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(
    BuildContext context,
    WidgetRef ref,
    AudioPlayerState player,
    AsyncValue<String?> localPathAsync,
    String? audioUrl,
    String title,
    String langCode,
    ColorScheme scheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.4)
                      : scheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                () => _togglePlay(
                  ref,
                  player,
                  localPathAsync,
                  audioUrl,
                  title,
                  langCode,
                ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child:
                    _isBusy
                        ? CircularProgressIndicator(color: scheme.onPrimary)
                        : Icon(
                          player.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 60,
                          color: scheme.onPrimary,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Handle auto-switch when language changes
  void _onLanguageChanged(String? newLang) {
    if (newLang == null) return;

    // Get the bundle to find URL/Title
    final asyncMessages = ref.read(messagesWithTranslationsProvider);
    if (!asyncMessages.hasValue) return;

    final list = asyncMessages.value!;
    final bundle = list.firstWhere(
      (e) => e.message.id == widget.messageId,
      orElse: () => list.first,
    );

    final tr = pickTranslation(bundle.translations, newLang);
    final audioUrl = _extractAudioUrl(tr);

    _switchLanguageAndPlay(newLang, bundle.message.title, audioUrl);
  }

  Future<void> _switchLanguageAndPlay(
    String langCode,
    String title,
    String? audioUrl,
  ) async {
    // 1. Get local path
    final localPathAsync = ref.read(
      audioLocalPathProvider((id: widget.messageId, lang: langCode)),
    );
    String? localPath = localPathAsync.value;

    // 2. Download if needed
    if (localPath == null || localPath.isEmpty) {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        try {
          showTopSnackBar(
            context,
            AppStrings.of(context, 'changing_language_audio'),
          );

          await ref
              .read(audioDownloadServiceProvider)
              .download(widget.messageId, langCode, audioUrl);
          // Invalidate to get new path
          ref.invalidate(
            audioLocalPathProvider((id: widget.messageId, lang: langCode)),
          );
          // Read again
          final newAsync = await ref.read(
            audioLocalPathProvider((
              id: widget.messageId,
              lang: langCode,
            )).future,
          );
          localPath = newAsync;
        } catch (e) {
          if (mounted) {
            showTopSnackBar(
              context,
              AppStrings.of(context, 'audio_download_error'),
              isError: true,
            );
          }
          return;
        }
      } else {
        return;
      }
    }

    if (localPath == null) return;

    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      // 3. Load and Play
      final ctrl = ref.read(audioPlayerProvider.notifier);
      await ctrl.loadSource(
        messageId: widget.messageId,
        mediaId: '${widget.messageId}:$langCode',
        path: localPath,
        title: title,
      );
      // Force play (start again)
      ctrl.play();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Widget _buildLanguageChips(
    List<String> languages,
    String currentLang,
    ColorScheme scheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          languages.map((lang) {
            final isSelected = lang == currentLang;

            // Shared logic with Home Screen for consistency
            final bgUnselected =
                isDark ? const Color(0xFF2C2C2C) : const Color(0xFFECEFF1);
            final labelUnselected =
                isDark ? const Color(0xFFB0BEC5) : const Color(0xFF455A64);
            final labelSelected = isDark ? Colors.black : Colors.white;

            return FilterChip(
              label: Text(
                arabicLanguageName(lang),
                style: TextStyle(
                  color: isSelected ? labelSelected : labelUnselected,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref
                      .read(messageLangOverridesProvider.notifier)
                      .setOverride(widget.messageId, lang);
                }
              },
              backgroundColor: bgUnselected,
              selectedColor: scheme.primary,
              checkmarkColor: labelSelected,
              showCheckmark: false,
              side:
                  isSelected
                      ? BorderSide.none
                      : BorderSide(
                        color: isDark ? Colors.white12 : Colors.transparent,
                      ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildProgressBar(AudioPlayerState player, ColorScheme scheme) {
    final durMs = player.duration?.inMilliseconds ?? 0;
    final posMs = player.position?.inMilliseconds ?? 0;
    final sliderValue =
        (durMs > 0) ? (_scrubValue ?? (posMs / durMs).clamp(0.0, 1.0)) : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: scheme.primary,
            inactiveTrackColor: scheme.primary.withOpacity(0.25),
            thumbColor: scheme.primary,
            overlayColor: scheme.primary.withOpacity(0.15),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: sliderValue,
            onChanged: (v) {
              setState(() {
                _scrubValue = v;
              });
            },
            onChangeEnd: (v) async {
              setState(() {
                _scrubValue = null;
              });
              if (durMs > 0) {
                final targetMs = (durMs * v).round();
                final ctrl = ref.read(audioPlayerProvider.notifier);
                await ctrl.seek(Duration(milliseconds: targetMs));
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(player.position),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              Text(
                _formatDuration(player.duration),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    WidgetRef ref,
    AudioPlayerState player,
    AsyncValue<String?> localPathAsync,
    String? audioUrl,
    String title,
    String langCode,
    ColorScheme scheme, {
    required bool hasPrev,
    required bool hasNext,
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 40,
          onPressed: hasPrev ? onPrev : null,
        ),

        const SizedBox(width: 16),

        // Play/Pause button (large)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap:
                  () => _togglePlay(
                    ref,
                    player,
                    localPathAsync,
                    audioUrl,
                    title,
                    langCode,
                  ),
              child:
                  _isBusy
                      ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          color: scheme.onPrimary,
                        ),
                      )
                      : Icon(
                        player.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 48,
                        color: scheme.onPrimary,
                      ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Next button
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 40,
          onPressed: hasNext ? onNext : null,
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(
    ColorScheme scheme,
    AudioPlayerState player,
    String displayLang,
    String? audioUrl,
    AsyncValue<String?> localPathAsync,
  ) {
    final isDownloaded = localPathAsync.value != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.speed_outlined,
          label: AppStrings.of(
            context,
            'speed_label',
          ).replaceFirst('{0}', '${player.speed}'),
          onTap: () {
            final current = player.speed;
            final next = _nextSpeed(current);
            ref.read(audioPlayerProvider.notifier).setSpeed(next);
          },
        ),
        if (!isDownloaded) ...[
          // Manual download button removed as per checking logic in _togglePlay
        ],
      ],
    );
  }

  double _nextSpeed(double current) {
    const speeds = [1.0, 1.25, 1.5, 2.0, 0.5, 0.75];
    // Find closest index
    int index = 0;
    double minDiff = 999;
    for (int i = 0; i < speeds.length; i++) {
      final diff = (speeds[i] - current).abs();
      if (diff < minDiff) {
        minDiff = diff;
        index = i;
      }
    }
    return speeds[(index + 1) % speeds.length];
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: scheme.onPrimary),
            const SizedBox(width: 8),
            Text(
              label.replaceAll('\n', ' '),
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlay(
    WidgetRef ref,
    AudioPlayerState player,
    AsyncValue<String?> localPathAsync,
    String? audioUrl,
    String title,
    String langCode,
  ) async {
    final localPath = localPathAsync.value;

    if (_isBusy) return;

    final ctrl = ref.read(audioPlayerProvider.notifier);

    if (localPath == null || localPath.isEmpty) {
      // Local missing -> Auto-download then play
      if (audioUrl != null && audioUrl.isNotEmpty) {
        setState(() => _isBusy = true);
        showTopSnackBar(
          context,
          AppStrings.of(context, 'downloading_progress'),
        );

        try {
          // 1. Download
          await ref
              .read(audioDownloadServiceProvider)
              .download(widget.messageId, langCode, audioUrl);

          // 2. Refresh provider to get new path
          ref.invalidate(
            audioLocalPathProvider((id: widget.messageId, lang: langCode)),
          );
          final newPath = await ref.read(
            audioLocalPathProvider((
              id: widget.messageId,
              lang: langCode,
            )).future,
          );

          if (newPath == null || newPath.isEmpty) {
            throw Exception('Download succeeded but path is empty');
          }

          if (mounted) {
            showTopSnackBar(
              context,
              AppStrings.of(context, 'download_completed'),
            );
          }

          // 3. Play
          await ctrl.loadSource(
            messageId: widget.messageId,
            mediaId: '${widget.messageId}:$langCode',
            path: newPath,
            title: title,
          );
          ctrl.play();
        } catch (e) {
          if (mounted)
            showTopSnackBar(
              context,
              AppStrings.of(
                context,
                'download_failed',
              ).replaceFirst('{0}', '$e'),
              isError: true,
            );
        } finally {
          if (mounted) setState(() => _isBusy = false);
        }
      } else {
        // No audio source at all
        if (mounted)
          showTopSnackBar(
            context,
            AppStrings.of(context, 'no_audio_source'),
            isError: true,
          );
      }
      return;
    }

    setState(() => _isBusy = true);
    try {
      if (player.sourcePath != localPath) {
        await ctrl.loadSource(
          messageId: widget.messageId,
          mediaId: '${widget.messageId}:$langCode',
          path: localPath,
          title: title,
        );
      }

      if (player.isPlaying) {
        ctrl.pause();
      } else {
        ctrl.play();
      }
    } catch (e) {
      if (mounted)
        showTopSnackBar(
          context,
          AppStrings.of(context, 'local_audio_error').replaceFirst('{0}', '$e'),
          isError: true,
        );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String? _extractAudioUrl(dynamic tr) {
    if (tr is Translation) {
      final path = tr.audioUrl;
      if (path == null || path.isEmpty) return null;
      // If full URL
      if (path.startsWith('http')) return path;
      // Resolve relative path
      return Supabase.instance.client.storage.from('audio').getPublicUrl(path);
    }
    return null;
  }

  String _extractDescription(String fullText) {
    final lines = fullText.split('\n');
    bool seenTitle = false;
    final b = StringBuffer();
    for (final raw in lines) {
      final l = raw.trim();
      if (l.startsWith('##')) {
        seenTitle = true;
        continue;
      }
      if (seenTitle && l.isNotEmpty) {
        b.writeln(l);
        if (b.length > 150) break;
      }
    }
    return b.toString().trim();
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '00:00';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
