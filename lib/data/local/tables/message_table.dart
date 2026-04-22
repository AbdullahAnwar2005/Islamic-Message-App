import 'package:drift/drift.dart';
import 'section_table.dart';

class Messages extends Table {
  IntColumn get id => integer()(); // keep explicit ids (we upsert from remote)
  TextColumn get slug => text()();
  TextColumn get title => text()();
  BoolColumn get isPublished => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get sectionId =>
      integer().nullable().references(
        Sections,
        #id,
      )(); // Nullable for robustness

  TextColumn get titleAr => text().nullable()();
  TextColumn get titleEn => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // Drift expects raw SQL strings for indexes here.
  @override
  List<String> get indexes => [
    'CREATE INDEX idx_messages_slug ON messages (slug)',
    'CREATE INDEX idx_messages_updated_at ON messages (updated_at)',
    'CREATE INDEX idx_messages_section_id ON messages (section_id)',
  ];
}
