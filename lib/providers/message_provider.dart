import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_section.dart';
import '../services/message_service.dart';

final messageServiceProvider = Provider((ref) => MessageService());

final messageProvider = StateNotifierProvider<MessageNotifier, AsyncValue<List<MessageSection>>>(
      (ref) => MessageNotifier(ref.watch(messageServiceProvider)),
);

class MessageNotifier extends StateNotifier<AsyncValue<List<MessageSection>>> {
  final MessageService service;

  MessageNotifier(this.service) : super(const AsyncLoading());

  Future<void> load(String langCode) async {
    state = const AsyncLoading();
    try {
      final sections = await service.loadSections(langCode);
      state = AsyncValue.data(sections);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
