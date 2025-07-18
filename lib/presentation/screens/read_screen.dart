import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/font_size_provider.dart';
import '../../providers/message_language_provider.dart';
import '../../providers/message_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../widgets/language_button.dart';
import '../../core/constants.dart';

class MessageScreen extends ConsumerWidget {
  final int messageId;

  const MessageScreen({super.key, required this.messageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLanguage = ref.watch(messageLanguageProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final langCode = ref.watch(messageLanguageProvider);
    final messageAsync = ref.watch(
      messageProvider(MessageParams(messageId: messageId, languageCode: langCode)),
    );

    final audioState = ref.watch(audioPlayerProvider(messageId));
    final audioNotifier = ref.read(audioPlayerProvider(messageId).notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: messageAsync.when(
          data: (msg) => Text(msg?.title ?? 'بدون عنوان'),
          loading: () => const Text('...'),
          error: (_, __) => const Text('خطأ'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showFontSizeSelector(context, ref),
            tooltip: 'تغيير حجم الخط',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LanguageButton(
                currentLanguageLabel: _getLanguageLabel(currentLanguage),
                currentLanguageCode: currentLanguage,
                onLanguageSelected: (newLangCode) {
                  if (newLangCode != currentLanguage) {
                    ref.read(messageLanguageProvider.notifier).setLanguage(newLangCode);
                  }
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: messageAsync.when(
                  data: (message) {
                    if (message == null) {
                      return const Center(child: Text('لا توجد رسالة متاحة'));
                    }
                    return Directionality(
                      textDirection: currentLanguage == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _buildTextSections(
                            message.translation.content,
                            theme,
                            fontSize,
                            currentLanguage,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text(
                      '⚠️ حدث خطأ في تحميل النص.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: messageAsync.maybeWhen(
        data: (msg) {
          final audioPath = msg?.translation.audioPath;
          if (audioPath == null || audioPath.isEmpty) return null;

          return FloatingActionButton(
            onPressed: () {
              audioNotifier.setAsset(audioPath).then((_) {
                audioNotifier.play();
                ScaffoldMessenger.of(context).showMaterialBanner(
                  MaterialBanner(
                    content: const Text('📖 الصوت يعمل الآن'),
                    leading: const Icon(Icons.volume_up),
                    actions: [
                      TextButton(
                        onPressed: () {
                          audioNotifier.pause();
                          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                        },
                        child: const Text('إيقاف'),
                      ),
                    ],
                  ),
                );
              });
            },

            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.play_arrow),
          );
        },
        orElse: () => null,
      ),
    );
  }

  List<Widget> _buildTextSections(
      String text, ThemeData theme, double fontSize, String langCode) {
    final isArabic = langCode == 'ar';

    return text.split('\n').map((line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return const SizedBox(height: 12);

      if (trimmed.contains('﴿') && trimmed.contains('﴾')) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _cleanText(trimmed),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                  fontFamily: AppFontFamilies.uthmanicRegular,
                  height: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      if (trimmed.startsWith('##')) {
        final title = trimmed.replaceFirst('##', '').trim();
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Text(
              _cleanText(title),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: fontSize + 4,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          _cleanText(trimmed),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: fontSize,
            height: 1.8,
          ),
          textAlign: TextAlign.justify,
        ),
      );
    }).toList();
  }

  String _getLanguageLabel(String code) {
    return switch (code) {
      'ar' => 'العربية',
      'en' => 'English',
      'fr' => 'Français',
      _ => code,
    };
  }

  String _cleanText(String text) {
    return text
        .replaceAll('\u202A', '')
        .replaceAll('\u202B', '')
        .replaceAll('\u202C', '')
        .replaceAll('\u202D', '')
        .replaceAll('\u202E', '')
        .replaceAll('\u061C', '')
        .replaceAll('\u200E', '')
        .replaceAll('\u200F', '')
        .trim();
  }

  void _showFontSizeSelector(BuildContext context, WidgetRef ref) {
    final fontSizeNotifier = ref.read(fontSizeProvider.notifier);
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('تعديل حجم الخط', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final size = ref.watch(fontSizeProvider);
                  return Slider(
                    value: size,
                    min: 14,
                    max: 24,
                    divisions: 5,
                    label: '${size.round()}',
                    onChanged: (value) => fontSizeNotifier.setFontSize(value),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
