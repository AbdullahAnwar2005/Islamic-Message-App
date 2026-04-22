import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alghaya_men_alkhalg/data/local/app_database.dart';

void main() {
  group('Progress Repository Tests', () {
    late AppDatabase database;
    late ReadingProgressDao readingProgressDao;
    late AudioProgressDao audioProgressDao;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      readingProgressDao = database.readingProgressDao;
      audioProgressDao = database.audioProgressDao;
    });

    tearDown(() async {
      await database.close();
    });

    group('ReadingProgressDao', () {
      test(
        'Saves and retrieves reading progress per message and language',
        () async {
          // Save progress for different languages
          await readingProgressDao.upsert(
            'msg1',
            'ar',
            percent: 50.0,
            scrollOffset: 100.0,
            pageIndex: 0,
          );

          await readingProgressDao.upsert(
            'msg1',
            'en',
            percent: 75.0,
            scrollOffset: 200.0,
            pageIndex: 0,
          );

          // Retrieve and verify
          final arProgress = await readingProgressDao.getByMessage(
            'msg1',
            'ar',
          );
          expect(arProgress!.scrollOffset, 100.0);
          expect(arProgress.percent, 50.0);

          final enProgress = await readingProgressDao.getByMessage(
            'msg1',
            'en',
          );
          expect(enProgress!.scrollOffset, 200.0);
          expect(enProgress.percent, 75.0);
        },
      );

      test('Updates existing progress without creating duplicates', () async {
        // Initial save
        await readingProgressDao.upsert(
          'msg1',
          'ar',
          percent: 25.0,
          scrollOffset: 50.0,
        );

        // Update
        await readingProgressDao.upsert(
          'msg1',
          'ar',
          percent: 50.0,
          scrollOffset: 100.0,
        );

        // Verify only one record exists with updated values
        final progress = await readingProgressDao.getByMessage('msg1', 'ar');
        expect(progress!.scrollOffset, 100.0);
        expect(progress.percent, 50.0);
      });

      test('Resets progress for specific language', () async {
        await readingProgressDao.upsert(
          'msg1',
          'ar',
          percent: 50.0,
          scrollOffset: 100.0,
        );
        await readingProgressDao.upsert(
          'msg1',
          'en',
          percent: 75.0,
          scrollOffset: 200.0,
        );

        await readingProgressDao.reset('msg1', 'ar');

        expect(await readingProgressDao.getByMessage('msg1', 'ar'), isNull);
        expect(await readingProgressDao.getByMessage('msg1', 'en'), isNotNull);
      });

      test('Resets all languages when language not specified', () async {
        await readingProgressDao.upsert(
          'msg1',
          'ar',
          percent: 50.0,
          scrollOffset: 100.0,
        );
        await readingProgressDao.upsert(
          'msg1',
          'en',
          percent: 75.0,
          scrollOffset: 200.0,
        );

        await readingProgressDao.reset('msg1');

        expect(await readingProgressDao.getByMessage('msg1', 'ar'), isNull);
        expect(await readingProgressDao.getByMessage('msg1', 'en'), isNull);
      });

      test('Returns null for non-existent progress', () async {
        final progress = await readingProgressDao.getByMessage(
          'nonexistent',
          'ar',
        );
        expect(progress, isNull);
      });
    });

    group('AudioProgressDao', () {
      test(
        'Saves and retrieves audio progress per message and language',
        () async {
          await audioProgressDao.upsert(
            'msg1',
            'ar',
            lastAudioPositionMs: 5000,
            playbackRate: 1.5,
          );

          await audioProgressDao.upsert(
            'msg1',
            'en',
            lastAudioPositionMs: 10000,
            playbackRate: 2.0,
          );

          final arProgress = await audioProgressDao.getByMessage('msg1', 'ar');
          expect(arProgress!.lastAudioPositionMs, 5000);
          expect(arProgress.playbackRate, 1.5);

          final enProgress = await audioProgressDao.getByMessage('msg1', 'en');
          expect(enProgress!.lastAudioPositionMs, 10000);
          expect(enProgress.playbackRate, 2.0);
        },
      );

      test('Updates existing audio progress', () async {
        await audioProgressDao.upsert(
          'msg1',
          'ar',
          lastAudioPositionMs: 1000,
          playbackRate: 1.0,
        );

        await audioProgressDao.upsert(
          'msg1',
          'ar',
          lastAudioPositionMs: 5000,
          playbackRate: 1.5,
        );

        final progress = await audioProgressDao.getByMessage('msg1', 'ar');
        expect(progress!.lastAudioPositionMs, 5000);
        expect(progress.playbackRate, 1.5);
      });

      test('Uses default playback rate of 1.0', () async {
        await audioProgressDao.upsert('msg1', 'ar', lastAudioPositionMs: 5000);

        final progress = await audioProgressDao.getByMessage('msg1', 'ar');
        expect(progress!.playbackRate, 1.0);
      });

      test('Resets audio progress for specific language', () async {
        await audioProgressDao.upsert('msg1', 'ar', lastAudioPositionMs: 5000);
        await audioProgressDao.upsert('msg1', 'en', lastAudioPositionMs: 10000);

        await audioProgressDao.reset('msg1', 'ar');

        expect(await audioProgressDao.getByMessage('msg1', 'ar'), isNull);
        expect(await audioProgressDao.getByMessage('msg1', 'en'), isNotNull);
      });

      test('Resets all audio progress when language not specified', () async {
        await audioProgressDao.upsert('msg1', 'ar', lastAudioPositionMs: 5000);
        await audioProgressDao.upsert('msg1', 'en', lastAudioPositionMs: 10000);

        await audioProgressDao.reset('msg1');

        expect(await audioProgressDao.getByMessage('msg1', 'ar'), isNull);
        expect(await audioProgressDao.getByMessage('msg1', 'en'), isNull);
      });

      test('Handles multiple messages independently', () async {
        await audioProgressDao.upsert('msg1', 'ar', lastAudioPositionMs: 5000);
        await audioProgressDao.upsert('msg2', 'ar', lastAudioPositionMs: 10000);

        await audioProgressDao.reset('msg1');

        expect(await audioProgressDao.getByMessage('msg1', 'ar'), isNull);
        expect(await audioProgressDao.getByMessage('msg2', 'ar'), isNotNull);
      });
    });
  });
}
