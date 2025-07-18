import 'package:drift/drift.dart';

class Messages extends Table {
  IntColumn get id => integer()(); // نحدد الـ id يدويًا من JSON
  TextColumn get title => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
