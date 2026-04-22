import 'package:drift/drift.dart';

import 'message_table.dart';

class Translations extends Table {
  IntColumn get messageId =>
      integer().references(
        Messages,
        #id,
        onDelete: KeyAction.cascade,
      )(); // cascade
  TextColumn get languageCode => text()();
  TextColumn get title =>
      text().withDefault(const Constant(''))(); // Localized title
  TextColumn get content => text()();
  TextColumn get audioUrl =>
      text()
          .nullable()(); // Local-only path to cached audio file (never synced to remote)
  TextColumn get audioPath => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {messageId, languageCode};

  @override
  List<String> get indexes => [
    'CREATE INDEX idx_translations_lang ON translations (language_code)',
    'CREATE INDEX idx_translations_updated_at ON translations (updated_at)',
    // PK already covers (message_id, language_code); extra composite index not needed.
  ];
}
