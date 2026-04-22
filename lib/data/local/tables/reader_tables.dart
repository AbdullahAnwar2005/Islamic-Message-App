import 'package:drift/drift.dart';

class ReadingSettingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  TextColumn get pageStyle => text().withDefault(const Constant('scroll'))();
  RealColumn get fontSize => real().withDefault(const Constant(18.0))();
  RealColumn get lineHeight => real().withDefault(const Constant(1.5))();
  TextColumn get fontFamily =>
      text().withDefault(const Constant('NotoNaskhArabic'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class ReadingProgressTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get textLanguageCode => text().withDefault(const Constant('ar'))();
  RealColumn get percent => real().withDefault(const Constant(0.0))();
  RealColumn get scrollOffset => real().withDefault(const Constant(0.0))();
  IntColumn get pageIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageId, textLanguageCode}, // one row per message+language
  ];
}

class AudioProgressTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get audioLanguageCode => text()();
  IntColumn get lastAudioPositionMs =>
      integer().withDefault(const Constant(0))();
  RealColumn get playbackRate => real().withDefault(const Constant(1.0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageId, audioLanguageCode}, // one row per message+audio language
  ];
}

class BookmarksTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get paragraphKey => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageId, paragraphKey}, // avoid duplicate bookmarks
  ];
}

class HighlightsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get startParagraphKey => text()();
  TextColumn get endParagraphKey => text()();
  IntColumn get startCharOffset => integer()();
  IntColumn get endCharOffset => integer()();
  TextColumn get color => text().withDefault(const Constant('yellow'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AudioSessionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text().unique()(); // already unique
  IntColumn get lastPositionMs => integer().withDefault(const Constant(0))();
  RealColumn get playbackRate => real().withDefault(const Constant(1.0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class AudioCuesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get paragraphKey => text()();
  IntColumn get startMs => integer()();
  IntColumn get endMs => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {
      messageId,
      paragraphKey,
      startMs,
    }, // a cue is unique by (message, paragraph, start)
  ];
}
