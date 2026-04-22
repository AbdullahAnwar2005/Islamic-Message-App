// database_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/app_database.dart';


// providers/database_provider.dart
final appDatabaseProvider = Provider<AppDatabase>(
      (ref) => throw UnimplementedError('Override me in main.dart'),
  name: 'appDatabaseProvider',
);

