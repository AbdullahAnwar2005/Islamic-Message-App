import 'package:flutter/material.dart';
import 'dart:async';

/// Scrollable transcript view with TOC, search, font controls, and reading mode
/// Implements optimized scroll position saving (on scrollEnd, dispose, or long debounce)
class TranscriptViewWidget extends StatefulWidget {
  final String content;
  final ScrollController scrollController;
  final ValueChanged<double> onScrollPositionChanged;
  final double initialScrollOffset;
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;
  final bool isCompactMode;
  final VoidCallback onToggleReadingMode;

  const TranscriptViewWidget({
    super.key,
    required this.content,
    required this.scrollController,
    required this.onScrollPositionChanged,
    this.initialScrollOffset = 0.0,
    this.fontSize = 18.0,
    required this.onFontSizeChanged,
    this.isCompactMode = false,
    required this.onToggleReadingMode,
  });

  @override
  State<TranscriptViewWidget> createState() => _TranscriptViewWidgetState();
}

class _TranscriptViewWidgetState extends State<TranscriptViewWidget> {
  Timer? _scrollDebounceTimer;
  double? _pendingScrollOffset;
  String _searchQuery = '';
  List<int> _searchMatches = [];
  int _currentMatchIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);

    // Restore initial scroll position
    if (widget.initialScrollOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController.hasClients) {
          widget.scrollController.jumpTo(widget.initialScrollOffset);
        }
      });
    }
  }

  @override
  void dispose() {
    // Save scroll position on dispose
    _saveScrollPosition();
    _scrollDebounceTimer?.cancel();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    final offset = widget.scrollController.offset;
    _pendingScrollOffset = offset;

    // Long debounce (1500-2000ms) for automatic saves
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 1800), () {
      _saveScrollPosition();
    });
  }

  void _saveScrollPosition() {
    if (_pendingScrollOffset != null) {
      widget.onScrollPositionChanged(_pendingScrollOffset!);
      _pendingScrollOffset = null;
    }
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchMatches = [];
        _currentMatchIndex = -1;
      });
      return;
    }

    final query = _searchQuery.toLowerCase();
    final content = widget.content.toLowerCase();
    final matches = <int>[];

    int index = content.indexOf(query);
    while (index != -1) {
      matches.add(index);
      index = content.indexOf(query, index + 1);
    }

    setState(() {
      _searchMatches = matches;
      _currentMatchIndex = matches.isNotEmpty ? 0 : -1;
    });
  }

  void _nextMatch() {
    if (_searchMatches.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _searchMatches.length;
    });
    // TODO: Scroll to match position
  }

  void _previousMatch() {
    if (_searchMatches.isEmpty) return;
    setState(() {
      _currentMatchIndex =
          (_currentMatchIndex - 1 + _searchMatches.length) %
          _searchMatches.length;
    });
    // TODO: Scroll to match position
  }

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSearchSheet(),
    );
  }

  void _showTableOfContents() {
    final sections = _parseContentSections();

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildTOCSheet(sections),
    );
  }

  List<({String title, int index})> _parseContentSections() {
    // Simple section parsing: split by double newlines or markdown headings
    final lines = widget.content.split('\n');
    final sections = <({String title, int index})>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      // Check for markdown headings
      if (line.startsWith('#')) {
        final title = line.replaceAll(RegExp(r'^#+\s*'), '');
        sections.add((title: title, index: i));
      }
    }

    // If no headings found, create sections by paragraphs
    if (sections.isEmpty) {
      var paragraphCount = 1;
      for (int i = 0; i < lines.length; i += 10) {
        sections.add((title: 'Section $paragraphCount', index: i));
        paragraphCount++;
      }
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
        120; // Player height + safe area

    return Column(
      children: [
        // Toolbar with Font controls, Search, TOC, Reading mode
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Font size decrease
              _buildToolButton(
                icon: Icons.text_decrease,
                label: 'Decrease font size',
                onPressed:
                    () => widget.onFontSizeChanged(
                      (widget.fontSize - 2).clamp(12.0, 32.0),
                    ),
              ),

              // Current font size indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${widget.fontSize.toInt()}sp',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Font size increase
              _buildToolButton(
                icon: Icons.text_increase,
                label: 'Increase font size',
                onPressed:
                    () => widget.onFontSizeChanged(
                      (widget.fontSize + 2).clamp(12.0, 32.0),
                    ),
              ),

              const SizedBox(width: 16),

              // Search button
              _buildToolButton(
                icon: Icons.search,
                label: 'Search in text',
                onPressed: _showSearchBar,
              ),

              const SizedBox(width: 8),

              // Table of Contents button
              _buildToolButton(
                icon: Icons.list,
                label: 'Table of contents',
                onPressed: _showTableOfContents,
              ),

              const Spacer(),

              // Reading mode toggle
              _buildToolButton(
                icon:
                    widget.isCompactMode
                        ? Icons.view_comfortable
                        : Icons.view_compact,
                label:
                    widget.isCompactMode ? 'Comfortable mode' : 'Compact mode',
                onPressed: widget.onToggleReadingMode,
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                _saveScrollPosition();
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: widget.isCompactMode ? 12.0 : 20.0,
                bottom: bottomPadding,
              ),
              child: SelectableText.rich(
                _buildParsedContent(theme, colorScheme),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _buildParsedContent(ThemeData theme, ColorScheme colorScheme) {
    final lines = widget.content.split('\n');
    final List<TextSpan> spans = [];
    final baseStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: widget.fontSize,
      height: widget.isCompactMode ? 1.4 : 1.8,
      color: colorScheme.onSurface,
    );
    final headerStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: widget.fontSize * 1.2,
      color: colorScheme.primary,
    );

    for (var line in lines) {
      if (line.trim().startsWith('##')) {
        // H2
        final text = line.trim().replaceAll(RegExp(r'^#+\s*'), '');
        spans.add(TextSpan(text: '$text\n', style: headerStyle));
      } else if (line.trim().startsWith('#')) {
        // H1
        final text = line.trim().replaceAll(RegExp(r'^#+\s*'), '');
        spans.add(
          TextSpan(
            text: '$text\n',
            style: headerStyle?.copyWith(fontSize: widget.fontSize * 1.4),
          ),
        );
      } else {
        // Body
        spans.add(TextSpan(text: '$line\n', style: baseStyle));
      }
    }
    return TextSpan(children: spans);
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(icon, size: 24, color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSheet() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search in text...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchMatches.isNotEmpty
                      ? Text(
                        '${_currentMatchIndex + 1}/${_searchMatches.length}',
                        style: theme.textTheme.bodySmall,
                      )
                      : null,
            ),
            onChanged: (value) {
              _searchQuery = value;
              _performSearch();
            },
          ),
          if (_searchMatches.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _previousMatch,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: 'Previous result',
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _nextMatch,
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: 'Next result',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTOCSheet(List<({String title, int index})> sections) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table of Contents',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return ListTile(
                  title: Text(section.title),
                  onTap: () {
                    // TODO: Scroll to section
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
