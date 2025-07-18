import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_player_provider.dart';

class AudioControls extends ConsumerWidget {
  final int messageId;
  final String? audioPath;

  const AudioControls({
    super.key,
    required this.messageId,
    required this.audioPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerProvider(messageId));
    final notifier = ref.read(audioPlayerProvider(messageId).notifier);

    if (audioPath == null || audioPath!.isEmpty) {
      return const Text('🎧 لا يتوفر ملف صوتي لهذه الرسالة.');
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                state.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                size: 32,
              ),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                if (!state.isPlaying) {
                  if (notifier.currentAssetPath != audioPath) {
                    notifier.setAsset(audioPath!).then((_) {
                      notifier.play();
                    });
                  } else {
                    notifier.play();
                  }
                } else {
                  notifier.pause();
                }
              },
            ),
            Text(
              "${_format(state.position)} / ${_format(state.duration)}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        if (state.duration > Duration.zero)
          Slider(
            min: 0,
            max: state.duration.inMilliseconds.toDouble(),
            value: state.position.inMilliseconds
                .clamp(0, state.duration.inMilliseconds)
                .toDouble(),
            onChanged: (value) {
              notifier.seek(Duration(milliseconds: value.toInt()));
            },
          ),
      ],
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
