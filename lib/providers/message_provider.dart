// lib/providers/message_provider.dart
//
// H-1 FIX: Eliminated N+1 query pattern.
//   Old: 1 query for messages + 1 per message for translations = O(N) queries.
//   New: 2 bulk queries + in-memory O(N) grouping.
//
// M-3 FIX: Removed silent `orElse: () => list.first` fallback.
//   Callers must handle the null case and show an error/not-found state.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../data/local/app_database.dart';
import 'database_provider.dart';

/// A small data holder combining one message with its translations.
class MessageWithTranslations {
  final Message message;
  final List<Translation> translations;
  MessageWithTranslations({required this.message, required this.translations});
}

/// Fetch all messages + translations using 2 bulk queries (H-1).
/// Returns null entries when no translation is found (safe pattern).
final messagesWithTranslationsProvider =
    FutureProvider<List<MessageWithTranslations>>((ref) async {
      final db = ref.read(appDatabaseProvider);

      // Two bulk queries — no N+1
      final messages = await db.select(db.messages).get();
      final allTrs = await db.select(db.translations).get();

      // Group translations by messageId in memory (O(N))
      final trsByMsg = <int, List<Translation>>{};
      for (final t in allTrs) {
        trsByMsg.putIfAbsent(t.messageId, () => []).add(t);
      }

      return messages
          .map(
            (m) => MessageWithTranslations(
              message: m,
              translations: trsByMsg[m.id] ?? [],
            ),
          )
          .toList();
    });

class SectionWithMessages {
  final Section section;
  final List<MessageWithTranslations> items;
  SectionWithMessages({required this.section, required this.items});
}

final homeSectionsProvider = FutureProvider<List<SectionWithMessages>>((
  ref,
) async {
  final db = ref.read(appDatabaseProvider);

  try {
    // 1. Sections (sorted)
    final sections =
        await (db.select(db.sections)
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)])).get();

    // 2. Messages + translations — bulk fetch, H-1 pattern
    final messages = await db.select(db.messages).get();
    final allTrs = await db.select(db.translations).get();

    // Group translations by messageId
    final trsByMsg = <int, List<Translation>>{};
    for (final t in allTrs) {
      trsByMsg.putIfAbsent(t.messageId, () => []).add(t);
    }

    // Group MessageWithTranslations by sectionId
    final msgsBySection = <int, List<MessageWithTranslations>>{};
    for (final msg in messages) {
      final bundle = MessageWithTranslations(
        message: msg,
        translations: trsByMsg[msg.id] ?? [],
      );
      if (msg.sectionId != null) {
        msgsBySection.putIfAbsent(msg.sectionId!, () => []).add(bundle);
      }
    }

    // Build result following section order
    return sections
        .map(
          (sec) => SectionWithMessages(
            section: sec,
            items: msgsBySection[sec.id] ?? [],
          ),
        )
        .toList();
  } catch (e, st) {
    if (kDebugMode) debugPrint('🔥 Error loading home sections: $e\n$st');
    rethrow;
  }
});
