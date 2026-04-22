import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/message_table.dart';
import '../tables/translations_table.dart';

part 'message_read_dao.g.dart';

class MessageWithTranslation {
  final Message message;
  final Translation translation;
  MessageWithTranslation(this.message, this.translation);
}

@DriftAccessor(tables: [Messages, Translations])
class MessageReadDao extends DatabaseAccessor<AppDatabase>
    with _$MessageReadDaoMixin {
  MessageReadDao(super.db);

  Stream<MessageWithTranslation?> watchMessageWithLang(
      int messageId,
      String lang, {
        String? fallbackLang,
      }) {
    final base = select(messages)..where((m) => m.id.equals(messageId));
    final tPrimary = translations;
    final tFallback =
    fallbackLang != null ? alias(translations, 't_fallback') : null;

    final joinQuery = base.join([
      leftOuterJoin(
        tPrimary,
        tPrimary.messageId.equalsExp(messages.id) &
        tPrimary.languageCode.equals(lang),
      ),
      if (tFallback != null)
        leftOuterJoin(
          tFallback,
          tFallback.messageId.equalsExp(messages.id) &
          tFallback.languageCode.equals(fallbackLang!),
        ),
    ]);

    return joinQuery.watchSingleOrNull().map((row) {
      if (row == null) return null;
      final msg = row.readTable(messages);
      final tr = row.readTableOrNull(tPrimary) ??
          (tFallback != null ? row.readTableOrNull(tFallback) : null);
      if (tr == null) return null;
      return MessageWithTranslation(msg, tr);
    });
  }
}
