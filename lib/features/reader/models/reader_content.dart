class Chapter {
  final String id;
  final String title;
  final String paragraphKeyStart;
  const Chapter({required this.id, required this.title, required this.paragraphKeyStart});
}

class Paragraph {
  final String key;
  final String text;
  final String? chapterId;
  const Paragraph({required this.key, required this.text, this.chapterId});
}

class MessageContent {
  final String id;
  final String title;
  final String languageCode;
  final List<Chapter> chapters;
  final List<Paragraph> paragraphs;
  const MessageContent({
    required this.id,
    required this.title,
    required this.languageCode,
    required this.chapters,
    required this.paragraphs,
  });
}
