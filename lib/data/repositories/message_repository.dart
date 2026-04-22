import 'package:drift/drift.dart';
import '../local/app_database.dart';
import '../local/models/full_message_model.dart';

class MessageRepository {
  final AppDatabase db;
  MessageRepository(this.db);

  Future<List<FullMessageModel>> getAllMessages(String langCode) async {
    final query = db.select(db.messages).join([
      innerJoin(
        db.translations,
        db.translations.messageId.equalsExp(db.messages.id) &
        db.translations.languageCode.equals(langCode),
      ),
    ])..orderBy([OrderingTerm.asc(db.messages.id)]);

    final rows = await query.get();
    return rows.map((row) {
      final m = row.readTable(db.messages);
      final t = row.readTable(db.translations);
      return FullMessageModel.fromDb(message: m, translation: t);
    }).toList();
  }

  Future<int> getMessageCount() async {
    final countExp = db.messages.id.count();
    final r = await (db.selectOnly(db.messages)..addColumns([countExp])).getSingle();
    return r.read(countExp) ?? 0;
  }
}
