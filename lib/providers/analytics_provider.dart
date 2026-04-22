import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/database_provider.dart';
import '../analytics/analytics_flush_scheduler.dart';
import '../analytics/analytics_service.dart';
import '../analytics/data/analytics_queue_dao.dart';
import '../analytics/data/analytics_remote_datasource.dart';

/// SharedPrefs provider (assuming you might have one, if not we create a basic one or use main's)
/// For now, we'll create a future provider or assume it's available.
/// Actually, a better pattern is to override a provider in main.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final analyticsQueueDaoProvider = Provider<AnalyticsQueueDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AnalyticsQueueDao(db);
});

final analyticsRemoteDatasourceProvider = Provider<AnalyticsRemoteDatasource>((
  ref,
) {
  return AnalyticsRemoteDatasource(Supabase.instance.client);
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final dao = ref.watch(analyticsQueueDaoProvider);
  final remote = ref.watch(analyticsRemoteDatasourceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AnalyticsService(dao, remote, prefs);
});

final analyticsFlushSchedulerProvider = Provider<AnalyticsFlushScheduler>((
  ref,
) {
  final service = ref.watch(analyticsServiceProvider);
  return AnalyticsFlushScheduler(service);
});
