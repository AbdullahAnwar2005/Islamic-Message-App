// lib/presentation/screens/read_screen.dart
// Reader Experience Design 6 — refined UX & sturdier plumbing
// + Dynamic GlobalAudioBar visibility based on audio availability

import '../../utils/message_extensions.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:alghaya_men_alkhalg/data/local/app_database.dart'
    show Translation; // Only import Translation

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// —— Reader domain & presentation ——
import '../../features/reader/mappers/translation_to_message_content.dart';
import '../../features/reader/models/reader_content.dart'
    show MessageContent, Chapter, Paragraph;

// —— Reader state ——
import '../../features/reader/providers/bookmarks_provider.dart'
    show bookmarksProvider, Bookmark;

import '../../features/reader/providers/reader_settings_provider.dart'
    show readerSettingsProvider;
import '../../features/reader/providers/screen_scroll_provider.dart'
    show chromeVisibilityProvider;
import '../../features/reader/providers/reader_progress_provider.dart'
    show readerProgressProvider;
import '../../features/reader/services/last_read_service.dart';

// —— Data & language ——
import '../../features/reader/ui/reader_text_style.dart'
    show buildReaderTextStyle;

// —— Sheets & bars ——
import '../../features/reader/widgets/aa_sheet_widget.dart' show AaSheet;
import '../../features/reader/widgets/bookmarks_sheet_widget.dart'
    show BookmarksSheet;
import '../../features/reader/widgets/chapters_sheet_widget.dart'
    show ChaptersSheet;
import '../../features/reader/widgets/paragraph_block_widget.dart'
    show ParagraphBlockWidget;
import '../../features/reader/widgets/reader_controls_bar.dart';

// —— App content streams ——
import '../../providers/audio_download_progress_provider.dart';
import '../../providers/message_language_provider.dart'
    show appLanguageProvider, messageLangOverridesProvider;
import '../../providers/message_provider.dart'
    show messagesWithTranslationsProvider, MessageWithTranslations;

// —— Global background audio bar (bottom-most) ——

import '../../utils/choose_translation_utility.dart';
import '../widgets/mini_audio_player.dart';
import '../../core/feedback_utils.dart';
import '../widgets/report_content_bottom_sheet.dart';
import '../../providers/analytics_provider.dart';

// ---- Layout constants ----
import '../../localization/app_strings.dart';

