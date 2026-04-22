import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to manage sync throttling logic
/// Prevents excessive sync operations by enforcing a 15-minute cooldown
class SyncThrottle {
  static const String _lastSyncKey = 'last_auto_sync_timestamp';
  static const int _throttleMinutes = 15;

  /// Check if enough time has passed since last sync
  Future<bool> shouldSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncTimestamp = prefs.getInt(_lastSyncKey);

    if (lastSyncTimestamp == null) {
      // Never synced before
      return true;
    }

    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    return difference.inMinutes >= _throttleMinutes;
  }

  /// Record the current time as the last sync timestamp
  Future<void> recordSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the DateTime of the last sync (if any)
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);

    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Get minutes remaining before next sync is allowed
  Future<int> getMinutesUntilNextSync() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return 0;

    final now = DateTime.now();
    final elapsed = now.difference(lastSync).inMinutes;
    final remaining = _throttleMinutes - elapsed;

    return remaining > 0 ? remaining : 0;
  }
}

/// Provider for sync throttle instance
final syncThrottleProvider = Provider<SyncThrottle>((ref) => SyncThrottle());
