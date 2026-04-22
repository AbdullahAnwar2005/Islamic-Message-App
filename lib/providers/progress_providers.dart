import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

/// Provider for reading scroll position by message + text language
final readingProgressProvider = FutureProvider.autoDispose
    .family<double, ({String messageId, String textLang})>((ref, params) async {
      final db = ref.watch(appDatabaseProvider);
      final progress = await db.readingProgressDao.getByMessage(
        params.messageId,
        params.textLang,
      );
      return progress?.scrollOffset ?? 0.0;
    });

/// Provider for audio playback position by message + audio language
final audioProgressProvider = FutureProvider.autoDispose.family<
  ({int positionMs, double rate}),
  ({String messageId, String audioLang})
>((ref, params) async {
  final db = ref.watch(appDatabaseProvider);
  final progress = await db.audioProgressDao.getByMessage(
    params.messageId,
    params.audioLang,
  );
  return (
    positionMs: progress?.lastAudioPositionMs ?? 0,
    rate: progress?.playbackRate ?? 1.0,
  );
});

/// Service provider for saving progress with debounce logic
final progressServiceProvider = Provider<ProgressService>(
  (ref) => ProgressService(ref),
);

class ProgressService {
  final Ref _ref;

  ProgressService(this._ref);

  /// Save reading progress (scroll position)
  /// Called on: onScrollEnd, dispose(), or long debounce (1500-2000ms)
  Future<void> saveReadingProgress({
    required String messageId,
    required String textLanguageCode,
    required double scrollOffset,
    double? percent,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    await db.readingProgressDao.upsert(
      messageId,
      textLanguageCode,
      percent: percent ?? 0.0,
      scrollOffset: scrollOffset,
    );
  }

  /// Save audio progress (playback position)
  /// Called on: pause(), seek() completion, or dispose()
  Future<void> saveAudioProgress({
    required String messageId,
    required String audioLanguageCode,
    required int positionMs,
    double playbackRate = 1.0,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    await db.audioProgressDao.upsert(
      messageId,
      audioLanguageCode,
      lastAudioPositionMs: positionMs,
      playbackRate: playbackRate,
    );
  }

  /// Reset reading progress for a message (optionally specific language)
  Future<void> resetReadingProgress(
    String messageId, [
    String? textLanguageCode,
  ]) async {
    final db = _ref.read(appDatabaseProvider);
    await db.readingProgressDao.reset(messageId, textLanguageCode);
  }

  /// Reset audio progress for a message (optionally specific language)
  Future<void> resetAudioProgress(
    String messageId, [
    String? audioLanguageCode,
  ]) async {
    final db = _ref.read(appDatabaseProvider);
    await db.audioProgressDao.reset(messageId, audioLanguageCode);
  }

  /// Get audio progress for resuming
  Future<dynamic> getAudioProgress({
    required String messageId,
    required String audioLanguageCode,
  }) async {
    final db = _ref.read(appDatabaseProvider);
    return await db.audioProgressDao.getByMessage(messageId, audioLanguageCode);
  }
}
