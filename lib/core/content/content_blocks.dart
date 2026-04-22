/// Content block parser — pure Dart, no Flutter dependency.
///
/// Rules match the website/backend exactly:
/// - Header: line starts with "##"
/// - Quran:  line contains ﴿ or ﴾
/// - Text:   contiguous non-empty lines grouped into paragraphs

enum BlockType { header, quran, text }

class ContentBlock {
  final BlockType type;
  final String text;
  const ContentBlock({required this.type, required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentBlock &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          text == other.text;

  @override
  int get hashCode => type.hashCode ^ text.hashCode;

  @override
  String toString() =>
      'ContentBlock($type, "${text.length > 40 ? '${text.substring(0, 40)}...' : text}")';
}

/// Parse raw content string into a list of typed blocks.
List<ContentBlock> parseContentToBlocks(String content) {
  if (content.isEmpty) return const [];

  // Normalize CRLF → LF
  final normalized = content.replaceAll('\r\n', '\n');
  final lines = normalized.split('\n');

  final blocks = <ContentBlock>[];
  final textBuffer = <String>[];

  void flushTextBuffer() {
    if (textBuffer.isEmpty) return;
    blocks.add(ContentBlock(type: BlockType.text, text: textBuffer.join('\n')));
    textBuffer.clear();
  }

  for (final line in lines) {
    final trimmedLeft = line.trimLeft();

    if (trimmedLeft.startsWith('##')) {
      // Header block — strip leading ## and trim
      flushTextBuffer();
      final headerText = trimmedLeft.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      if (headerText.isNotEmpty) {
        blocks.add(ContentBlock(type: BlockType.header, text: headerText));
      }
    } else if (line.contains('\uFD3F') || line.contains('\uFD3E')) {
      // Quran block — line contains ﴿ or ﴾
      flushTextBuffer();
      blocks.add(ContentBlock(type: BlockType.quran, text: line.trim()));
    } else if (line.trim().isEmpty) {
      // Empty line — flush current text paragraph
      flushTextBuffer();
    } else {
      // Regular text line — accumulate
      textBuffer.add(line);
    }
  }

  flushTextBuffer();
  return blocks;
}

/// Build a TTS payload from blocks.
///
/// - Includes ONLY [BlockType.text] blocks
/// - Replaces internal newlines with spaces within each block
/// - Joins blocks with double newlines
String buildTtsPayload(List<ContentBlock> blocks) {
  return blocks
      .where((b) => b.type == BlockType.text)
      .map((b) => b.text.replaceAll('\n', ' '))
      .join('\n\n');
}
