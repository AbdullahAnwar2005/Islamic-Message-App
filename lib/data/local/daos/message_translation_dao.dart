import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/translations_table.dart';

part 'message_translation_dao.g.dart';

@DriftAccessor(tables: [Translations])
class MessageTranslationDao extends DatabaseAccessor<AppDatabase>
    with _$MessageTranslationDaoMixin {
  MessageTranslationDao(super.db);

  Future<int> upsert(TranslationsCompanion data) =>
      into(translations).insertOnConflictUpdate(data);

  Future<Translation?> byMsgLang(int messageId, String lang) {
    final q = select(translations)
      ..where((t) => t.messageId.equals(messageId) & t.languageCode.equals(lang));
    return q.getSingleOrNull();
  }

  Stream<Translation?> watchByMsgLang(int messageId, String lang) {
    final q = select(translations)
      ..where((t) => t.messageId.equals(messageId) & t.languageCode.equals(lang));
    return q.watchSingleOrNull();
  }
}
