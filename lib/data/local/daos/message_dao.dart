// data/local/message_dao.dart
import 'package:drift/drift.dart';
import 'package:alghaya_men_alkhalg/data/local/app_database.dart';

import '../tables/message_table.dart';
import '../tables/translations_table.dart';

part 'message_dao.g.dart';


@DriftAccessor(tables: [Messages, Translations])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Stream<List<MessageWithTranslations>> watchMessagesWithAllTranslations() {
    final tr = attachedDatabase.translations;

    final q = select(messages).join([
      leftOuterJoin(
        tr,
        tr.messageId.equalsExp(messages.id),
      ),
    ])..orderBy([OrderingTerm.desc(messages.createdAt)]);

    return q.watch().map((rows) {
      final map = <int, MessageWithTranslations>{};

      for (final r in rows) {
        final m = r.readTable(messages);
        final t = r.readTableOrNull(tr);

        final curr = map[m.id];
        if (curr == null) {
          map[m.id] = MessageWithTranslations(
            message: m,
            translations: t != null ? [t] : <Translation>[],
          );
        } else if (t != null) {
          map[m.id] = MessageWithTranslations(
            message: curr.message,
            translations: [...curr.translations, t],
          );
        }
      }
      return map.values.toList();
    });
  }
}

