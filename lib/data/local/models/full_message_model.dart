import '../app_database.dart';
import 'message_translation_model.dart';

class FullMessageModel {
  final int id;
  final String title;
  final MessageTranslationModel translation;

  FullMessageModel({
    required this.id,
    required this.title,
    required this.translation,
  });

  factory FullMessageModel.fromDb({
    required Message message,
    required MessageTranslation translation,
  }) {
    return FullMessageModel(
      id: message.id,
      title: message.title,
      translation: MessageTranslationModel.fromDb(translation),
    );
  }
}