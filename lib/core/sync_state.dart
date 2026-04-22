import 'package:shared_preferences/shared_preferences.dart';

class SyncState {
  static const _kLastSyncKey = 'last_sync_at';

  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_kLastSyncKey);
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  static Future<void> setLastSync(DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSyncKey, dt.toUtc().toIso8601String());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastSyncKey);
  }
}
