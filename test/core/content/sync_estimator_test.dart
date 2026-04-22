import 'package:flutter_test/flutter_test.dart';
import 'package:alghaya_men_alkhalg/core/content/content_blocks.dart';
import 'package:alghaya_men_alkhalg/core/content/sync_estimator.dart';

void main() {
  group('estimateSyncRanges', () {
    test('distributes duration proportionally with increasing ranges', () {
      final blocks = [
        const ContentBlock(type: BlockType.text, text: 'Short'), // 5 chars
        const ContentBlock(
          type: BlockType.text,
          text: 'A longer text',
        ), // 13 chars
        const ContentBlock(type: BlockType.text, text: 'Medium!!'), // 8 chars
      ];

      final ranges = estimateSyncRanges(blocks, 10000);

      expect(ranges.length, 3);

      // Ranges should be non-overlapping and increasing
      for (var i = 0; i < ranges.length - 1; i++) {
        expect(ranges[i].endMs, ranges[i + 1].startMs);
        expect(ranges[i].startMs, lessThan(ranges[i].endMs));
      }

      // First range starts at 0
      expect(ranges.first.startMs, 0);

      // Last range ends at exactly durationMs (clamped)
      expect(ranges.last.endMs, 10000);
    });

    test('skips non-text blocks', () {
      final blocks = [
        const ContentBlock(type: BlockType.header, text: 'Title'),
        const ContentBlock(type: BlockType.text, text: 'Paragraph one'),
        const ContentBlock(type: BlockType.quran, text: '﴿آية﴾'),
        const ContentBlock(type: BlockType.text, text: 'Paragraph two'),
      ];

      final ranges = estimateSyncRanges(blocks, 6000);

      expect(ranges.length, 2);
      expect(ranges[0].blockIndex, 1); // index of first text block
      expect(ranges[1].blockIndex, 3); // index of second text block
      expect(ranges.last.endMs, 6000);
    });

    test('durationMs <= 0 returns empty list', () {
      final blocks = [const ContentBlock(type: BlockType.text, text: 'Hello')];
      expect(estimateSyncRanges(blocks, 0), isEmpty);
      expect(estimateSyncRanges(blocks, -100), isEmpty);
    });

    test('no text blocks returns empty list', () {
      final blocks = [
        const ContentBlock(type: BlockType.header, text: 'Title'),
        const ContentBlock(type: BlockType.quran, text: '﴿آية﴾'),
      ];
      expect(estimateSyncRanges(blocks, 5000), isEmpty);
    });

    test('single text block covers entire duration', () {
      final blocks = [
        const ContentBlock(type: BlockType.text, text: 'Only block'),
      ];
      final ranges = estimateSyncRanges(blocks, 3000);
      expect(ranges.length, 1);
      expect(ranges[0].startMs, 0);
      expect(ranges[0].endMs, 3000);
    });
  });

  group('activeTextBlockIndex', () {
    final ranges = [
      const SyncRange(blockIndex: 1, startMs: 0, endMs: 3000),
      const SyncRange(blockIndex: 3, startMs: 3000, endMs: 7000),
      const SyncRange(blockIndex: 5, startMs: 7000, endMs: 10000),
    ];

    test('returns correct index for position within range', () {
      expect(activeTextBlockIndex(ranges, 0), 1);
      expect(activeTextBlockIndex(ranges, 1500), 1);
      expect(activeTextBlockIndex(ranges, 3000), 3);
      expect(activeTextBlockIndex(ranges, 5000), 3);
      expect(activeTextBlockIndex(ranges, 7000), 5);
      expect(activeTextBlockIndex(ranges, 9999), 5);
    });

    test('returns last block index at/after end of playback', () {
      expect(activeTextBlockIndex(ranges, 10000), 5);
      expect(activeTextBlockIndex(ranges, 15000), 5);
    });

    test('returns null for negative position', () {
      expect(activeTextBlockIndex(ranges, -1), null);
    });

    test('returns null for empty ranges', () {
      expect(activeTextBlockIndex([], 1000), null);
    });
  });
}