class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({
    super.key,
    required this.messageId,
    this.initialChapterIndex,
  });
  final int messageId;
  final int? initialChapterIndex;

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen>
    with SingleTickerProviderStateMixin {
  // Analytics
  final DateTime _readStartTime = DateTime.now();
  bool _hasTrackedOpen = false;
  int? _currentSectionId;
  String? _currentLang;

  // Visual chrome fade
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..value = 1;

  // View mode state
  bool _isPageView = false;

  // Scroll & hint state
  final ScrollController _scrollCtl = ScrollController();
  final PageController _pageCtl = PageController();
  final ValueNotifier<double> _scrollHintOpacity = ValueNotifier(1);
  double _lastPixels = 0;
  bool _seenAnyScroll = false;
  bool _initialScrollDone = false;

  // —— Chapter anchors ——
  final List<GlobalKey> _chapterKeys = [];
  int _chaptersCount = 0;

  // Cached anchor offsets
  final List<double?> _anchorOffsets = [];

  // Live active & completion
  int _currentChapterIndex = 0;
  int _lastVisitedChapter = 0;
  final Set<int> _completedChapters = <int>{};

  void _ensureChapterKeys(int count) {
    _chaptersCount = count;
    if (_chapterKeys.length == count && _anchorOffsets.length == count) return;

    _chapterKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));

    _anchorOffsets
      ..clear()
      ..addAll(List<double?>.filled(count, null));

    _completedChapters.removeWhere((i) => i < 0 || i >= count);
    _currentChapterIndex = _currentChapterIndex.clamp(
      0,
      math.max(0, count - 1),
    );
    _lastVisitedChapter = _lastVisitedChapter.clamp(0, math.max(0, count - 1));
  }

  // Measure anchors
  void _captureAnchorOffsets() {
    if (_chapterKeys.isEmpty || !_scrollCtl.hasClients) return;

    for (var i = 0; i < _chapterKeys.length; i++) {
      final ctx = _chapterKeys[i].currentContext;
      final ro = ctx?.findRenderObject();
      if (ro == null) continue;
      final viewport = RenderAbstractViewport.of(ro);
      if (viewport == null) continue;

      final offset = viewport.getOffsetToReveal(ro, 0.08).offset;
      _anchorOffsets[i] = offset;
    }
  }

  int _computeCurrentChapterIndex() {
    if (_chapterKeys.isEmpty) return 0;
    final viewportTop =
        kToolbarHeight + MediaQuery.of(context).padding.top + 12;

    int current = 0;
    for (var i = 0; i < _chapterKeys.length; i++) {
      final ctx = _chapterKeys[i].currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= viewportTop + 2) {
        current = i;
      } else {
        // fuck
      }
    }
    return current.clamp(0, _chapterKeys.length - 1);
  }

  // Two-phase jump
  Future<void> _scrollToChapter(int chapterIndex, {int attempt = 0}) async {
    if (_isPageView) {
      _pageCtl.jumpToPage(chapterIndex);
      setState(() {
        _currentChapterIndex = chapterIndex;
        _lastVisitedChapter = math.max(_lastVisitedChapter, chapterIndex);
        _completedChapters.add(chapterIndex);
      });
      return;
    }

    if (!_scrollCtl.hasClients ||
        chapterIndex < 0 ||
        chapterIndex >= _chaptersCount)
      return;

    final known =
        (chapterIndex < _anchorOffsets.length)
            ? _anchorOffsets[chapterIndex]
            : null;
    if (known != null) {
      await _scrollCtl.animateTo(
        known.clamp(
          _scrollCtl.position.minScrollExtent,
          _scrollCtl.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureAnchorOffsets();
        final again = _anchorOffsets[chapterIndex];
        if (again != null) {
          _scrollCtl.animateTo(
            again.clamp(
              _scrollCtl.position.minScrollExtent,
              _scrollCtl.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
          );
        }
        final idx = _computeCurrentChapterIndex();
        if (idx != _currentChapterIndex)
          setState(() => _currentChapterIndex = idx);
      });
      return;
    }

    // Approximate via neighbor
    double? approx;
    int neighborIndex = -1;

    // Search backwards
    for (int i = chapterIndex; i >= 0; i--) {
      if (_anchorOffsets[i] != null) {
        approx = _anchorOffsets[i]!;
        neighborIndex = i;
        break;
      }
    }
    // Search forwards if needed
    if (approx == null) {
      for (int i = chapterIndex; i < _chaptersCount; i++) {
        if (_anchorOffsets[i] != null) {
          approx = _anchorOffsets[i]!;
          neighborIndex = i;
          break;
        }
      }
    }

    // Calculate average height
    final knownOffsets = _anchorOffsets.whereType<double>().toList()..sort();
    final avgHeight =
        (knownOffsets.length >= 2)
            ? (knownOffsets.last - knownOffsets.first) /
                (knownOffsets.length - 1)
            : (_scrollCtl.position.maxScrollExtent / (_chaptersCount + 1));

    if (approx != null && neighborIndex != -1) {
      // Extrapolate from neighbor
      approx = approx + ((chapterIndex - neighborIndex) * avgHeight);
    } else {
      // Pure guess
      approx = (avgHeight * chapterIndex);
    }

    approx = approx!.clamp(
      _scrollCtl.position.minScrollExtent,
      _scrollCtl.position.maxScrollExtent,
    );

    await _scrollCtl.animateTo(
      approx!,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );

    if (attempt < 3) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureAnchorOffsets();
        _scrollToChapter(chapterIndex, attempt: attempt + 1);
      });
    }
  }

  // —— Bookmark quick-add ——
  Future<void> _addBookmark(MessageContent content) async {
    if (!_scrollCtl.hasClients) return;

    // Find the visible paragraph
    final chapter = content.chapters[_currentChapterIndex];
    int bestParaIndex = 0;
    String bestParaKey = '';
    String bestExcerpt = '';

    double bestDy = 999999;

    for (var i = 0; i < chapter.paragraphs.length; i++) {
      final p = chapter.paragraphs[i];
      final key = GlobalObjectKey(p.key);
      final ctx = key.currentContext;
      if (ctx == null) continue;

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final position = box.localToGlobal(Offset.zero);
      final dy = position.dy;

      if (dy > -50 && dy < 400) {
        if (dy < bestDy) {
          bestDy = dy;
          bestParaIndex = i;
          bestParaKey = p.key;
          bestExcerpt = p.text;
        }
      } else if (dy <= -50 && (dy + box.size.height) > 100) {
        bestDy = -999;
        bestParaIndex = i;
        bestParaKey = p.key;
        bestExcerpt = p.text;
        break;
      }
    }

    if (bestExcerpt.isEmpty && chapter.paragraphs.isNotEmpty) {
      bestParaIndex = 0;
      bestParaKey = chapter.paragraphs[0].key;
      bestExcerpt = chapter.paragraphs[0].text;
    } else if (bestExcerpt.isEmpty) {
      bestExcerpt =
          chapter.title ??
          '${AppStrings.of(context, 'chapter')} ${_currentChapterIndex + 1}';
    }

    if (bestExcerpt.length > 100) {
      bestExcerpt = '${bestExcerpt.substring(0, 100)}...';
    }

    final b = Bookmark(
      messageId: widget.messageId,
      chapterIndex: _currentChapterIndex,
      paragraphIndex: bestParaIndex,
      paragraphKey: bestParaKey,
      excerpt: bestExcerpt,
      createdAt: DateTime.now(),
    );

    await ref.read(bookmarksProvider.notifier).add(b);

    if (!mounted) return;
    showTopSnackBar(context, AppStrings.of(context, 'bookmark_saved'));
  }

  @override
  void initState() {
    super.initState();
    _scrollCtl.addListener(_onScroll);
    _pageCtl.addListener(_onPageScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial = ref.read(readerProgressProvider(widget.messageId));
      if (!_isPageView && _scrollCtl.hasClients && initial > 0) {
        final max = _scrollCtl.position.maxScrollExtent;
        _scrollCtl.jumpTo(initial.clamp(0.0, max));
      }
      _captureAnchorOffsets();
      _currentChapterIndex = _computeCurrentChapterIndex();
      _lastVisitedChapter = _currentChapterIndex;
      _completedChapters.add(_currentChapterIndex);
      setState(() {});
    });
  }

  @override
  void deactivate() {
    ref.read(readerProgressProvider(widget.messageId).notifier).flush();
    super.deactivate();
  }

  @override
  void dispose() {
    // A11Y-01: restore edgeToEdge when leaving ReadScreen so Home/Audio screens
    // show the status bar again. ReadScreen manages immersive mode per-screen.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fadeCtrl.dispose();
    _scrollHintOpacity.dispose();
    _scrollCtl.removeListener(_onScroll);
    _scrollCtl.dispose();
    _pageCtl.removeListener(_onPageScroll);
    _pageCtl.dispose();
    _trackReadEnd();
    super.dispose();
  }

  void _trackReadEnd() {
    try {
      final durationMs =
          DateTime.now().difference(_readStartTime).inMilliseconds;
      double ratio = 0.0;

      if (_isPageView) {
        if (_chaptersCount > 0) {
          // If we completed the last chapter, 1.0. Else proportion.
          if (_completedChapters.contains(_chaptersCount - 1)) {
            ratio = 1.0;
          } else {
            ratio = (_currentChapterIndex + 1) / _chaptersCount;
          }
        }
      } else {
        if (_scrollCtl.hasClients && _scrollCtl.position.haveDimensions) {
          final max = _scrollCtl.position.maxScrollExtent;
          final current = _scrollCtl.position.pixels;
          if (max <= 100) {
            ratio = 1.0; // Short content
          } else {
            ratio = (current / max).clamp(0.0, 1.0);
          }
        }
      }

      // Heuristic for "completed": ratio > 0.9
      final completed = ratio >= 0.9;

      ref
          .read(analyticsServiceProvider)
          .track(
            'message_read_end',
            properties: {
              'message_id': widget.messageId,
              'section_id': _currentSectionId,
              'language_code': _currentLang,
              'time_spent_ms': durationMs,
              'completion_ratio': ratio,
              'completed': completed,
            },
          );
    } catch (e) {
      debugPrint('Error tracking read end: $e');
    }
  }

  void _onPageScroll() {
    if (!_seenAnyScroll) {
      _seenAnyScroll = true;
      _scrollHintOpacity.value = 0;
    }
  }

  void _onScroll() {
    if (!_seenAnyScroll && _scrollCtl.position.haveDimensions) {
      _seenAnyScroll = true;
      _scrollHintOpacity.value = 0;
    }
    if (!_scrollCtl.hasClients) return;

    final pos = _scrollCtl.position;
    final now = pos.pixels;

    const hysteresis = 8.0;
    final goingDown = now > _lastPixels + hysteresis;
    final goingUp = now < _lastPixels - hysteresis;
    _lastPixels = now;

    final chrome = ref.read(chromeVisibilityProvider.notifier);
    final isVisible = ref.read(chromeVisibilityProvider);

    if (goingDown && isVisible) {
      chrome.hide();
      _fadeCtrl.reverse();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else if (goingUp && !isVisible) {
      chrome.show();
      _fadeCtrl.forward();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    ref
        .read(readerProgressProvider(widget.messageId).notifier)
        .save(pos.pixels);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAnchorOffsets();
      final idx = _computeCurrentChapterIndex();
      if (idx != _currentChapterIndex) {
        setState(() {
          _currentChapterIndex = idx;
          _lastVisitedChapter = math.max(_lastVisitedChapter, idx);
          _completedChapters.add(idx);
          ref.read(lastReadServiceProvider).save(widget.messageId, idx);
        });
      }
    });
  }

  void _toggleChrome() {
    final notifier = ref.read(chromeVisibilityProvider.notifier);
    final visible = ref.read(chromeVisibilityProvider);
    notifier.toggle();
    if (!visible) {
      _fadeCtrl.forward();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      _fadeCtrl.reverse();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(readerSettingsProvider);
    final messagesAsync = ref.watch(messagesWithTranslationsProvider);
    final chromeVisible = ref.watch(chromeVisibilityProvider);

    // Sync local isPageView with settings
    _isPageView = settings.isPageView;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          offset: chromeVisible ? Offset.zero : const Offset(0, -1),
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: AppBar(
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: AppStrings.of(context, 'back'),
              ),
              title: Consumer(
                builder: (context, ref, _) {
                  final messagesAsync = ref.watch(
                    messagesWithTranslationsProvider,
                  );
                  return messagesAsync.when(
                    data: (list) {
                      final bundle =
                          list
                              .where((e) => e.message.id == widget.messageId)
                              .firstOrNull;

                      if (bundle == null) return const SizedBox.shrink();

                      final rawLang =
                          ref.watch(messageLangOverridesProvider)[widget
                              .messageId] ??
                          ref.watch(appLanguageProvider);
                      final displayLang = norm(rawLang!);
                      // final tr = _pickBestTranslation(bundle, displayLang); // No longer needed for title

                      return Text(
                        bundle.message.localizedTitle(displayLang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
              actions: [
                // Report Content Button
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () {
                    final rawLang =
                        ref.read(messageLangOverridesProvider)[widget
                            .messageId] ??
                        ref.read(appLanguageProvider);
                    final displayLang = norm(rawLang!);

                    // Import the bottom sheet helper
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => _ReportBottomSheetWrapper(
                            messageId: widget.messageId,
                            languageCode: displayLang,
                          ),
                    );
                  },
                  tooltip: AppStrings.of(context, 'report_content_title'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: messagesAsync.when(
          data: (list) {
            // NAV-01: guard — show a friendly error screen instead of crashing
            // if the message was deleted remotely while cached locally.
            final bundle =
                list.where((e) => e.message.id == widget.messageId).firstOrNull;

            if (bundle == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.find_in_page_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.of(context, 'message_not_found'),
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.of(context, 'message_not_found_body'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: Text(AppStrings.of(context, 'back')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final rawLang =
                ref.watch(messageLangOverridesProvider)[widget.messageId] ??
                ref.watch(appLanguageProvider);
            final displayLang = norm(rawLang!);
            final tr = _pickBestTranslation(bundle, displayLang);

            final content = _buildContentRobust(
              bundle: bundle,
              translation: tr,
              langCode: displayLang,
            );

            // Analytics Capture
            _currentSectionId = bundle.message.sectionId;
            _currentLang = displayLang;
            if (!_hasTrackedOpen) {
              _hasTrackedOpen = true;
              ref
                  .read(analyticsServiceProvider)
                  .track(
                    'message_open',
                    properties: {
                      'message_id': widget.messageId,
                      'section_id': _currentSectionId,
                      'language_code': _currentLang,
                    },
                  );
            }

            _ensureChapterKeys(content.chapters.length);

            // Handle initial jump if provided
            if (widget.initialChapterIndex != null && !_initialScrollDone) {
              _initialScrollDone = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Also set local state immediately
                setState(() {
                  _currentChapterIndex = widget.initialChapterIndex!;
                  _lastVisitedChapter = math.max(
                    _lastVisitedChapter,
                    widget.initialChapterIndex!,
                  );
                  _completedChapters.add(widget.initialChapterIndex!);
                });
                // Then scroll
                _scrollToChapter(widget.initialChapterIndex!);
              });
            }

            // Save progress initially (so even if user doesn't scroll, we know they opened it)
            if (widget.initialChapterIndex == null && !_initialScrollDone) {
              _initialScrollDone = true;
              ref.read(lastReadServiceProvider).save(widget.messageId, 0);
            }

            final horizontalPad = _contentPadding(context);
            final isRtl = displayLang.toLowerCase().startsWith('ar');

            final textStyle = buildReaderTextStyle(
              context: context,
              isRtl: isRtl,
              fontSize: settings.fontSize,
              lineHeight: settings.lineHeight,
            );

            // Determine audio availability
            final String? audioUrl = _extractAudioUrl(tr);
            final localPathAsync = ref.watch(
              audioLocalPathProvider((id: widget.messageId, lang: displayLang)),
            );

            // Check if actually playing (to keep bar visible)
            // Check if actually playing (to keep bar visible)

            bool hasAudio = (audioUrl != null && audioUrl.isNotEmpty);
            localPathAsync.whenData((p) {
              if (p != null && p.isNotEmpty) hasAudio = true;
            });

            // Show audio bar if has audio AND Chrome Visible (MiniPlayer handles active/inactive state)
            final bool showAudioBar = hasAudio && chromeVisible;

            // Bottom padding logic: Determine total height of bottom controls
            // Base controls (~70) + Mini Audio Player height (~76 including margins) if present
            final double controlsHeight = 70 + (showAudioBar ? 76.0 : 0);

            final double bottomContentPadding = controlsHeight + 20;

            final topSafePad = MediaQuery.of(context).padding.top;

            // Only show scrolling hint if not page view, OR multiple pages exist
            final bool showHint =
                !_isPageView || (_isPageView && _chaptersCount > 1);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleChrome,
              onDoubleTap: _toggleChrome,
              child: Stack(
                children: [
                  // Content Layer
                  Positioned.fill(
                    child: Directionality(
                      textDirection:
                          isRtl ? TextDirection.rtl : TextDirection.ltr,
                      child:
                          _isPageView
                              ? _buildPageView(
                                content,
                                textStyle,
                                isRtl,
                                horizontalPad,
                                bottomContentPadding,
                              )
                              : CustomScrollView(
                                controller: _scrollCtl,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                slivers: [
                                  SliverPadding(
                                    padding: EdgeInsets.fromLTRB(
                                      horizontalPad.left,
                                      topSafePad + kToolbarHeight + 16,
                                      horizontalPad.right,
                                      bottomContentPadding + 40,
                                    ),
                                    sliver: _ContentSliver(
                                      content: content,
                                      textStyle: textStyle,
                                      isRtl: isRtl,
                                      chapterKeys: _chapterKeys,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  // First-scroll hint
                  if (showHint)
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollHintOpacity,
                      builder:
                          (_, v, __) => IgnorePointer(
                            ignoring: true,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: v,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: bottomContentPadding + 100,
                                  ),
                                  child: _ScrollHint(
                                    label:
                                        _isPageView
                                            ? AppStrings.of(
                                              context,
                                              'flip_page_hint',
                                            )
                                            : AppStrings.of(
                                              context,
                                              'scroll_hint',
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),

                  // Page Counter (Visible when controls are shown)
                  if (chromeVisible)
                    Positioned(
                      bottom: controlsHeight + 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentChapterIndex + 1} / $_chaptersCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom Controls (Unified: Settings + Audio)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    left: 0,
                    right: 0,
                    // If chrome is visible, show at bottom (0). If hidden, slide down by full height.
                    bottom: chromeVisible ? 0 : -(controlsHeight + 40),
                    child: ReaderControlsBar(
                      bottomContent:
                          showAudioBar
                              ? MiniAudioPlayer(
                                messageId: widget.messageId,
                                title: bundle.message.localizedTitle(
                                  displayLang,
                                ),
                              )
                              : null,
                      onChaptersTap: () => _openChapters(context, content),
                      onSettingsTap: () => _openAA(context),
                      onBookmarksListTap: () => _openBookmarks(context),
                      onBookmarkAddTap: () => _addBookmark(content),
                    ),
                  ),
                ],
              ),
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          error:
              (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${AppStrings.of(context, 'loading_error')}\n${e.toString()}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed:
                            () => ref.invalidate(
                              messagesWithTranslationsProvider,
                            ),
                        icon: const Icon(Icons.refresh),
                        label: Text(AppStrings.of(context, 'retry')),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  // —— Nav Actions ——

  EdgeInsets _contentPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final base = math.max(16.0, w * 0.06);
    return EdgeInsets.symmetric(horizontal: base);
  }

  void _openAA(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AaSheet(messageId: widget.messageId),
    );
  }

  Future<void> _openChapters(
    BuildContext context,
    MessageContent content,
  ) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _captureAnchorOffsets(),
    );

    final pickedIndex = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => ChaptersSheet(
            chapters: content.chapters,
            currentChapterIndex: _currentChapterIndex,
            completedChapters: _completedChapters,
          ),
    );

    if (pickedIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Immediately update local state to show it as read/visited
        _scrollToChapter(pickedIndex);
      });
    }
  }

  Future<void> _openBookmarks(BuildContext context) async {
    final pickedBookmark = await showModalBottomSheet<Bookmark>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BookmarksSheet(messageId: widget.messageId),
    );

    if (pickedBookmark != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // 1. Jump to chapter
        await _scrollToChapter(pickedBookmark.chapterIndex);

        // 2. Attempt to scroll to specific paragraph
        if (pickedBookmark.paragraphKey != null) {
          // Give a slight delay for the scroll to settle/layout to happen
          await Future.delayed(const Duration(milliseconds: 150));

          final key = GlobalObjectKey(pickedBookmark.paragraphKey!);
          final ctx = key.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.1, // slightly below top
            );
          }
        }
      });
    }
  }

  // ---------- helpers ----------
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
      return bundle.translations.first;
    }
  }

  MessageContent _buildContentRobust({
    required MessageWithTranslations bundle,
    required dynamic translation,
    required String langCode,
  }) {
    if (translation is Translation) {
      return toMessageContent(translation);
    }
    // Fallback if somehow translation is not the correct type
    return MessageContent(languageCode: langCode, chapters: const []);
  }

  String? _extractAudioUrl(dynamic translation) {
    if (translation is Translation) {
      final path = translation.audioUrl;
      if (path == null || path.isEmpty) return null;
      // If it's already a full URL, return it
      if (path.startsWith('http')) return path;
      // Otherwise, assume it's a relative path in 'audio' bucket
      return Supabase.instance.client.storage.from('audio').getPublicUrl(path);
    }
    return null;
  }

  Widget _buildPageView(
    MessageContent content,
    TextStyle style,
    bool isRtl,
    EdgeInsets hPad,
    double bottomPad,
  ) {
    return PageView.builder(
      controller: _pageCtl,
      itemCount: content.chapters.length,
      onPageChanged: (i) {
        setState(() {
          _currentChapterIndex = i;
          _lastVisitedChapter = math.max(_lastVisitedChapter, i);
          _completedChapters.add(i);
          ref.read(lastReadServiceProvider).save(widget.messageId, i);
        });
      },
      itemBuilder: (ctx, i) {
        final chapter = content.chapters[i];
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            hPad.left,
            80, // Top padding
            hPad.right,
            bottomPad + 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                chapter.title ?? 'Chapter ${i + 1}',
                style: style.copyWith(
                  fontSize: style.fontSize! * 1.2,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ...chapter.paragraphs.map(
                (p) => ParagraphBlockWidget(
                  key: GlobalObjectKey(p.key),
                  block: p,
                  textStyle: style,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContentSliver extends StatelessWidget {
  const _ContentSliver({
    required this.content,
    required this.textStyle,
    required this.isRtl,
    required this.chapterKeys,
  });

  final MessageContent content;
  final TextStyle textStyle;
  final bool isRtl;
  final List<GlobalKey> chapterKeys;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final chapter = content.chapters[index];
        return Column(
          key: chapterKeys.length > index ? chapterKeys[index] : null,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (index > 0) const SizedBox(height: 48),
            if (chapter.title != null) ...[
              Text(
                chapter.title!,
                style: textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (textStyle.fontSize ?? 18) * 1.3,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            ...chapter.paragraphs.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ParagraphBlockWidget(
                  key: GlobalObjectKey(p.key),
                  block: p,
                  textStyle: textStyle,
                ),
              ),
            ),
            if (index == content.chapters.length - 1)
              const SizedBox(height: 100),
          ],
        );
      }, childCount: content.chapters.length),
    );
  }
}

class _ScrollHint extends StatelessWidget {
  const _ScrollHint({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

// Wrapper widget to provide Riverpod context for the bottom sheet
class _ReportBottomSheetWrapper extends ConsumerWidget {
  final int messageId;
  final String languageCode;

  const _ReportBottomSheetWrapper({
    required this.messageId,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReportContentBottomSheet(
      messageId: messageId,
      languageCode: languageCode,
    );
  }
}
