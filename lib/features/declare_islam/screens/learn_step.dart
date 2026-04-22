import 'package:alghaya_men_alkhalg/presentation/screens/contact_us_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../localization/app_strings.dart';
import '../providers/declare_islam_provider.dart';
import '../../../../providers/analytics_provider.dart';

class LearnStepWidget extends ConsumerStatefulWidget {
  const LearnStepWidget({super.key});

  @override
  ConsumerState<LearnStepWidget> createState() => _LearnStepWidgetState();
}

class _LearnStepWidgetState extends ConsumerState<LearnStepWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    // _initAudio(); // TEMPORARY DISABLE: Audio not yet available
  }

  Future<void> _initAudio() async {
    try {
      setState(() => _isLoadingAudio = true);
      // TODO: Replace with actual Shahada audio URL
      await _player.setUrl(
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      );
      // Using a placeholder for now as requested. Ideally this should be a local asset or specific URL.
      // If we have asset: await _player.setAsset('assets/audio/shahada.mp3');

      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
              _player.seek(Duration.zero);
              _player.pause();
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Error loading audio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.of(
                context,
                'audio_loading_error',
              ).replaceFirst('{0}', ''),
            ),
            action: SnackBarAction(
              label: AppStrings.of(context, 'retry'),
              onPressed: _initAudio,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAudio = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _toggleSpeed() {
    setState(() {
      _speed = _speed == 1.0 ? 0.75 : 1.0;
      _player.setSpeed(_speed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Arabic Shahada Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  AppStrings.of(context, 'di_learn_shahada_ar'),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    height: 2.0,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                // Audio Controls
                /* TEMPORARY DISABLE: Audio not yet available
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _isLoadingAudio ? null : _togglePlay,
                      icon:
                          _isLoadingAudio
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                _isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: _toggleSpeed,
                      child: Text(
                        "${_speed}x",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                */
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(
                    context,
                    'shahada_english',
                  ), // Reusing existing string
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(context, 'shahada_transliteration'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).disabledColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          FilledButton(
            onPressed: () {
              ref
                  .read(analyticsServiceProvider)
                  .track(
                    'shahada_step_complete',
                    properties: {'step_index': 1}, // Completed Learn Step
                  );
              ref
                  .read(declareIslamProvider.notifier)
                  .goToStep(DeclareIslamStep.readiness);
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              AppStrings.of(context, 'di_learn_btn_next'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              );
            },
            icon: const Icon(Icons.support_agent),
            label: Text(AppStrings.of(context, 'di_learn_btn_contact')),
          ),
        ],
      ),
    );
  }
}
