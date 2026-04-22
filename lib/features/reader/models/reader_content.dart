class Paragraph {
  final String key;   // stable key for list items / bookmarks
  final String text;  // plain text (already stripped of markdown)
  const Paragraph({required this.key, required this.text});

  Paragraph copyWith({String? key, String? text}) =>
      Paragraph(key: key ?? this.key, text: text ?? this.text);
}

class Chapter {
  final String? title;
  final List<Paragraph> paragraphs;
  const Chapter({this.title, this.paragraphs = const []});

  Chapter copyWith({String? title, List<Paragraph>? paragraphs}) =>
      Chapter(title: title ?? this.title, paragraphs: paragraphs ?? this.paragraphs);
}

class MessageContent {
  final String languageCode;
  final List<Chapter> chapters;
  const MessageContent({required this.languageCode, this.chapters = const []});

  MessageContent copyWith({String? languageCode, List<Chapter>? chapters}) =>
      MessageContent(languageCode: languageCode ?? this.languageCode,
          chapters: chapters ?? this.chapters);
}
