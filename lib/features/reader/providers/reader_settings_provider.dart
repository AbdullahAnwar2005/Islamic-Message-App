import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/app_database.dart';

enum ReaderTheme { system, light, dark, sepia }
enum ReaderPageStyle { scroll, page }

class ReaderSettings {
  final double fontSize;
  final double lineHeight;
  final ReaderTheme theme;
  final String fontFamily;
  final ReaderPageStyle pageStyle;
  const ReaderSettings({
    this.fontSize = 18,
    this.lineHeight = 1.5,
    this.theme = ReaderTheme.system,
    this.fontFamily = 'NotoNaskhArabic',
    this.pageStyle = ReaderPageStyle.scroll,
  });

  ReaderSettings copyWith({
    double? fontSize, double? lineHeight, ReaderTheme? theme,
    String? fontFamily, ReaderPageStyle? pageStyle,
  }) => ReaderSettings(
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    theme: theme ?? this.theme,
    fontFamily: fontFamily ?? this.fontFamily,
    pageStyle: pageStyle ?? this.pageStyle,
  );
}

final readerSettingsProvider =
StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReaderSettingsNotifier(db)..load();
});

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  ReaderSettingsNotifier(this._db) : super(const ReaderSettings());
  final AppDatabase _db;

  Future<void> load() async {
    final row = await _db.readingSettingsDao.getSettings();
    state = ReaderSettings(
      fontSize: row.fontSize,
      lineHeight: row.lineHeight,
      theme: _toTheme(row.theme),
      fontFamily: row.fontFamily,
      pageStyle: _toPageStyle(row.pageStyle),
    );
  }

  Future<void> setFontSize(double v) async {
    state = state.copyWith(fontSize: v);
    await _db.readingSettingsDao.updateSettings(fontSize: v);
  }
  Future<void> setLineHeight(double v) async {
    state = state.copyWith(lineHeight: v);
    await _db.readingSettingsDao.updateSettings(lineHeight: v);
  }
  Future<void> setTheme(ReaderTheme t) async {
    state = state.copyWith(theme: t);
    await _db.readingSettingsDao.updateSettings(theme: _fromTheme(t));
  }
  Future<void> setPageStyle(ReaderPageStyle s) async {
    state = state.copyWith(pageStyle: s);
    await _db.readingSettingsDao.updateSettings(pageStyle: _fromPageStyle(s));
  }

  static ReaderTheme _toTheme(String s){
    switch (s) { case 'light': return ReaderTheme.light;
      case 'dark': return ReaderTheme.dark;
      case 'sepia': return ReaderTheme.sepia;
      default: return ReaderTheme.system; }
  }
  static String _fromTheme(ReaderTheme t){
    switch (t) { case ReaderTheme.light: return 'light';
      case ReaderTheme.dark: return 'dark';
      case ReaderTheme.sepia: return 'sepia';
      case ReaderTheme.system: default: return 'system'; }
  }
  static ReaderPageStyle _toPageStyle(String s)=> s=='page'?ReaderPageStyle.page:ReaderPageStyle.scroll;
  static String _fromPageStyle(ReaderPageStyle s)=> s==ReaderPageStyle.page?'page':'scroll';
}
