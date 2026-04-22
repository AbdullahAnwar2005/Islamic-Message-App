import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/app_database.dart';

/// Repository for handling Contact Us messages with offline-first support
class ContactRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  ContactRepository(this._db, this._supabase);

  /// Submit a contact message
  /// Tries Supabase first, falls back to local outbox if offline
  Future<bool> submitContactMessage({
    required String category,
    required String message,
    String? email,
  }) async {
    try {
      // Gather device metadata
      final appVersion = '0.9.1'; // TODO: Get from package_info_plus
      final platform = Platform.operatingSystem;
      final locale = Platform.localeName;

      // Try direct Supabase insertion
      await _supabase.from('contact_messages').insert({
        'category': category,
        'message': message,
        'email': email,
        'app_version': appVersion,
        'platform': platform,
        'locale': locale,
        'device_model': null, // Can be added with device_info_plus
      });

      debugPrint('[ContactRepository] Message sent to Supabase successfully');
      return true;
    } catch (e) {
      debugPrint('[ContactRepository] Supabase failed, saving to outbox: $e');

      // Save to local outbox for later sync
      await _db
          .into(_db.contactOutbox)
          .insert(
            ContactOutboxCompanion.insert(
              category: category,
              message: message,
              email: Value(email),
              appVersion: '0.9.1',
              platform: Platform.operatingSystem,
              locale: Platform.localeName,
              deviceModel: const Value(null),
              createdAt: DateTime.now(),
              synced: const Value(false),
            ),
          );

      debugPrint('[ContactRepository] Message saved to outbox');
      return false; // Indicate offline mode
    }
  }

  /// Sync pending contact messages from outbox to Supabase
  Future<int> syncPendingMessages() async {
    final pending =
        await (_db.select(_db.contactOutbox)
          ..where((t) => t.synced.equals(false))).get();

    if (pending.isEmpty) {
      debugPrint('[ContactRepository] No pending messages to sync');
      return 0;
    }

    int successCount = 0;

    for (final item in pending) {
      try {
        await _supabase.from('contact_messages').insert({
          'category': item.category,
          'message': item.message,
          'email': item.email,
          'app_version': item.appVersion,
          'platform': item.platform,
          'locale': item.locale,
          'device_model': item.deviceModel,
        });

        // Mark as synced
        await (_db.update(_db.contactOutbox)..where(
          (t) => t.id.equals(item.id),
        )).write(const ContactOutboxCompanion(synced: Value(true)));

        successCount++;
        debugPrint('[ContactRepository] Synced message ID ${item.id}');
      } catch (e) {
        debugPrint(
          '[ContactRepository] Failed to sync message ID ${item.id}: $e',
        );
        // Continue with next item
      }
    }

    debugPrint(
      '[ContactRepository] Synced $successCount/${pending.length} messages',
    );
    return successCount;
  }

  /// Get count of pending (unsynced) messages
  Future<int> getPendingCount() async {
    final count =
        await (_db.selectOnly(_db.contactOutbox)
              ..addColumns([_db.contactOutbox.id.count()])
              ..where(_db.contactOutbox.synced.equals(false)))
            .getSingle();

    return count.read(_db.contactOutbox.id.count()) ?? 0;
  }

  /// Clear synced messages older than 30 days
  Future<int> cleanupOldMessages() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    return await (_db.delete(_db.contactOutbox)..where(
      (t) => t.synced.equals(true) & t.createdAt.isSmallerThanValue(cutoff),
    )).go();
  }
}
