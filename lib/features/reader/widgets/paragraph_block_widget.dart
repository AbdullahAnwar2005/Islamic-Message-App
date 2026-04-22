import 'package:flutter/material.dart';

// If your models live elsewhere, import them accordingly:
import '../models/reader_content.dart' show Paragraph;

class ParagraphBlockWidget extends StatelessWidget {
  const ParagraphBlockWidget({
    super.key,
    required this.block,
    required this.textStyle,
  });

  final dynamic block;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final para = _toParagraph(block);
    final text = _normalizeWhitespace(para.text);
    final isRtl = _looksRtl(text);

    // Pick align & direction from content, not from locale
    final align = isRtl ? TextAlign.right : TextAlign.left;
    final dir   = isRtl ? TextDirection.rtl : TextDirection.ltr;

    // If you want selectable text, replace Text with SelectableText
    return Semantics(
      label: text,
      child: Directionality(
        textDirection: dir,
        child: Text(
          text,
          textAlign: TextAlign.justify,
          style: textStyle,
          softWrap: true,
        ),
      ),
    );
  }

  // ——— helpers ———

  Paragraph _toParagraph(dynamic b) {
    if (b is Paragraph) return b;

    // Legacy map support: {text: "..."} (ignore unknown fields)
    if (b is Map) {
      final raw = (b['text'] as String?) ?? '';
      return Paragraph(key: 'auto_${raw.hashCode}', text: raw);
    }

    // Fallback to string
    if (b is String) {
      return Paragraph(key: 'auto_${b.hashCode}', text: b);
    }

    // Last resort
    return const Paragraph(key: 'empty', text: '');
  }

  bool _looksRtl(String s) {
    // Basic heuristic over Arabic/Hebrew ranges
    final rtlRe = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\u0590-\u05FF]');
    return rtlRe.hasMatch(s);
  }

  String _normalizeWhitespace(String s) {
    // Collapse internal runs; keep intentional newlines if you need them.
    return s.replaceAll(RegExp(r'[ \t]+'), ' ').trimRight();
  }
}
