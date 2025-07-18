import '../app_database.dart';

class MessageTranslationModel {
  final int id;
  final int messageId;
  final String languageCode;
  final String content;
  final String? audioPath;
  final DateTime updatedAt;

  MessageTranslationModel({
    required this.id,
    required this.messageId,
    required this.languageCode,
    required this.content,
    this.audioPath,
    required this.updatedAt,
  });

  factory MessageTranslationModel.fromDb(MessageTranslation row) {
    return MessageTranslationModel(
      id: row.id,
      messageId: row.messageId,
      languageCode: row.languageCode,
      content: row.content,
      audioPath: row.audioPath,
      updatedAt: row.updatedAt,
    );
  }
}
