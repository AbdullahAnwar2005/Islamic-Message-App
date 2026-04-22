import 'package:alghaya_men_alkhalg/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final availableLanguagesProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final rows = await db.customSelect(
    'SELECT DISTINCT language_code FROM translations ORDER BY language_code;',
    readsFrom: {db.translations},
  ).get();

  return rows.map((row) => row.data['language_code'] as String).toList();
});
