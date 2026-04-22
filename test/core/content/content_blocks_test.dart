import 'package:flutter_test/flutter_test.dart';
import 'package:alghaya_men_alkhalg/core/content/content_blocks.dart';

void main() {
  group('parseContentToBlocks', () {
    test('mixed content: header + quran + text classified correctly', () {
      const content = '''## المقدمة
السلام عليكم ورحمة الله وبركاته
هذا هو المحتوى الأول

﴿بسم الله الرحمن الرحيم﴾

وهذا نص آخر بعد القرآن''';

      final blocks = parseContentToBlocks(content);

      expect(blocks.length, 4);

      expect(blocks[0].type, BlockType.header);
      expect(blocks[0].text, 'المقدمة'); // ## stripped

      expect(blocks[1].type, BlockType.text);
      expect(blocks[1].text, contains('السلام عليكم'));

      expect(blocks[2].type, BlockType.quran);
      expect(blocks[2].text, contains('﴿'));

      expect(blocks[3].type, BlockType.text);
      expect(blocks[3].text, contains('نص آخر'));
    });

    test('header text strips ## and trims', () {
      final blocks = parseContentToBlocks('##   Hello World  ');
      expect(blocks.length, 1);
      expect(blocks[0].type, BlockType.header);
      expect(blocks[0].text, 'Hello World');
    });

    test('CRLF normalization', () {
      const content = '## Title\r\nLine one\r\nLine two\r\n\r\nLine three';
      final blocks = parseContentToBlocks(content);

      expect(blocks[0].type, BlockType.header);
      expect(blocks[0].text, 'Title');
      expect(blocks[1].type, BlockType.text);
      expect(blocks[1].text, 'Line one\nLine two');
      expect(blocks[2].type, BlockType.text);
      expect(blocks[2].text, 'Line three');
    });

    test('empty content returns empty list', () {
      expect(parseContentToBlocks(''), isEmpty);
    });

    test('only headers yield no text blocks', () {
      const content = '## First\n## Second';
      final blocks = parseContentToBlocks(content);
      expect(blocks.length, 2);
      expect(blocks.every((b) => b.type == BlockType.header), isTrue);
    });

    test('quran line with only opening ornament', () {
      final blocks = parseContentToBlocks('this has ﴿ in it');
      expect(blocks.length, 1);
      expect(blocks[0].type, BlockType.quran);
    });

    test('quran line with only closing ornament', () {
      final blocks = parseContentToBlocks('this has ﴾ in it');
      expect(blocks.length, 1);
      expect(blocks[0].type, BlockType.quran);
    });

    test('contiguous text lines grouped into single block', () {
      const content = 'line one\nline two\nline three';
      final blocks = parseContentToBlocks(content);
      expect(blocks.length, 1);
      expect(blocks[0].type, BlockType.text);
      expect(blocks[0].text, 'line one\nline two\nline three');
    });
  });

  group('buildTtsPayload', () {
    test('excludes quran blocks', () {
      final blocks = [
        const ContentBlock(type: BlockType.header, text: 'Title'),
        const ContentBlock(type: BlockType.text, text: 'First paragraph'),
        const ContentBlock(
          type: BlockType.quran,
          text: '﴿بسم الله الرحمن الرحيم﴾',
        ),
        const ContentBlock(type: BlockType.text, text: 'Second paragraph'),
      ];

      final payload = buildTtsPayload(blocks);
      expect(payload, 'First paragraph\n\nSecond paragraph');
      expect(payload, isNot(contains('﴿')));
      expect(payload, isNot(contains('Title')));
    });

    test('replaces internal newlines with spaces', () {
      final blocks = [
        const ContentBlock(type: BlockType.text, text: 'line one\nline two'),
      ];
      final payload = buildTtsPayload(blocks);
      expect(payload, 'line one line two');
    });

    test('empty blocks list returns empty string', () {
      expect(buildTtsPayload([]), '');
    });

    test('only quran blocks returns empty string', () {
      final blocks = [const ContentBlock(type: BlockType.quran, text: '﴿آية﴾')];
      expect(buildTtsPayload(blocks), '');
    });
  });
}
