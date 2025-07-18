import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/message_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/message_language_provider.dart';

import '../widgets/content_card.dart';
import 'read_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final languageCode = ref.watch(messageLanguageProvider);
    final messagesAsync = ref.watch(messagesProvider(languageCode));

    return Scaffold(
      appBar: AppBar(
        title: const Text('رسالة الإسلام'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            onPressed: () => _toggleTheme(ref, themeMode),
          ),
        ],
      ),
      drawer: Drawer(

      ),
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('حدث خطأ: $err')),
        data: (messages) {
          if (messages.isEmpty) {
            return const Center(child: Text('لا توجد رسائل بعد'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final translation = message.translation;
              final audioPath = translation.audioPath;

              return ContentCard(
                message: message,
                onRead: () => _openReadScreen(context, message.id),
                onChangeLanguage: (newLangCode) =>
                    _changeLanguage(ref, newLangCode),
                onPlay: () => _handleAudioPlay(ref, message.id, audioPath),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleTheme(WidgetRef ref, ThemeMode currentMode) {
    final newMode =
    currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    ref.read(themeProvider.notifier).setTheme(newMode);
  }

  void _changeLanguage(WidgetRef ref, String? newLangCode) {
    if (newLangCode == null) return;
    ref.read(messageLanguageProvider.notifier).setLanguage(newLangCode);
    ref.invalidate(messagesProvider);
  }

  void _openReadScreen(BuildContext context, int messageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageScreen(messageId: messageId),
      ),
    );
  }

  void _handleAudioPlay(WidgetRef ref, int messageId, String? audioPath) {
    if (audioPath == null || audioPath.isEmpty) return;

    final notifier = ref.read(audioPlayerProvider(messageId).notifier);
    final playerState = ref.read(audioPlayerProvider(messageId));

    final currentAsset = notifier.currentAssetPath;

    if (!playerState.isPlaying) {
      if (currentAsset != audioPath) {
        notifier.setAsset(audioPath).then((_) => notifier.play());
      } else {
        notifier.play();
      }
    } else {
      notifier.pause();
    }
  }
}
