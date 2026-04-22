import 'dart:collection';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, Map<int, List<Bookmark>>>(
      (ref) => BookmarksNotifier()..loadAll(),
    );

class Bookmark {
  final int messageId;
  // New fields for paragraph-based bookmarking
  final int chapterIndex;
  final int paragraphIndex;
  final String? paragraphKey; // optional stable key
  final String excerpt; // text snippet

  // Deprecated/Legacy fields (kept for migration if needed, or just removed)
  // final double pixels;
  // final double? percent;

  final DateTime createdAt;

  const Bookmark({
    required this.messageId,
    required this.chapterIndex,
    required this.paragraphIndex,
    required this.excerpt,
    this.paragraphKey,
    required this.createdAt,
  });

  Bookmark copyWith({
    int? chapterIndex,
    int? paragraphIndex,
    String? paragraphKey,
    String? excerpt,
    DateTime? createdAt,
  }) => Bookmark(
    messageId: messageId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    paragraphIndex: paragraphIndex ?? this.paragraphIndex,
    paragraphKey: paragraphKey ?? this.paragraphKey,
    excerpt: excerpt ?? this.excerpt,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'chapterIndex': chapterIndex,
    'paragraphIndex': paragraphIndex,
    'paragraphKey': paragraphKey,
    'excerpt': excerpt,
    'createdAt': createdAt.toIso8601String(),
  };

  static Bookmark fromJson(Map<String, dynamic> m) => Bookmark(
    messageId: m['messageId'] as int,
    chapterIndex: (m['chapterIndex'] as int?) ?? 0,
    paragraphIndex: (m['paragraphIndex'] as int?) ?? 0,
    paragraphKey: m['paragraphKey'] as String?,
    excerpt: (m['excerpt'] as String?) ?? 'Bookmark',
    createdAt: DateTime.parse(m['createdAt'] as String),
  );
}

class BookmarksNotifier extends StateNotifier<Map<int, List<Bookmark>>> {
  BookmarksNotifier() : super(const <int, List<Bookmark>>{});

  static const _prefsKey = 'reader_bookmarks_v2';

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;

    // Decode flat list → typed List<Bookmark>
    final decoded = jsonDecode(raw) as List<dynamic>;
    final List<Bookmark> flat = decoded
        .map((e) => Bookmark.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    // Group by messageId → Map<int, List<Bookmark>>
    final Map<int, List<Bookmark>> map = <int, List<Bookmark>>{};
    for (final b in flat) {
      final List<Bookmark> bucket = map.putIfAbsent(
        b.messageId,
        () => <Bookmark>[],
      );
      bucket.add(b);
    }

    // Sort each bucket: newest first
    for (final entry in map.entries) {
      entry.value.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    state = map;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Bookmark> flat = state.values
        .expand((bucket) => bucket)
        .toList(growable: false);
    await prefs.setString(
      _prefsKey,
      jsonEncode(flat.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<void> add(Bookmark b) async {
    // Ensure typed list
    final List<Bookmark> current = List<Bookmark>.from(
      state[b.messageId] ?? const <Bookmark>[],
    );
    current.insert(0, b);
    state = {...state, b.messageId: current};
    await _persist();
  }

  Future<void> remove(int messageId, Bookmark b) async {
    final List<Bookmark> current = List<Bookmark>.from(
      state[messageId] ?? const <Bookmark>[],
    );
    // Remove by identity; adjust if you prefer a key (e.g., createdAt/pixels)
    current.remove(b);
    state = {...state, messageId: current};
    await _persist();
  }

  /// Read-only view to prevent outside mutation.
  UnmodifiableListView<Bookmark> forMessage(int messageId) =>
      UnmodifiableListView<Bookmark>(state[messageId] ?? const <Bookmark>[]);
}
