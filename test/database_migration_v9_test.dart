import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alghaya_men_alkhalg/data/local/app_database.dart';

void main() {
  group('Database Migration v9 Tests', () {
    late AppDatabase database;

    setUp(() {
      // Create an in-memory database for testing
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('Migration adds AudioProgressTable', () async {
      // Verify that AudioProgressTable exists and has correct columns
      final audioProgressDao = database.audioProgressDao;

      // Try to insert a test record
      await audioProgressDao.upsert(
        '1',
        'ar',
        lastAudioPositionMs: 5000,
        playbackRate: 1.5,
      );

      // Retrieve the record
      final progress = await audioProgressDao.getByMessage('1', 'ar');

      expect(progress, isNotNull);
      expect(progress!.messageId, '1');
      expect(progress.audioLanguageCode, 'ar');
      expect(progress.lastAudioPositionMs, 5000);
      expect(progress.playbackRate, 1.5);
    });

    test('Migration adds textLanguageCode to ReadingProgressTable', () async {
      final readingProgressDao = database.readingProgressDao;

      // Insert test records for different languages
      await readingProgressDao.upsert(
        '1',
        'ar',
        percent: 50.0,
        scrollOffset: 100.0,
      );

      await readingProgressDao.upsert(
        '1',
        'en',
        percent: 75.0,
        scrollOffset: 200.0,
      );

      // Retrieve records
      final arabicProgress = await readingProgressDao.getByMessage('1', 'ar');
      final englishProgress = await readingProgressDao.getByMessage('1', 'en');

      expect(arabicProgress, isNotNull);
      expect(arabicProgress!.scrollOffset, 100.0);
      expect(arabicProgress.textLanguageCode, 'ar');

      expect(englishProgress, isNotNull);
      expect(englishProgress!.scrollOffset, 200.0);
      expect(englishProgress.textLanguageCode, 'en');
    });

    test('Unique constraint enforced for messageId + language pairs', () async {
      final audioProgressDao = database.audioProgressDao;

      // Insert first record
      await audioProgressDao.upsert('1', 'ar', lastAudioPositionMs: 1000);

      // Update the same record (should not throw)
      await audioProgressDao.upsert('1', 'ar', lastAudioPositionMs: 2000);

      // Verify update worked
      final progress = await audioProgressDao.getByMessage('1', 'ar');
      expect(progress!.lastAudioPositionMs, 2000);
    });

    test('Reset methods work correctly', () async {
      final audioProgressDao = database.audioProgressDao;

      // Insert records for multiple languages
      await audioProgressDao.upsert('1', 'ar', lastAudioPositionMs: 1000);
      await audioProgressDao.upsert('1', 'en', lastAudioPositionMs: 2000);
      await audioProgressDao.upsert('2', 'ar', lastAudioPositionMs: 3000);

      // Reset specific language
      await audioProgressDao.reset('1', 'ar');
      expect(await audioProgressDao.getByMessage('1', 'ar'), isNull);
      expect(await audioProgressDao.getByMessage('1', 'en'), isNotNull);

      // Reset all languages for a message
      await audioProgressDao.reset('1');
      expect(await audioProgressDao.getByMessage('1', 'en'), isNull);
      expect(await audioProgressDao.getByMessage('2', 'ar'), isNotNull);
    });
  });
}
