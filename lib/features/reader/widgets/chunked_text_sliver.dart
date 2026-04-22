import 'package:flutter/widgets.dart';

import '../models/reader_content.dart';

/// Sliver that flattens chapters -> blocks and renders paragraphs.
/// Optionally render chapter headers via `chapterHeaderBuilder`.
class ChunkedTextSliver extends StatelessWidget {
  const ChunkedTextSliver({
    super.key,
    required this.content,
    required this.paragraphBuilder,
    this.chapterHeaderBuilder,
  });

  final MessageContent content;
  final Widget Function(dynamic paragraphBlock) paragraphBuilder;
  final Widget Function(dynamic chapter)? chapterHeaderBuilder;

  @override
  Widget build(BuildContext context) {
    final items = <_Item>[];

    for (final ch in content.chapters) {
      // Support either class-like or map-like chapter models
      final title = _readField(ch, 'title');
      final blocks = _readField(ch, 'blocks') as List? ?? const [];

      if (chapterHeaderBuilder != null && (title != null && title.toString().trim().isNotEmpty)) {
        items.add(_Item.header(ch)); // push a header sentinel
      }
      for (final b in blocks) {
        items.add(_Item.paragraph(b)); // push each paragraph block
      }
    }

    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it = items[i];
        return it.isHeader
            ? chapterHeaderBuilder!(it.payload)
            : paragraphBuilder(it.payload); // always a paragraph block here
      },
    );
  }
}

class _Item {
  final bool isHeader;
  final dynamic payload;
  _Item.header(this.payload) : isHeader = true;
  _Item.paragraph(this.payload) : isHeader = false;
}

/// Read `obj.field` if it's a class, or `obj['field']` if it's a map.
dynamic _readField(dynamic obj, String field) {
  try {
    // reflection-less best effort: known common patterns
    switch (field) {
      case 'title':
        return (obj as dynamic).title;
      case 'blocks':
        return (obj as dynamic).blocks;
    }
  } catch (_) {
    // fall through to map access
  }
  if (obj is Map<String, dynamic>) return obj[field];
  return null;
}
