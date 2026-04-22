import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/app_database.dart';

/// Repository for handling Content Reports with offline-first support
class ContentReportRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  ContentReportRepository(this._db, this._supabase);

  /// Submit a content report
  /// Tries Supabase first, falls back to local outbox if offline
  Future<bool> submitReport({
    required int messageId,
    required String languageCode,
    required String reportType,
    String? comment,
  }) async {
    try {
      // Gather device metadata
      final appVersion = '0.9.1'; // TODO: Get from package_info_plus
      final platform = Platform.operatingSystem;
      final locale = Platform.localeName;

      // Try direct Supabase insertion
      await _supabase.from('content_reports').insert({
        'message_id': messageId,
        'language_code': languageCode,
        'report_type': reportType,
        'comment': comment,
        'app_version': appVersion,
        'platform': platform,
        'locale': locale,
      });

      debugPrint(
        '[ContentReportRepository] Report sent to Supabase successfully',
      );
      return true;
    } catch (e) {
      debugPrint(
        '[ContentReportRepository] Supabase failed, saving to outbox: $e',
      );

      // Save to local outbox for later sync
      await _db
          .into(_db.contentReportsOutbox)
          .insert(
            ContentReportsOutboxCompanion.insert(
              messageId: messageId,
              languageCode: languageCode,
              reportType: reportType,
              comment: Value(comment),
              appVersion: '0.9.1',
              platform: Platform.operatingSystem,
              locale: Platform.localeName,
              createdAt: DateTime.now(),
              synced: const Value(false),
            ),
          );

      debugPrint('[ContentReportRepository] Report saved to outbox');
      return false; // Indicate offline mode
    }
  }

  /// Sync pending content reports from outbox to Supabase
  Future<int> syncPendingReports() async {
    final pending =
        await (_db.select(_db.contentReportsOutbox)
          ..where((t) => t.synced.equals(false))).get();

    if (pending.isEmpty) {
      debugPrint('[ContentReportRepository] No pending reports to sync');
      return 0;
    }

    int successCount = 0;

    for (final item in pending) {
      try {
        await _supabase.from('content_reports').insert({
          'message_id': item.messageId,
          'language_code': item.languageCode,
          'report_type': item.reportType,
          'comment': item.comment,
          'app_version': item.appVersion,
          'platform': item.platform,
          'locale': item.locale,
        });

        // Mark as synced
        await (_db.update(_db.contentReportsOutbox)..where(
          (t) => t.id.equals(item.id),
        )).write(const ContentReportsOutboxCompanion(synced: Value(true)));

        successCount++;
        debugPrint('[ContentReportRepository] Synced report ID ${item.id}');
      } catch (e) {
        debugPrint(
          '[ContentReportRepository] Failed to sync report ID ${item.id}: $e',
        );
        // Continue with next item
      }
    }

    debugPrint(
      '[ContentReportRepository] Synced $successCount/${pending.length} reports',
    );
    return successCount;
  }

  /// Get count of pending (unsynced) reports
  Future<int> getPendingCount() async {
    final count =
        await (_db.selectOnly(_db.contentReportsOutbox)
              ..addColumns([_db.contentReportsOutbox.id.count()])
              ..where(_db.contentReportsOutbox.synced.equals(false)))
            .getSingle();

    return count.read(_db.contentReportsOutbox.id.count()) ?? 0;
  }

  /// Clear synced reports older than 30 days
  Future<int> cleanupOldReports() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    return await (_db.delete(_db.contentReportsOutbox)..where(
      (t) => t.synced.equals(true) & t.createdAt.isSmallerThanValue(cutoff),
    )).go();
  }
}
