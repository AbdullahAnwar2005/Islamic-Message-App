import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/app_database.dart';

class ReadingProgress {
  final String messageId;
  final double percent;
  final double scrollOffset;
  final int pageIndex;
  const ReadingProgress({required this.messageId, this.percent=0, this.scrollOffset=0, this.pageIndex=0});
}

final readingProgressProvider = StateNotifierProvider.family<
    ReadingProgressNotifier, ReadingProgress, String>((ref, messageId) {
  final db = ref.watch(appDatabaseProvider);
  final n = ReadingProgressNotifier(db, messageId);
  n.load();
  return n;
});

class ReadingProgressNotifier extends StateNotifier<ReadingProgress> {
  ReadingProgressNotifier(this._db, this.messageId)
      : super(ReadingProgress(messageId: messageId));
  final AppDatabase _db;
  final String messageId;
  Timer? _debounce;

  Future<void> load() async {
    final row = await _db.readingProgressDao.getByMessage(messageId);
    if (row != null) {
      state = ReadingProgress(
        messageId: messageId,
        percent: row.percent,
        scrollOffset: row.scrollOffset,
        pageIndex: row.pageIndex,
      );
    }
  }

  void onScroll(double offset, double maxExtent) {
    final p = maxExtent <= 0 ? 0 : (offset / maxExtent) * 100;
    state = ReadingProgress(
      messageId: messageId, percent: p.clamp(0, 100), scrollOffset: offset, pageIndex: state.pageIndex,
    );
    _persist();
  }

  void onPage(int index, int total) {
    final p = total <= 1 ? 0 : (index / (total - 1)) * 100;
    state = ReadingProgress(
      messageId: messageId, percent: p.clamp(0, 100), scrollOffset: 0, pageIndex: index,
    );
    _persist();
  }

  void _persist() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _db.readingProgressDao.upsert(
        messageId,
        percent: state.percent,
        scrollOffset: state.scrollOffset,
        pageIndex: state.pageIndex,
      );
    });
  }

  @override
  void dispose() { _debounce?.cancel(); super.dispose(); }
}
