import 'dart:io';

import 'package:alghaya_men_alkhalg/data/local/tables/message_table.dart';
import 'package:alghaya_men_alkhalg/data/local/tables/message_translations_table.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(tables: [Messages, MessageTranslations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertMessage(MessagesCompanion entry) => into(messages).insert(entry);
  Future<int> insertMessageTranslation(MessageTranslationsCompanion entry) => into(messageTranslations).insert(entry);

  Future<List<Message>> getAllMessages() => select(messages).get();

  Future<Message?> getMessageById(int id) =>
      (select(messages)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<MessageTranslation>> getTranslationsForMessage(int messageId, String lang) {
    return (select(messageTranslations)
      ..where((t) => t.messageId.equals(messageId) & t.languageCode.equals(lang)))
        .get();
  }
  Future<MessageTranslation?> getTranslationByMessageIdAndLanguage(
      int messageId, String languageCode) {
    return (select(messageTranslations)
      ..where((tbl) =>
      tbl.messageId.equals(messageId) &
      tbl.languageCode.equals(languageCode)))
        .getSingleOrNull();
  }
  Future<void> clearAllMessages() async {
    await delete(messageTranslations).go();
    await delete(messages).go();
    print('🧹 All messages and translations deleted');
  }
  Future<bool> messageExists(int id) async {
    final result = await (select(messages)..where((tbl) => tbl.id.equals(id))).get();
    return result.isNotEmpty;
  }

  Future<void> insertMessageFromRemote(Map<String, dynamic> msg) async {
    await into(messages).insert(
      MessagesCompanion(
        id: Value(msg['id']),
        title: Value(msg['title']),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> insertTranslationFromRemote(Map<String, dynamic> tr) async {
    await into(messageTranslations).insert(
      MessageTranslationsCompanion(
        messageId: Value(tr['message_id']),
        languageCode: Value(tr['language_code']),
        content: Value(tr['content']),
        audioPath: Value(tr['audio_path'] ?? ''),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'messages.sqlite');
    return NativeDatabase(File(path));
  });
}
