import 'package:drift/drift.dart';

/// Outbox table for Contact Us messages (offline queue)
class ContactOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();
  TextColumn get message => text()();
  TextColumn get email => text().nullable()();
  TextColumn get appVersion => text()();
  TextColumn get platform => text()();
  TextColumn get locale => text()();
  TextColumn get deviceModel => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

/// Outbox table for Content Reports (offline queue)
class ContentReportsOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get messageId => integer()();
  TextColumn get languageCode => text()();
  TextColumn get reportType => text()();
  TextColumn get comment => text().nullable()();
  TextColumn get appVersion => text()();
  TextColumn get platform => text()();
  TextColumn get locale => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}
