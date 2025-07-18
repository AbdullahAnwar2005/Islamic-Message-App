import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/message_repo_provider.dart';


import 'package:flutter/foundation.dart';

import '../data/local/models/full_message_model.dart';

@immutable
class MessageParams {
  final int messageId;
  final String languageCode;

  const MessageParams({
    required this.messageId,
    required this.languageCode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MessageParams &&
              runtimeType == other.runtimeType &&
              messageId == other.messageId &&
              languageCode == other.languageCode;

  @override
  int get hashCode => messageId.hashCode ^ languageCode.hashCode;
}


/// ✅ مزوّد لجلب جميع الرسائل بلغة معينة
final messagesProvider = FutureProvider.family<List<FullMessageModel>, String>((ref, languageCode) async {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.getAllMessagesByLanguage(languageCode);
});


/// ✅ مزوّد لجلب رسالة واحدة (العنوان + الترجمة) حسب id واللغة
final messageProvider = FutureProvider.family<FullMessageModel?, MessageParams>((ref, params) async {
  final repo = ref.watch(messageRepositoryProvider);
  return repo.getMessageWithTranslation(params.messageId, params.languageCode);
});
