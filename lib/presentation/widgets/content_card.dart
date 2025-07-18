import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../data/local/models/full_message_model.dart';
import 'language_button.dart';
import '../../providers/audio_player_provider.dart';

class ContentCard extends ConsumerWidget {
  final FullMessageModel message;
  final VoidCallback onRead;
  final VoidCallback onPlay;
  final ValueChanged<String?> onChangeLanguage;

  const ContentCard({
    super.key,
    required this.message,
    required this.onRead,
    required this.onPlay,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final translation = message.translation;
    final langCode = translation.languageCode;
    final audioPath = translation.audioPath;

    final audioState = ref.watch(audioPlayerProvider(message.id));
    final audioNotifier = ref.read(audioPlayerProvider(message.id).notifier);

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.lightCardBoarder, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔘 زر اختيار اللغة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LanguageButton(
                  currentLanguageLabel: _getLanguageLabel(langCode),
                  currentLanguageCode: langCode,
                  onLanguageSelected: (newLang) {
                    if (newLang != null && newLang != langCode) {
                      onChangeLanguage(newLang);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// 🟢 العنوان
            Text(
              message.title,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 8),

            /// 📝 الوصف
            Text(
              extractDescriptionFromText(translation.content),
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            ),
            const SizedBox(height: 12),

            /// 🔊 الصوت + القراءة + الوقت
            Row(
              children: [
                IconButton(
                  onPressed: audioPath == null || audioPath.isEmpty
                      ? null
                      : () {
                    if (!audioState.isPlaying) {
                      if (audioNotifier.currentAssetPath != audioPath) {
                        audioNotifier.setAsset(audioPath).then((_) => audioNotifier.play());
                      } else {
                        audioNotifier.play();
                      }
                    } else {
                      audioNotifier.pause();
                    }
                  },
                  icon: Icon(
                    audioState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  ),
                  color: theme.colorScheme.primary,
                  iconSize: 32,
                ),
                Text(
                  "${_formatDuration(audioState.position)} / ${_formatDuration(audioState.duration)}",
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onRead,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('اقرأ'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),

            /// 🟦 شريط التقدم (إذا كان هناك مدة)
            if (audioState.duration > Duration.zero)
              Slider(
                min: 0,
                max: audioState.duration.inMilliseconds.toDouble(),
                value: audioState.position.inMilliseconds
                    .clamp(0, audioState.duration.inMilliseconds)
                    .toDouble(),
                onChanged: (value) {
                  audioNotifier.seek(Duration(milliseconds: value.toInt()));
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return code;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// 🧠 وصف من أول مقطع بعد أول عنوان
  String extractDescriptionFromText(String fullText) {
    final lines = fullText.split('\n');
    bool afterFirstTitle = false;
    final buffer = StringBuffer();

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('##')) {
        afterFirstTitle = true;
        continue;
      }

      if (afterFirstTitle && trimmed.isNotEmpty) {
        buffer.writeln(trimmed);
        if (buffer.length > 200) break;
      }
    }

    return buffer.toString().trim();
  }
}
