import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple data class
class LastReadInfo {
  final int messageId;
  final int chapterIndex;
  final DateTime timestamp;

  LastReadInfo({
    required this.messageId,
    required this.chapterIndex,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'chapterIndex': chapterIndex,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LastReadInfo.fromJson(Map<String, dynamic> map) {
    return LastReadInfo(
      messageId: map['messageId'] as int,
      chapterIndex: map['chapterIndex'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

final lastReadServiceProvider = Provider((ref) => LastReadService());

class LastReadService {
  static const _key = 'last_read_info_v1';

  Future<void> save(int messageId, int chapterIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final info = LastReadInfo(
      messageId: messageId,
      chapterIndex: chapterIndex,
      timestamp: DateTime.now(),
    );
    await prefs.setString(_key, jsonEncode(info.toJson()));
  }

  Future<LastReadInfo?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null) return null;
    try {
      return LastReadInfo.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
