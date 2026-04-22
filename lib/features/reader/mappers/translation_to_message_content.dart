import 'package:collection/collection.dart';
import '../../../data/local/app_database.dart' show Translation;
import '../models/reader_content.dart';

/// Build structured content from a DB `Translation`.
/// You may optionally pass `messageId` and `messageTitle` so callers (HomeScreen)
/// don’t need to re-look them up later.
MessageContent toMessageContent(
    Translation t, {
      int? messageId,
      String? messageTitle,
    }) {
  final lines = t.content.split('\n');

  List<Chapter> chapters = [];
  String? currentTitle;
  List<Paragraph> currentParas = [];
  int pIndex = 0;

  void flushParaBuffer(StringBuffer buf) {
    final txt = buf.toString().trim();
    if (txt.isNotEmpty) {
      currentParas.add(Paragraph(key: 'p${pIndex++}', text: txt));
      buf.clear();
    }
  }

  void flushChapter() {
    if ((currentTitle == null || currentTitle!.trim().isEmpty) &&
        currentParas.isEmpty) {
      return;
    }
    chapters.add(Chapter(
      title: currentTitle,
      paragraphs: List.unmodifiable(currentParas),
    ));
    currentTitle = null;
    currentParas = [];
  }

  final buf = StringBuffer();
  for (final raw in lines) {
    final l = raw.trimRight();
    if (l.startsWith('##')) {
      flushParaBuffer(buf);
      flushChapter();
      currentTitle = l.replaceFirst('##', '').trim();
    } else if (l.isEmpty) {
      flushParaBuffer(buf);
    } else {
      if (buf.isNotEmpty) buf.write('\n');
      buf.write(l);
    }
  }
  flushParaBuffer(buf);
  flushChapter();

  // If no headers were found, put everything in one chapter.
  chapters = chapters.isEmpty
      ? [
    Chapter(
      title: null,
      paragraphs: lines
          .splitBetween((a, b) => a.trim().isEmpty && b.trim().isNotEmpty)
          .mapIndexed((i, chunk) => Paragraph(
        key: 'p$i',
        text: chunk.join('\n').trim(),
      ))
          .where((p) => p.text.isNotEmpty)
          .toList(growable: false),
    )
  ]
      : chapters;

  return MessageContent(
    languageCode: t.languageCode,
    chapters: chapters,
  );
}
