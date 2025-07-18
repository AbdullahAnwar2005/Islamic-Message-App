
import '../local/app_database.dart';
import '../local/models/full_message_model.dart';

class MessageRepository {
  final AppDatabase db;

  MessageRepository(this.db);

  Future<FullMessageModel?> getMessageWithTranslation(int messageId, String languageCode) async {
    final message = await db.getMessageById(messageId);
    final translation = await db.getTranslationByMessageIdAndLanguage(messageId, languageCode);

    if (message != null && translation != null) {
      return FullMessageModel.fromDb(message: message, translation: translation);
    }

    return null;
  }

  Future<List<FullMessageModel>> getAllMessagesByLanguage(String languageCode) async {
    final messagesList = await db.getAllMessages();
    final List<FullMessageModel> fullMessages = [];

    for (final message in messagesList) {
      final translation = await db.getTranslationByMessageIdAndLanguage(message.id, languageCode);
      if (translation != null) {
        fullMessages.add(
          FullMessageModel.fromDb(
            message: message,
            translation: translation,
          ),
        );
      }
    }

    return fullMessages;
  }
}
