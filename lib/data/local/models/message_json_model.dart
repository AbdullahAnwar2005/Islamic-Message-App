class MessageJsonModel {
  final String title;
  final List<TranslationJsonModel> translations;

  MessageJsonModel({required this.title, required this.translations});

  factory MessageJsonModel.fromJson(Map<String, dynamic> json) {
    return MessageJsonModel(
      title: json['title'],
      translations: (json['translations'] as List)
          .map((t) => TranslationJsonModel.fromJson(t))
          .toList(),
    );
  }
}

class TranslationJsonModel {
  final String languageCode;
  final String content;
  final String? audioPath;

  TranslationJsonModel({
    required this.languageCode,
    required this.content,
    this.audioPath,
  });

  factory TranslationJsonModel.fromJson(Map<String, dynamic> json) {
    return TranslationJsonModel(
      languageCode: json['languageCode'],
      content: json['content'],
      audioPath: json['audioPath'],
    );
  }
}
