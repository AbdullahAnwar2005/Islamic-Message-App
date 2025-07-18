import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageLanguageProvider =
StateNotifierProvider<MessageLanguageNotifier, String>((ref) {
  return MessageLanguageNotifier();
});

class MessageLanguageNotifier extends StateNotifier<String> {
  MessageLanguageNotifier() : super('ar'); // default

  void toggle() {
    state = state == 'ar' ? 'en' : 'ar'; // expand to more later
  }

  void setLanguage(String langCode) {
    state = langCode;
  }
}
