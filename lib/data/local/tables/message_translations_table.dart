import 'package:drift/drift.dart';

class MessageTranslations extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get messageId => integer()
      .customConstraint('REFERENCES messages(id) ON DELETE CASCADE')();


  TextColumn get languageCode => text()();
  TextColumn get content => text()();
  TextColumn get audioPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
