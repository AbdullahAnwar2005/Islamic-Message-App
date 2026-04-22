import 'dart:ui' as ui;
import 'package:flutter/material.dart';

TextStyle buildReaderTextStyle({
  required BuildContext context,
  required bool isRtl,
  required double fontSize,      // from settings
  required double lineHeight,    // from settings
}) {
  final base = Theme.of(context).textTheme.bodyLarge!;
  return base.copyWith(
    fontSize: fontSize,                // e.g. 18–22 for Arabic
    height: lineHeight,                // 1.6–1.9 feels great
    wordSpacing: 0.5,                  // subtle, improves Arabic readability
    letterSpacing: isRtl ? 0.0 : 0.15, // tiny boost for Latin
    leadingDistribution: TextLeadingDistribution.even,
    locale: isRtl ? const ui.Locale('ar') : null,
  );
}
