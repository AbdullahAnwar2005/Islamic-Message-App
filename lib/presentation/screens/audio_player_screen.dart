// lib/presentation/screens/audio_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/semantics.dart'; // For SemanticsService
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';

import '../../data/local/app_database.dart';
import '../../providers/audio_download_progress_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/message_language_provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/progress_providers.dart';
import '../../providers/transcript_providers.dart';
import '../../core/content/content_blocks.dart';
import '../../utils/arabic_language_names.dart';
import '../../utils/choose_translation_utility.dart';
import '../../utils/message_extensions.dart';
import '../../core/feedback_utils.dart';
import '../../localization/app_strings.dart';
import '../../providers/follow_audio_provider.dart';
import '../../providers/audio_transcript_font_size_provider.dart';

// Widgets
import '../../presentation/widgets/audio_settings_sheet.dart';

enum AudioControlState {
  idle,
  downloading,
  ready,
  buffering,
  playing,
  paused,
  error,
}

class AudioPlayerScreen extends ConsumerStatefulWidget {
  final int messageId;

  const AudioPlayerScreen({super.key, required this.messageId});

  @override
  ConsumerState<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends ConsumerState<AudioPlayerScreen> {
  double? _scrubValue;
  AudioControlState _controlState = AudioControlState.idle;

  // Transcript state
  bool _isCompactMode = false;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  ProviderSubscription<Map<int, String>>? _langOverrideSub;

  String? _resumeMessage;

  // Track sheet size

  static const double _minSheetSize = 0.16;
  static const double _initialSheetSize = 0.16;
  static const double _maxSheetSize = 0.9;

  // Font constraints
  static const double _minFont = 14.0;
  static const double _maxFont = 28.0;

  @override
  void initState() {
    super.initState();

    _langOverrideSub = ref.listenManual<Map<int, String>>(
      messageLangOverridesProvider,
      (prev, next) {
        final old = prev?[widget.messageId];
        final newL = next[widget.messageId];
        if (newL != null && newL != old) {
          final player = ref.read(audioPlayerProvider);
          if (player.activeMessageId == widget.messageId && old != null) {
            ref
                .read(progressServiceProvider)
                .saveAudioProgress(
                  messageId: widget.messageId.toString(),
                  audioLanguageCode: old,
                  positionMs: player.position.inMilliseconds,
                  playbackRate: player.speed,
                );
          }
          _onLanguageChanged(newL);
        }
      },
    );
  }

  @override
  void dispose() {
    _langOverrideSub?.close();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final messagesAsync = ref.watch(messagesWithTranslationsProvider);
    final langOverrides = ref.watch(messageLangOverridesProvider);
    final appLang = ref.watch(appLanguageProvider);

    return messagesAsync.when(
      data: (list) {
        final bundle =
            list.where((e) => e.message.id == widget.messageId).firstOrNull;
        // M-3 FIX: show explicit error if message not found (instead of
        // silently displaying the first message in the list)
        if (bundle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(AppStrings.of(context, 'loading_error'))),
          );
        }

        final rawLang = langOverrides[widget.messageId] ?? appLang;
        final displayLang = norm(rawLang!);

        final playerState = ref.watch(audioPlayerProvider);
        final isActive = playerState.activeMessageId == widget.messageId;
        final player = isActive ? playerState : const AudioPlayerState();

        final localPathAsync = ref.watch(
          audioLocalPathProvider((id: widget.messageId, lang: displayLang)),
        );

        final tr = pickTranslation(bundle.translations, displayLang);
        final audioUrl = _extractAudioUrl(tr);
        final content = tr?.content ?? '';

        // Derive blocks args — no provider writes during build
        final bKey = (
          messageId: widget.messageId,
          langCode: displayLang,
          content: content,
        );

        final availableLangs =
            bundle.translations
                .map((t) => norm(t.languageCode))
                .whereType<String>()
                .toSet()
                .toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              bundle.message.localizedTitle(appLang),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: AppStrings.of(context, 'settings_label'),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: _openSettingsSheet,
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final screenH = constraints.maxHeight;
              final minSheetHeightPx = screenH * _minSheetSize;

              return Stack(
                children: [
                  // MAIN CONTENT
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          minSheetHeightPx + 24,
                        ),
                        child: Column(
                          children: [
                            _buildCompactHeaderCard(
                              context,
                              bundle.message.localizedTitle(appLang),
                              displayLang,
                              scheme,
                              player,
                            ),
                            const SizedBox(height: 32),

                            _buildProgressBar(
                              player,
                              scheme,
                              availableLangs,
                              displayLang,
                            ),

                            if (_resumeMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _resumeMessage!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            _buildRefinedControls(
                              context,
                              ref,
                              player,
                              localPathAsync,
                              audioUrl,
                              bundle.message.localizedTitle(appLang),
                              displayLang,
                              scheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // TRANSCRIPT SHEET
                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: _initialSheetSize,
                    minChildSize: _minSheetSize,
                    maxChildSize: _maxSheetSize,
                    snap: true,
                    builder: (context, scrollController) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final pixelHeight = constraints.maxHeight;
                          final screenHeight =
                              MediaQuery.of(context).size.height;
                          final isExpanded =
                              pixelHeight > (screenHeight * 0.22);

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildSheetHeader(
                                  context: context,
                                  scheme: scheme,
                                  player: player,
                                  localPathAsync: localPathAsync,
                                  audioUrl: audioUrl,
                                  title: bundle.message.localizedTitle(appLang),
                                  langCode: displayLang,
                                  content: content,
                                  isExpanded: isExpanded,
                                ),
                                const Divider(height: 1),
                                Expanded(
                                  child: Stack(
                                    children: [
                                      TranscriptBody(
                                        scrollController: scrollController,
                                        cacheKey: bKey,
                                        isExpanded: isExpanded,
                                        scheme: scheme,
                                        isCompactMode: _isCompactMode,
                                      ),
                                      if (isExpanded)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: _buildTranscriptBottomBar(
                                            context: context,
                                            scheme: scheme,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.of(context, 'audio_player_error'),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed:
                        () => ref.invalidate(messagesWithTranslationsProvider),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppStrings.of(context, 'retry')),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildCompactHeaderCard(
    BuildContext context,
    String title,
    String lang,
    ColorScheme scheme,
    AudioPlayerState player,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  arabicLanguageName(lang),
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: scheme.outline.withOpacity(0.2)),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    player.duration > Duration.zero
                        ? _formatDuration(player.duration)
                        : '--:--',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    AudioPlayerState player,
    ColorScheme scheme,
    List<String> availableLangs,
    String currentLang,
  ) {
    if (player.isLoading) {
      return Center(
        child: Text(
          AppStrings.of(context, 'audio_loading_progress'),
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
    }

    final durMs = player.duration.inMilliseconds;
    final posMs = player.position.inMilliseconds;
    final sliderValue = (_scrubValue ?? (durMs > 0 ? posMs / durMs : 0.0))
        .clamp(0.0, 1.0);

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
          child: Semantics(
            slider: true,
            label: AppStrings.of(context, 'audio_progress_bar'),
            child: Slider(
              value: sliderValue,
              onChanged:
                  player.isLoading
                      ? null
                      : (v) => setState(() => _scrubValue = v),
              onChangeEnd: (v) async {
                setState(() => _scrubValue = null);
                if (durMs > 0) {
                  final targetMs = (durMs * v).round();
                  final ctrl = ref.read(audioPlayerProvider.notifier);
                  await ctrl.seek(Duration(milliseconds: targetMs));
                  ref
                      .read(progressServiceProvider)
                      .saveAudioProgress(
                        messageId: widget.messageId.toString(),
                        audioLanguageCode: currentLang,
                        positionMs: targetMs,
                        playbackRate: player.speed,
                      );
                }
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(player.position),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatDuration(player.duration),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefinedControls(
    BuildContext context,
    WidgetRef ref,
    AudioPlayerState player,
    AsyncValue<String?> localPathAsync,
    String? audioUrl,
    String title,
    String langCode,
    ColorScheme scheme,
  ) {
    // FIXED: Determine text direction for proper button placement
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // REWIND button (left)
        Tooltip(
          message: AppStrings.of(context, 'rewind_10s'),
          child: Semantics(
            label: AppStrings.of(context, 'rewind_10s'),
            button: true,
            child: IconButton(
              icon: const Icon(
                Icons.replay_10_rounded,
              ), // NAV-02: time direction doesn't flip
              iconSize: 36,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              color: scheme.onSurface,
              onPressed: () {
                final newPos = player.position - const Duration(seconds: 10);
                ref
                    .read(audioPlayerProvider.notifier)
                    .seek(newPos < Duration.zero ? Duration.zero : newPos);
              },
            ),
          ),
        ),
        const SizedBox(width: 32),

        // Download progress indicator and Play/Pause button container
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Separate download progress area
            if (_controlState == AudioControlState.downloading ||
                (ref.watch(
                      audioDownloadProgressForFileProvider((
                        player.activeMessageId ?? widget.messageId,
                        langCode,
                      )),
                    ) !=
                    null))
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: 80,
                  height: 4,
                  child: LinearProgressIndicator(
                    color: scheme.primary,
                    backgroundColor: scheme.primary.withOpacity(0.2),
                  ),
                ),
              )
            else if (_controlState == AudioControlState.buffering ||
                player.isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: scheme.primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              const SizedBox(height: 12),

            SizedBox(
              width: 80,
              height: 80,
              child: Semantics(
                label:
                    player.isPlaying
                        ? (isRTL ? 'إيقاف مؤقت' : 'Pause')
                        : (isRTL ? 'تشغيل' : 'Play'),
                button: true,
                child: FloatingActionButton(
                  elevation: 4,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: const CircleBorder(),
                  onPressed:
                      () => _togglePlay(
                        ref,
                        player,
                        localPathAsync,
                        audioUrl,
                        title,
                        langCode,
                      ),
                  child: Icon(
                    player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 48,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 32),

        // FORWARD button (right)
        Tooltip(
          message: AppStrings.of(context, 'forward_10s'),
          child: Semantics(
            label: AppStrings.of(context, 'forward_10s'),
            button: true,
            child: IconButton(
              icon: const Icon(
                Icons.forward_10_rounded,
              ), // NAV-02: time direction doesn't flip
              iconSize: 36,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              color: scheme.onSurface,
              onPressed: () {
                final dur = player.duration;
                final target = player.position + const Duration(seconds: 10);
                final clamped =
                    (dur > Duration.zero && target > dur) ? dur : target;
                ref.read(audioPlayerProvider.notifier).seek(clamped);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetHeader({
    required BuildContext context,
    required ColorScheme scheme,
    required AudioPlayerState player,
    required AsyncValue<String?> localPathAsync,
    required String? audioUrl,
    required String title,
    required String langCode,
    required String content,
    required bool isExpanded,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (!_sheetController.isAttached) return;
          final target = (_sheetController.size < 0.5) ? 0.6 : _minSheetSize;
          _sheetController.animateTo(
            target,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Centered Handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),

              // 2. Title + Mini Player Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.of(context, 'transcript_title'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 6),
                          Text(
                            _firstNonEmptyLine(content),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    constraints: BoxConstraints.tight(const Size(48, 48)),
                    icon: Icon(
                      player.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 32,
                      color: scheme.primary,
                    ),
                    onPressed:
                        () => _togglePlay(
                          ref,
                          player,
                          localPathAsync,
                          audioUrl,
                          title,
                          langCode,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranscriptBottomBar({
    required BuildContext context,
    required ColorScheme scheme,
  }) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          10 + (bottomInset > 0 ? 0 : 0),
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(color: scheme.outlineVariant.withOpacity(0.6)),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Sync highlight toggle
              Consumer(
                builder: (context, ref, _) {
                  final syncOn = ref.watch(syncEnabledProvider);
                  return Tooltip(
                    message:
                        syncOn
                            ? AppStrings.of(context, 'sync_toggle_on')
                            : AppStrings.of(context, 'sync_toggle_off'),
                    child: IconButton(
                      onPressed:
                          () => ref.read(syncEnabledProvider.notifier).toggle(),
                      icon: Icon(syncOn ? Icons.sync : Icons.sync_disabled),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      color: syncOn ? scheme.primary : scheme.onSurface,
                    ),
                  );
                },
              ),
              // Follow-audio auto-scroll toggle
              Consumer(
                builder: (context, ref, _) {
                  final followOn = ref.watch(followAudioEnabledProvider);
                  return Tooltip(
                    message:
                        followOn
                            ? AppStrings.of(context, 'follow_toggle_on')
                            : AppStrings.of(context, 'follow_toggle_off'),
                    child: IconButton(
                      onPressed:
                          () => ref
                              .read(followAudioEnabledProvider.notifier)
                              .setEnabled(!followOn),
                      icon: Icon(
                        followOn
                            ? Icons.my_location
                            : Icons.location_disabled_rounded,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      color: followOn ? scheme.primary : scheme.onSurface,
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: scheme.outlineVariant.withOpacity(0.8),
              ),
              const SizedBox(width: 8),

              // Font size controls
              Consumer(
                builder: (context, ref, _) {
                  final fontSize = ref.watch(audioTranscriptFontSizeProvider);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'زيادة حجم الخط',
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(audioTranscriptFontSizeProvider.notifier)
                                .setFontSize(
                                  (fontSize + 1).clamp(_minFont, _maxFont),
                                );
                          },
                          icon: const Icon(Icons.text_increase),
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          color: scheme.onSurface,
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '${fontSize.toStringAsFixed(0)}sp',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'تقليل حجم الخط',
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(audioTranscriptFontSizeProvider.notifier)
                                .setFontSize(
                                  (fontSize - 1).clamp(_minFont, _maxFont),
                                );
                          },
                          icon: const Icon(Icons.text_decrease),
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: scheme.outlineVariant.withOpacity(0.8),
              ),
              const SizedBox(width: 8),

              // Reading density toggle
              Tooltip(
                message: _isCompactMode ? 'وضع مريح' : 'وضع مدمج',
                child: IconButton(
                  onPressed:
                      () => setState(() => _isCompactMode = !_isCompactMode),
                  icon: Icon(
                    _isCompactMode ? Icons.view_agenda : Icons.view_day,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- SETTINGS SHEET ----------

  void _openSettingsSheet() {
    final player = ref.read(audioPlayerProvider);
    final list = ref.read(messagesWithTranslationsProvider).value ?? [];
    if (list.isEmpty) return;

    final bundle = list.firstWhere(
      (e) => e.message.id == widget.messageId,
      orElse: () => list.first,
    );

    final rawLang =
        ref.read(messageLangOverridesProvider)[widget.messageId] ??
        ref.read(appLanguageProvider);
    final displayLang = norm(rawLang!);

    final availableLangs =
        bundle.translations
            .map((t) => norm(t.languageCode))
            .whereType<String>()
            .toSet()
            .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => AudioSettingsSheet(
            currentSpeed: player.speed,
            onSpeedChanged: (val) {
              ref.read(audioPlayerProvider.notifier).setSpeed(val);
            },
            currentLanguage: displayLang,
            availableLanguages: availableLangs,
            onLanguageChanged: (lang) {
              ref
                  .read(messageLangOverridesProvider.notifier)
                  .setOverride(widget.messageId, lang);
            },
            isDownloading: false,
            downloadingLanguage: null,
          ),
    );
  }

  // ---------- LOGIC METHODS ----------

  Future<void> _togglePlay(
    WidgetRef ref,
    AudioPlayerState player,
    AsyncValue<String?> localPathAsync,
    String? audioUrl,
    String title,
    String langCode,
  ) async {
    final localPath = localPathAsync.value;
    if (_controlState == AudioControlState.downloading ||
        _controlState == AudioControlState.buffering) {
      return;
    }

    final ctrl = ref.read(audioPlayerProvider.notifier);

    if (localPath == null || localPath.isEmpty) {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        setState(() => _controlState = AudioControlState.downloading);
        showTopSnackBar(
          context,
          AppStrings.of(context, 'downloading_progress'),
        );

        try {
          await ref
              .read(audioDownloadServiceProvider)
              .download(widget.messageId, langCode, audioUrl);

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

          final file = File(newPath);
          if (!await file.exists() || await file.length() == 0) {
            throw Exception('Downloaded file is missing or empty.');
          }

          if (mounted) {
            showTopSnackBar(
              context,
              AppStrings.of(context, 'download_completed'),
            );
          }

          if (mounted) setState(() => _controlState = AudioControlState.ready);

          // Transition explicitly: ready -> buffering -> playing
          if (mounted)
            setState(() => _controlState = AudioControlState.buffering);
          await ctrl.loadSource(
            messageId: widget.messageId,
            mediaId: '${widget.messageId}:$langCode',
            path: newPath,
            title: title,
          );
          if (mounted)
            setState(() => _controlState = AudioControlState.playing);
          ctrl.play();
        } catch (e) {
          if (mounted) {
            setState(() => _controlState = AudioControlState.error);
            showTopSnackBar(
              context,
              AppStrings.of(context, 'audio_download_error'),
              isError: true,
            );
          }
          debugPrint('[AudioPlayer] Download Failed: $e');
        } finally {
          if (mounted && _controlState == AudioControlState.downloading) {
            setState(() => _controlState = AudioControlState.idle);
          }
        }
      } else {
        if (mounted) {
          showTopSnackBar(
            context,
            AppStrings.of(context, 'no_audio_source'),
            isError: true,
          );
        }
      }
      return;
    }

    setState(() => _controlState = AudioControlState.buffering);
    if (mounted) {
      SemanticsService.tooltip(AppStrings.of(context, 'audio_loading'));
    }

    try {
      if (player.sourcePath != localPath) {
        await ctrl.loadSource(
          messageId: widget.messageId,
          mediaId: '${widget.messageId}:$langCode',
          path: localPath,
          title: title,
        );

        // Resume from saved progress
        final progress = await ref
            .read(progressServiceProvider)
            .getAudioProgress(
              messageId: widget.messageId.toString(),
              audioLanguageCode: langCode,
            );
        if (progress != null && progress.lastAudioPositionMs > 0) {
          await ctrl.seek(Duration(milliseconds: progress.lastAudioPositionMs));

          if (mounted) {
            final timeStr = _formatDuration(
              Duration(milliseconds: progress.lastAudioPositionMs),
            );
            final msg = AppStrings.of(
              context,
              'resume_at_time',
            ).replaceFirst('{0}', timeStr);
            setState(() => _resumeMessage = msg);

            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) setState(() => _resumeMessage = null);
            });
          }
        }
      }

      if (player.isPlaying) {
        ctrl.pause();
        setState(() => _controlState = AudioControlState.paused);
        ref
            .read(progressServiceProvider)
            .saveAudioProgress(
              messageId: widget.messageId.toString(),
              audioLanguageCode: langCode,
              positionMs: player.position.inMilliseconds,
              playbackRate: player.speed,
            );
      } else {
        ctrl.play();
        setState(() => _controlState = AudioControlState.playing);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _controlState = AudioControlState.error);
        showTopSnackBar(
          context,
          AppStrings.of(context, 'audio_playback_error'),
          isError: true,
        );
      }
      debugPrint('[AudioPlayer] Playback Error: $e');
    } finally {
      if (mounted && _controlState == AudioControlState.buffering) {
        setState(() => _controlState = AudioControlState.idle);
      }
    }
  }

  void _onLanguageChanged(String? newLang) {
    if (newLang == null) return;
    if (_controlState == AudioControlState.downloading ||
        _controlState == AudioControlState.buffering) {
      return;
    }

    final asyncMessages = ref.read(messagesWithTranslationsProvider);
    if (!asyncMessages.hasValue) return;

    final list = asyncMessages.value!;
    final bundle =
        list.where((e) => e.message.id == widget.messageId).firstOrNull;
    if (bundle == null) return; // M-3: don't show wrong content

    final tr = pickTranslation(bundle.translations, newLang);
    final audioUrl = _extractAudioUrl(tr);

    _switchLanguageAndPlay(newLang, bundle.message.displayTitle, audioUrl);
  }

  Future<void> _switchLanguageAndPlay(
    String langCode,
    String title,
    String? audioUrl,
  ) async {
    final localPathAsync = ref.read(
      audioLocalPathProvider((id: widget.messageId, lang: langCode)),
    );
    String? localPath = localPathAsync.value;

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

          ref.invalidate(
            audioLocalPathProvider((id: widget.messageId, lang: langCode)),
          );

          localPath = await ref.read(
            audioLocalPathProvider((
              id: widget.messageId,
              lang: langCode,
            )).future,
          );
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
    if (_controlState == AudioControlState.downloading) return;

    setState(() => _controlState = AudioControlState.buffering);
    try {
      final ctrl = ref.read(audioPlayerProvider.notifier);
      await ctrl.loadSource(
        messageId: widget.messageId,
        mediaId: '${widget.messageId}:$langCode',
        path: localPath,
        title: title,
      );
      ctrl.play();
      if (mounted) setState(() => _controlState = AudioControlState.playing);
    } catch (e) {
      if (mounted) setState(() => _controlState = AudioControlState.error);
      debugPrint('[AudioPlayer] Playback Error: $e');
    } finally {
      if (mounted && _controlState == AudioControlState.buffering) {
        setState(() => _controlState = AudioControlState.idle);
      }
    }
  }

  String? _extractAudioUrl(dynamic tr) {
    if (tr is Translation) {
      final path = tr.audioUrl;
      if (path == null || path.isEmpty) return null;
      return path;
    }
    return null;
  }

  // ---------- HELPERS ----------

  String norm(String code) => code.toLowerCase().trim();

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String _firstNonEmptyLine(String s) {
    if (s.isEmpty) return '';
    final lines = s.split('\n');
    for (final l in lines) {
      final t = l.trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }
}

class TranscriptBody extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final BlocksArgs cacheKey;
  final bool isExpanded;
  final ColorScheme scheme;
  final bool isCompactMode;

  const TranscriptBody({
    super.key,
    required this.scrollController,
    required this.cacheKey,
    required this.isExpanded,
    required this.scheme,
    required this.isCompactMode,
  });

  @override
  ConsumerState<TranscriptBody> createState() => _TranscriptBodyState();
}

class _TranscriptBodyState extends ConsumerState<TranscriptBody> {
  // ── GlobalKeys for each block (incremental, never fully recreated) ──
  List<GlobalKey> _blockKeys = [];

  // ── Auto-scroll state ──
  int? _lastAutoScrolledIndex;
  bool _programmaticScroll = false;
  DateTime _cooldownUntil = DateTime.fromMillisecondsSinceEpoch(0);
  bool get _inCooldown => DateTime.now().isBefore(_cooldownUntil);
  void _extendCooldown() {
    _cooldownUntil = DateTime.now().add(const Duration(seconds: 2));
  }

  // ── Listener lifecycle ──
  ProviderSubscription<int?>? _activeBlockSub;

  @override
  void initState() {
    super.initState();
    _setupListener(widget.cacheKey);
  }

  @override
  void didUpdateWidget(covariant TranscriptBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cacheKey != widget.cacheKey) {
      _activeBlockSub?.close();
      _lastAutoScrolledIndex = null;
      _setupListener(widget.cacheKey);
    }
  }

  @override
  void dispose() {
    _activeBlockSub?.close();
    super.dispose();
  }

  void _setupListener(BlocksArgs key) {
    _activeBlockSub = ref.listenManual<int?>(activeBlockIndexProvider(key), (
      prev,
      next,
    ) {
      if (next == null) return;
      _scrollToIndexIfNeeded(next);
    });
  }

  // ── Scroll logic (Patch 3.6, Tightening A/B/C) ──

  void _scrollToIndexIfNeeded(int idx) {
    final followEnabled = ref.read(followAudioEnabledProvider);
    if (!followEnabled) return;
    if (!mounted) return;
    if (idx < 0 || idx >= _blockKeys.length) return;
    if (_inCooldown) return;
    if (idx == _lastAutoScrolledIndex) return;

    final ctx = _blockKeys[idx].currentContext;
    if (ctx == null) return;

    _lastAutoScrolledIndex = idx;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Double-check inside post-frame (Tightening C)
      final ctx2 = _blockKeys[idx].currentContext;
      if (ctx2 == null) return;

      const d = Duration(milliseconds: 300);
      _programmaticScroll = true;
      Scrollable.ensureVisible(
        ctx2,
        alignment: 0.2,
        duration: d,
        curve: Curves.easeOut,
      );
      // Unlock after duration + 100ms (Tightening A)
      Future.delayed(d + const Duration(milliseconds: 100), () {
        if (mounted) _programmaticScroll = false;
      });
    });
  }

  // ── Scroll notification handler ──

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_programmaticScroll) return false; // ignore self-triggered

    if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      _extendCooldown();
    } else if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _extendCooldown();
    }
    return false;
  }

  // ── Incremental GlobalKeys (Patch 3.2) ──

  void _ensureBlockKeys(int count) {
    if (_blockKeys.length < count) {
      _blockKeys = [
        ..._blockKeys,
        for (var i = _blockKeys.length; i < count; i++) GlobalKey(),
      ];
    } else if (_blockKeys.length > count) {
      _blockKeys = _blockKeys.sublist(0, count);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpanded) {
      return CustomScrollView(
        controller: widget.scrollController,
        slivers: const [SliverToBoxAdapter(child: SizedBox.shrink())],
      );
    }

    final blocks = ref.watch(parsedBlocksProvider(widget.cacheKey));

    if (blocks.isEmpty) {
      return CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            sliver: SliverToBoxAdapter(
              child: Text(
                'لا يوجد نص متاح لهذا المحتوى.',
                style: TextStyle(color: widget.scheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      );
    }

    _ensureBlockKeys(blocks.length);

    // Patch 3.7: GestureDetector for sheet drag guard
    return GestureDetector(
      onPanDown: (_) => _extendCooldown(),
      behavior: HitTestBehavior.translucent,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              sliver: SliverList.builder(
                itemCount: blocks.length,
                itemBuilder: (context, index) {
                  return KeyedSubtree(
                    key: _blockKeys[index],
                    child: _BlockItemWidget(
                      block: blocks[index],
                      blockIndex: index,
                      cacheKey: widget.cacheKey,
                      scheme: widget.scheme,
                      isCompactMode: widget.isCompactMode,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual block widget that selectively rebuilds only when its
/// active highlight state changes.
class _BlockItemWidget extends ConsumerWidget {
  final ContentBlock block;
  final int blockIndex;
  final BlocksArgs cacheKey;
  final ColorScheme scheme;
  final bool isCompactMode;

  const _BlockItemWidget({
    required this.block,
    required this.blockIndex,
    required this.cacheKey,
    required this.scheme,
    required this.isCompactMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(audioTranscriptFontSizeProvider);
    // Only text blocks can be highlighted — read active index selectively
    final syncEnabled = ref.watch(syncEnabledProvider);
    final isActive =
        block.type == BlockType.text && syncEnabled
            ? ref.watch(
              activeBlockIndexProvider(
                cacheKey,
              ).select((idx) => idx == blockIndex),
            )
            : false;

    switch (block.type) {
      case BlockType.header:
        return _buildHeader(context);
      case BlockType.quran:
        return _buildQuran(context, fontSize);
      case BlockType.text:
        return _buildText(context, isActive, fontSize);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        block.text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.primary,
          height: 1.4,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildQuran(BuildContext context, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.primary.withOpacity(0.15)),
          ),
          child: Text(
            block.text,
            style: TextStyle(
              fontSize: fontSize + 4,
              height: 2.0,
              color: scheme.onSurface,
              fontFamily: 'UthmanicHafs',
              fontFamilyFallback: const ['NotoNaskhArabic', 'Arial'],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, bool isActive, double fontSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color:
            isActive
                ? scheme.primaryContainer.withOpacity(0.35)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border:
            isActive
                ? Border.all(color: scheme.primary.withOpacity(0.2))
                : null,
      ),
      child: Text(
        block.text,
        style: TextStyle(
          fontSize: fontSize,
          height: isCompactMode ? 1.35 : 1.75,
          color: scheme.onSurface,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
