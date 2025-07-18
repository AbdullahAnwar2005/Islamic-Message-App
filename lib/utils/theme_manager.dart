import 'package:flutter/material.dart';

class ThemeManager {
  static ThemeMode toggle(ThemeMode current) {
    return current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  static String themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'وضع النهار';
      case ThemeMode.dark: return 'الوضع الليلي';
      default: return 'النظام';
    }
  }
}
