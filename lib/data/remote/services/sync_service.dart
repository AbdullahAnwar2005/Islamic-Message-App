// lib/data/remote/services/sync_service.dart
import 'package:alghaya_men_alkhalg/data/local/app_database.dart';
import 'package:alghaya_men_alkhalg/data/repositories/contact_repository.dart';
import 'package:alghaya_men_alkhalg/data/repositories/content_report_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncResult {
  final int messagesUpserted;
  final int translationsUpserted;
  final int contactsSynced;
  final int reportsSynced;
  final DateTime endedAt;
  const SyncResult({
    required this.messagesUpserted,
    required this.translationsUpserted,
    required this.contactsSynced,
    required this.reportsSynced,
    required this.endedAt,
  });
}

class SyncService {
  final AppDatabase db;
  final SupabaseClient supabase;
  late final ContactRepository _contactRepo;
  late final ContentReportRepository _reportRepo;

  SyncService({required this.db, required this.supabase}) {
    _contactRepo = ContactRepository(db, supabase);
    _reportRepo = ContentReportRepository(db, supabase);
  }

  Future<SyncResult> run({bool initial = false}) async {
    int contactsSynced = 0;
    int reportsSynced = 0;

    // 1) Sync pending contact messages (if any)
    try {
      contactsSynced = await _contactRepo.syncPendingMessages();
      debugPrint('[SyncService] Synced $contactsSynced contact messages');
    } catch (e) {
      debugPrint('[SyncService] Failed to sync contact messages: $e');
    }

    // 2) Sync pending content reports (if any)
    try {
      reportsSynced = await _reportRepo.syncPendingReports();
      debugPrint('[SyncService] Synced $reportsSynced content reports');
    } catch (e) {
      debugPrint('[SyncService] Failed to sync content reports: $e');
    }

    // 3) TODO: Pull content updates from Supabase (messages/translations)
    // final last = await db.readLastSync();
    // pull from supabase (>= last)
    // await db.upsertMessage(...), db.upsertTranslation(...)
    // await db.writeLastSync(DateTime.now().toUtc());

    // 4) Cleanup old synced records (optional, for performance)
    try {
      await _contactRepo.cleanupOldMessages();
      await _reportRepo.cleanupOldReports();
    } catch (e) {
      debugPrint('[SyncService] Cleanup failed (non-critical): $e');
    }

    // Return a result for UI/telemetry
    return SyncResult(
      messagesUpserted: 0,
      translationsUpserted: 0,
      contactsSynced: contactsSynced,
      reportsSynced: reportsSynced,
      endedAt: DateTime.now().toUtc(),
    );
  }
}
