// lib/providers/transcript_providers.dart
//
// M-8 FIX: syncEnabledProvider is now persisted via SharedPreferences,
//          matching the pattern used by followAudioEnabledProvider.
// All providers are fully derived — no state writes during build.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/content/content_blocks.dart';
import '../core/content/sync_estimator.dart';
import 'analytics_provider.dart' show sharedPreferencesProvider;
import 'audio_player_provider.dart';

// ────────────────────────────────────────────────────────────
// Args record — keyed by content string (Riverpod caches by ==)
// ────────────────────────────────────────────────────────────

typedef BlocksArgs = ({int messageId, String langCode, String content});

// ────────────────────────────────────────────────────────────
// 1. Parsed blocks — pure derivation, no seeding
// ────────────────────────────────────────────────────────────

final parsedBlocksProvider = Provider.autoDispose
    .family<List<ContentBlock>, BlocksArgs>((ref, args) {
      return parseContentToBlocks(args.content);
    });

// ────────────────────────────────────────────────────────────
// 2. Sync ranges — derived from blocks + player duration
// ────────────────────────────────────────────────────────────

final syncRangesProvider = Provider.autoDispose
    .family<List<SyncRange>, BlocksArgs>((ref, args) {
      final blocks = ref.watch(parsedBlocksProvider(args));
      final durationMs = ref.watch(
        audioPlayerProvider.select((s) => s.duration.inMilliseconds),
      );
      return estimateSyncRanges(blocks, durationMs);
    });

// ────────────────────────────────────────────────────────────
// 3. Active block index — derived from sync ranges + position
// ────────────────────────────────────────────────────────────

final activeBlockIndexProvider = Provider.autoDispose.family<int?, BlocksArgs>((
  ref,
  args,
) {
  final ranges = ref.watch(syncRangesProvider(args));
  final positionMs = ref.watch(
    audioPlayerProvider.select((s) => s.position.inMilliseconds),
  );
  return activeTextBlockIndex(ranges, positionMs);
});

// ────────────────────────────────────────────────────────────
// 4. Sync enabled toggle — M-8: persisted via SharedPreferences
// ────────────────────────────────────────────────────────────

const _kSyncEnabledKey = 'sync_highlight_enabled';

final syncEnabledProvider = NotifierProvider<_SyncEnabledNotifier, bool>(
  _SyncEnabledNotifier.new,
);

class _SyncEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_kSyncEnabledKey) ?? true;
  }

  void toggle() {
    final next = !state;
    state = next;
    ref.read(sharedPreferencesProvider).setBool(_kSyncEnabledKey, next);
  }
}
