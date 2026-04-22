import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderSettings {
  final double fontSize;
  final double lineHeight;
  final bool isPageView; // [NEW]

  const ReaderSettings({
    required this.fontSize,
    required this.lineHeight,
    required this.isPageView,
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    bool? isPageView,
  }) => ReaderSettings(
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    isPageView: isPageView ?? this.isPageView,
  );
}

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>(
      (ref) => ReaderSettingsNotifier()..load(),
    );

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  ReaderSettingsNotifier()
    : super(
        const ReaderSettings(fontSize: 18, lineHeight: 1.6, isPageView: false),
      );

  static const _fontKey = 'reader_font_size';
  static const _lineKey = 'reader_line_height';
  static const _viewKey = 'reader_is_page_view';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble(_fontKey) ?? state.fontSize;
    final line = prefs.getDouble(_lineKey) ?? state.lineHeight;
    final isPage = prefs.getBool(_viewKey) ?? state.isPageView;
    state = ReaderSettings(
      fontSize: size,
      lineHeight: line,
      isPageView: isPage,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontKey, state.fontSize);
    await prefs.setDouble(_lineKey, state.lineHeight);
    await prefs.setBool(_viewKey, state.isPageView);
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(12, 36));
    _save();
  }

  void adjustFontSize(double delta) {
    setFontSize(state.fontSize + delta);
  }

  void setLineHeight(double line) {
    state = state.copyWith(lineHeight: line.clamp(1.0, 2.5));
    _save();
  }

  void setPageView(bool isPage) {
    state = state.copyWith(isPageView: isPage);
    _save();
  }
}
