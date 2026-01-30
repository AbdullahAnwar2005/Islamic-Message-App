import 'package:drift/drift.dart';

class Sections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()(); // e.g., "القرآن الكريم", "الحديث الشريف"
  TextColumn get slug => text().unique()(); // e.g. 'quran', 'hadith'
  IntColumn get sortOrder => integer().nullable()(); // 1, 2, 3...
}
