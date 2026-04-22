import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';
import 'analytics_queue_table.dart';
import '../domain/analytics_event.dart';
import 'dart:math';

part 'analytics_queue_dao.g.dart';

@DriftAccessor(tables: [AnalyticsEventQueue])
class AnalyticsQueueDao extends DatabaseAccessor<AppDatabase>
    with _$AnalyticsQueueDaoMixin {
  AnalyticsQueueDao(AppDatabase db) : super(db);

  /// Enqueue a new event.
  Future<void> enqueue(AnalyticsEvent event) async {
    await into(analyticsEventQueue).insertOnConflictUpdate(
      AnalyticsEventQueueCompanion.insert(
        clientEventId: event.clientEventId,
        occurredAt: event.occurredAt,
        eventName: event.eventName,
        payloadJson: event.toJsonString(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Get a batch of events ready to be sent.
  /// Respects [limit] and [nextRetryAt].
  Future<List<AnalyticsQueueEntry>> getBatch({int limit = 100}) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // Select events where nextRetryAt is null OR <= now
    return (select(analyticsEventQueue)
          ..where((t) {
            final ready = t.nextRetryAt.isNull();
            final retryTimeReached = t.nextRetryAt.isSmallerOrEqualValue(nowMs);
            return ready | retryTimeReached;
          })
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Mark specific IDs as successfully sent (delete them).
  Future<void> markBatchSucceeded(List<String> ids) async {
    if (ids.isEmpty) return;
    await (delete(analyticsEventQueue)
      ..where((t) => t.clientEventId.isIn(ids))).go();
  }

  /// Mark specific IDs as failed. Increment attempts and set backoff.
  /// Backoff: min(2^attempts * 5s, 10 minutes)
  Future<void> markBatchFailed(List<String> ids) async {
    if (ids.isEmpty) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    // We can't do complex logic easily in a single UPDATE query with varying attempts,
    // so we iterate or use a custom query. For simplicity and since batch sizes are small (100),
    // we can fetch the rows, calculate updates, and batch update.
    // However, a simpler approch for "bulk failure" is to just update them all if they share similar attempts,
    // but they might not.
    // Let's do a read-modify-write for correctness on backoff calculation.

    final rows =
        await (select(analyticsEventQueue)
          ..where((t) => t.clientEventId.isIn(ids))).get();

    await batch((batch) {
      for (final row in rows) {
        final newAttempts = row.attempts + 1;
        // 5s, 10s, 20s, 40s...
        final backoffSeconds = min(
          pow(2, newAttempts) * 5,
          600,
        ); // Max 10 mins (600s)
        final nextRetry = nowMs + (backoffSeconds * 1000).toInt();

        batch.update(
          analyticsEventQueue,
          AnalyticsEventQueueCompanion(
            attempts: Value(newAttempts),
            nextRetryAt: Value(nextRetry),
          ),
          where: (t) => t.clientEventId.equals(row.clientEventId),
        );
      }
    });
  }

  /// Prune the queue if it exceeds [maxRows], deleting the oldest.
  Future<void> prune({int maxRows = 5000}) async {
    final countExp = analyticsEventQueue.clientEventId.count();
    final count =
        await (selectOnly(analyticsEventQueue)..addColumns([
          countExp,
        ])).map((row) => row.read(countExp)!).getSingle();

    if (count > maxRows) {
      final excess = count - maxRows;
      // Delete 'excess' oldest rows
      // SQLite doesn't support DELETE ... LIMIT directly in all versions or via Drift helper easily
      // without a subquery.
      // DELETE FROM table WHERE id IN (SELECT id FROM table ORDER BY created_at ASC LIMIT excess)

      final oldestIds =
          await (select(analyticsEventQueue)
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
                ..limit(excess))
              .map((row) => row.clientEventId)
              .get();

      if (oldestIds.isNotEmpty) {
        await (delete(analyticsEventQueue)
          ..where((t) => t.clientEventId.isIn(oldestIds))).go();
      }
    }
  }

  /// Get current queue size (for debug)
  Future<int> getQueueSize() async {
    final countExp = analyticsEventQueue.clientEventId.count();
    return await (selectOnly(analyticsEventQueue)
      ..addColumns([countExp])).map((row) => row.read(countExp)!).getSingle();
  }
}
