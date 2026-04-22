import 'package:shared_preferences/shared_preferences.dart';

class DeclareIslamRepository {
  static const String keyHasDeclared = 'di_has_declared';
  static const String keyDeclaredAt = 'di_declared_at';
  static const String keyLanguage = 'di_declared_language';

  Future<bool> hasDeclared() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyHasDeclared) ?? false;
  }

  Future<void> setDeclared({required String languageCode}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyHasDeclared, true);
    await prefs.setString(keyDeclaredAt, DateTime.now().toIso8601String());
    await prefs.setString(keyLanguage, languageCode);
  }

  Future<void> clearDeclaration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyHasDeclared);
    await prefs.remove(keyDeclaredAt);
    await prefs.remove(keyLanguage);
  }
}
