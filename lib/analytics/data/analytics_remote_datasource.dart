import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsRemoteDatasource {
  final SupabaseClient _supabase;

  AnalyticsRemoteDatasource(this._supabase);

  /// Sends a batch of events to the 'ingest-events' Edge Function.
  /// Throws an exception on failure.
  Future<void> sendEvents(List<Map<String, dynamic>> events) async {
    if (events.isEmpty) return;

    try {
      await _supabase.functions.invoke(
        'ingest-events',
        body: {'events': events},
      );
    } on FunctionException catch (e) {
      throw Exception('Ingest function failed: $e');
    } catch (e) {
      throw Exception('Failed to send events: $e');
    }
  }
}
