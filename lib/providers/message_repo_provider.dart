import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/message_repository.dart';
import 'database_provider.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MessageRepository(db);
});
