import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_database.dart';
import '../models/message_json_model.dart';

class ContentInitializer {
  final AppDatabase db;

  ContentInitializer(this.db);

  Future<void> initialize({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('isContentInitialized') ?? false;

    if (isInitialized && !force) return;

    // 🔴 حذف كل الرسائل أولاً إذا طلبنا force
    if (force) {
      await db.clearAllMessages();
    }

    final jsonString = await rootBundle.loadString('assets/messages.json');
    final jsonData = json.decode(jsonString);
    final List<dynamic> messagesList = jsonData['messages'];

    for (var msg in messagesList) {
      final message = MessageJsonModel.fromJson(msg);
      final messageId = await db.insertMessage(
        MessagesCompanion.insert(title: message.title),
      );

      for (var translation in message.translations) {
        await db.insertMessageTranslation(
          MessageTranslationsCompanion.insert(
            messageId: messageId,
            languageCode: translation.languageCode,
            content: translation.content,
            audioPath: Value(translation.audioPath ?? ''),
          ),
        );
      }
    }

    await prefs.setBool('isContentInitialized', true);
    print('✅ Local content initialized successfully.');
  }
}
