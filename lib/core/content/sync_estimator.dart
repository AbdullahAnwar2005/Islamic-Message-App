/// Sync estimator — distributes audio duration proportionally across text blocks.
///
/// Pure Dart, no Flutter dependency.

import 'content_blocks.dart';

class SyncRange {
  final int blockIndex;
  final int startMs;
  final int endMs;
  const SyncRange({
    required this.blockIndex,
    required this.startMs,
    required this.endMs,
  });

  @override
  String toString() => 'SyncRange(block=$blockIndex, $startMs–$endMs ms)';
}

/// Estimate timing ranges for text blocks based on character count.
///
/// - Only [BlockType.text] blocks get ranges.
/// - Duration is distributed proportionally by trimmed character count.
/// - Last range's [endMs] is clamped to [durationMs] to avoid rounding gaps.
/// - Returns empty list if [durationMs] <= 0 or no text blocks.
List<SyncRange> estimateSyncRanges(List<ContentBlock> blocks, int durationMs) {
  if (durationMs <= 0) return const [];

  // Collect text block indices and weights
  final entries = <({int index, int weight})>[];
  for (var i = 0; i < blocks.length; i++) {
    if (blocks[i].type == BlockType.text) {
      final w = blocks[i].text.trim().length;
      if (w > 0) entries.add((index: i, weight: w));
    }
  }

  if (entries.isEmpty) return const [];

  final totalWeight = entries.fold<int>(0, (sum, e) => sum + e.weight);
  if (totalWeight == 0) return const [];

  final ranges = <SyncRange>[];
  int cursor = 0;

  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    final int endMs;
    if (i == entries.length - 1) {
      // Clamp last range to exact duration
      endMs = durationMs;
    } else {
      endMs = cursor + (e.weight * durationMs ~/ totalWeight);
    }
    ranges.add(SyncRange(blockIndex: e.index, startMs: cursor, endMs: endMs));
    cursor = endMs;
  }

  return ranges;
}

/// Find the active text block index for a given playback position.
///
/// Returns the [SyncRange.blockIndex] whose range contains [positionMs].
/// If [positionMs] >= last range's endMs, returns the last text block index
/// (handles end-of-playback gracefully).
/// Returns `null` if [ranges] is empty or [positionMs] < first range start.
int? activeTextBlockIndex(List<SyncRange> ranges, int positionMs) {
  if (ranges.isEmpty) return null;
  if (positionMs < ranges.first.startMs) return null;

  // Handle end-of-playback: at or past the last range
  if (positionMs >= ranges.last.endMs) return ranges.last.blockIndex;

  // Linear scan (fast enough for typical block counts < 50)
  for (final r in ranges) {
    if (positionMs >= r.startMs && positionMs < r.endMs) {
      return r.blockIndex;
    }
  }

  return null;
}
