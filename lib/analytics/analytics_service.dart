import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'data/analytics_queue_dao.dart';
import 'data/analytics_remote_datasource.dart';
import 'domain/analytics_event.dart';

class AnalyticsService {
  final AnalyticsQueueDao _dao;
  final AnalyticsRemoteDatasource _remote;
  final SharedPreferences _prefs;

  // State
  late final String _anonUserId;
  late final String _sessionId;
  late final String _appVersion;
  final String _platform = Platform.operatingSystem;

  bool _isInitialized = false;
  bool _isFlushing = false;

  AnalyticsService(this._dao, this._remote, this._prefs);

  /// Initialize session, user ID, and app version.
  Future<void> init() async {
    if (_isInitialized) return;

    // Anon ID (Persistent)
    String? storedId = _prefs.getString('analytics_anon_user_id');
    if (storedId == null) {
      storedId = const Uuid().v4();
      await _prefs.setString('analytics_anon_user_id', storedId);
    }
    _anonUserId = storedId;

    // Session ID (New per launch)
    _sessionId = const Uuid().v4();

    // App Version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (e) {
      _appVersion = 'unknown';
    }

    _isInitialized = true;
    debugPrint('[Analytics] Initialized. Session: $_sessionId');

    // Attempt initial flush
    flush();
  }

  /// Track an event.
  /// [eventName] should be from the whitelist.
  /// [properties] are optional key-value pairs.
  Future<void> track(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) await init();

    try {
      final sanitizedProps = AnalyticsEvent.sanitizeProperties(
        properties ?? {},
      );

      final event = AnalyticsEvent(
        clientEventId: const Uuid().v4(),
        occurredAt: DateTime.now().toUtc().toIso8601String(),
        anonUserId: _anonUserId,
        sessionId: _sessionId,
        eventName: eventName,
        schemaVersion: 1,
        platform: _platform,
        appVersion: _appVersion,
        properties: sanitizedProps,
      );

      // Enqueue
      await _dao.enqueue(event);

      if (kDebugMode) {
        print('[Analytics] Enqueued: $eventName');
      }

      // Check queue size for auto-flush threshold
      final size = await _dao.getQueueSize();
      if (size >= 20) {
        flush();
      }
    } catch (e, st) {
      debugPrint('[Analytics] Track failed: $e\n$st');
    }
  }

  /// Attempt to flush the queue to the backend.
  Future<void> flush() async {
    if (_isFlushing) return;

    // Check connectivity first
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      debugPrint('[Analytics] Flush skipped (no connection)');
      return;
    }

    _isFlushing = true;
    List<String> currentBatchIds = [];

    try {
      // 1. Prune
      await _dao.prune(maxRows: 5000);

      // 2. Get Batch
      final batch = await _dao.getBatch(limit: 100);
      if (batch.isEmpty) {
        return; // Nothing to send
      }

      currentBatchIds = batch.map((e) => e.clientEventId).toList();
      debugPrint('[Analytics] Flushing batch of ${batch.length} events...');

      // 3. Prepare Payload
      // Decode the stored JSON strings to Maps
      final eventsToSend =
          batch.map((e) {
            return jsonDecode(e.payloadJson) as Map<String, dynamic>;
          }).toList();

      // 4. Send
      await _remote.sendEvents(eventsToSend);

      // 5. Success
      await _dao.markBatchSucceeded(currentBatchIds);
      debugPrint('[Analytics] Flush success.');

      // Recursive flush if we filled the batch
      if (batch.length == 100) {
        _isFlushing = false;
        flush();
        return;
      }
    } catch (e) {
      debugPrint('[Analytics] Flush failed: $e');
      // 6. Failure - update attempts and backoff
      if (currentBatchIds.isNotEmpty) {
        await _dao.markBatchFailed(currentBatchIds);
      }
    } finally {
      _isFlushing = false;
    }
  }

  // Debug helpers
  Future<int> getQueueSize() => _dao.getQueueSize();
}
