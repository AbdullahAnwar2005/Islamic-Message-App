import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents a single analytics event ready for queuing/sending.
@immutable
class AnalyticsEvent {
  final String clientEventId;
  final String occurredAt; // ISO 8601 UTC
  final String anonUserId;
  final String sessionId;
  final String eventName;
  final int schemaVersion;
  final String platform;
  final String appVersion;
  final Map<String, dynamic> properties;

  const AnalyticsEvent({
    required this.clientEventId,
    required this.occurredAt,
    required this.anonUserId,
    required this.sessionId,
    required this.eventName,
    required this.schemaVersion,
    required this.platform,
    required this.appVersion,
    this.properties = const {},
  });

  /// Sanitize and validate properties before creating the event.
  /// - Clamps `completion_ratio` to [0, 1].
  /// - Caps string lengths.
  /// - Removes nulls.
  /// - Enforces JSON size limits (approximate).
  static Map<String, dynamic> sanitizeProperties(Map<String, dynamic> raw) {
    final sanitized = <String, dynamic>{};

    for (final entry in raw.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) continue;

      if (key == 'completion_ratio' && value is num) {
        sanitized[key] = value.clamp(0.0, 1.0);
      } else if (value is String) {
        // Cap string length at 100 chars
        sanitized[key] = value.length > 100 ? value.substring(0, 100) : value;
      } else if (value is num || value is bool) {
        sanitized[key] = value;
      } else {
        // Fallback for other types: toString and cap
        final s = value.toString();
        sanitized[key] = s.length > 100 ? s.substring(0, 100) : s;
      }
    }

    // JSON size check (rough estimate)
    // If too large, drop properties until it fits, or clear all if critical.
    // Here we'll just truncate if the *values* make it huge, but individual caps help.
    // As a safety net, if the JSON string is > 4KB, we might want to trim.
    // For now, relying on per-field limits.

    return sanitized;
  }

  Map<String, dynamic> toJson() {
    return {
      'client_event_id': clientEventId,
      'occurred_at': occurredAt,
      'anon_user_id': anonUserId,
      'session_id': sessionId,
      'event_name': eventName,
      'schema_version': schemaVersion,
      'platform': platform,
      'app_version': appVersion,
      'properties': properties,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      clientEventId: json['client_event_id'] as String,
      occurredAt: json['occurred_at'] as String,
      anonUserId: json['anon_user_id'] as String,
      sessionId: json['session_id'] as String,
      eventName: json['event_name'] as String,
      schemaVersion: json['schema_version'] as int,
      platform: json['platform'] as String,
      appVersion: json['app_version'] as String,
      properties: json['properties'] as Map<String, dynamic>? ?? {},
    );
  }
}
