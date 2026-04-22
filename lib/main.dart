// lib/main.dart
import 'package:alghaya_men_alkhalg/providers/audio_service_providers.dart';
import 'package:alghaya_men_alkhalg/providers/sync_provider.dart'
    show syncInFlightProvider;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_config.dart';
import 'providers/app_locale_provider.dart';

import 'data/audio/app_audio_handler.dart';
import 'data/local/app_database.dart';
import 'providers/database_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/message_provider.dart';
import 'providers/language_preference_provider.dart';
import 'providers/sync_throttle_provider.dart';
import 'providers/analytics_provider.dart';
import 'analytics/analytics_navigator_observer.dart';

import 'presentation/screens/home_screen.dart';
import 'presentation/screens/language_selection_screen.dart';
import 'presentation/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// H-2: Startup crash handler hooks
// ---------------------------------------------------------------------------
void _setupErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      Sentry.captureException(details.exception, stackTrace: details.stack);
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('[PlatformError] $error\n$stack');
    } else {
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  };
}

// ---------------------------------------------------------------------------
// Auto-sync with 15-minute throttling and a 15-second hard timeout (H-2)
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// START-01: Fire-and-forget sync — runs AFTER runApp so UI is never blocked.
// Sets syncInFlightProvider = true while in flight so HomeScreen can show
// an appropriate loading state instead of a blank screen.
// ---------------------------------------------------------------------------
void _triggerBackgroundSync(ProviderContainer container) {
  // Mark sync as starting
  container.read(syncInFlightProvider.notifier).state = true;

  _runAutoSyncIfNeeded(container).whenComplete(() {
    // Mark sync as done — HomeScreen reacts via syncInFlightProvider
    container.read(syncInFlightProvider.notifier).state = false;
  });
}

Future<void> _runAutoSyncIfNeeded(ProviderContainer container) async {
  final prefs = await SharedPreferences.getInstance();
  final alreadySyncedOnce = prefs.getBool('isSyncedOnce') ?? false;
  final throttle = container.read(syncThrottleProvider);

  try {
    final dbIsEmpty = await isDbEmpty(container);

    if (!alreadySyncedOnce || dbIsEmpty) {
      if (kDebugMode)
        debugPrint('[startup] Running BLOCKING sync (first run or DB empty)');
      // H-2: wrap first-run (blocking) sync in a hard 20-second timeout
      await container
          .read(syncServiceProvider)
          .run(initial: !alreadySyncedOnce)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              if (kDebugMode)
                debugPrint(
                  '[startup] First-run sync timed out after 20s; continuing with local DB',
                );
            },
          );

      await prefs.setBool('isSyncedOnce', true);
      await throttle.recordSync();
      container.invalidate(messagesWithTranslationsProvider);
    } else {
      final shouldRunSync = await throttle.shouldSync();
      if (shouldRunSync) {
        if (kDebugMode)
          debugPrint('[startup] Running throttled background sync');
        // Non-blocking background sync also gets a timeout
        container
            .read(syncServiceProvider)
            .run(initial: false)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                if (kDebugMode)
                  debugPrint('[startup] Background sync timed out');
              },
            )
            .then((_) {
              throttle.recordSync();
              container.invalidate(messagesWithTranslationsProvider);
            })
            .catchError((e) {
              container.read(syncStatusProvider.notifier).state =
                  SyncStatus.failed;
              if (kDebugMode)
                debugPrint('[startup] Background sync failed: $e');
            });
      } else {
        if (kDebugMode) {
          final minutesRemaining = await throttle.getMinutesUntilNextSync();
          debugPrint(
            '[startup] Skipping sync. Next sync in $minutesRemaining minutes',
          );
        }
      }
    }
  } catch (e, st) {
    if (kDebugMode) debugPrint('[startup] Auto-sync failed (ignored): $e\n$st');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // L-6: crash reporting hooks
  _setupErrorHandlers();

  // B-1: no dotenv.load — credentials come from AppConfig (dart-define)

  await JustAudioBackground.init(
    androidNotificationChannelId: 'alghaya.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
    preloadArtwork: true,
  );

  // Audio focus / session — interrupted by phone calls etc.
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  // M-6: handle audio session interruptions (phone calls, notifications)
  session.interruptionEventStream.listen((event) {
    // Handled inside AppAudioHandler via audio_session; no extra action needed here
    // but we listen to ensure the stream is observed.
  });

  // B-3: SINGLE handler instance — this is the only AudioPlayer owner
  final handler = AppAudioHandler();

  // B-1: Use AppConfig instead of dotenv
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final db = AppDatabase.background();

  // B-2: ONE override for appDatabaseProvider (was duplicated)
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      audioHandlerProvider.overrideWithValue(handler),
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
    ],
  );

  // Analytics
  final analytics = container.read(analyticsServiceProvider);
  await analytics.init();
  container.read(analyticsFlushSchedulerProvider).start();

  handler.setAnalytics(analytics);

  // START-01: Trigger sync in background AFTER runApp — never blocks UI.
  _triggerBackgroundSync(container);

  // A11Y-01: Use edgeToEdge as default; ReadScreen applies immersive per-scroll.
  // A11Y-03: Clamp textScaler to max 1.4 — applied via MediaQuery in MyApp.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '',
      );
      options.tracesSampleRate = 1.0;
    },
    appRunner:
        () => runApp(
          UncontrolledProviderScope(container: container, child: const MyApp()),
        ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final appLocale = ref.watch(appLocaleProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      locale: appLocale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorObservers: [
        AnalyticsNavigatorObserver(ref.read(analyticsServiceProvider)),
      ],
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      // A11Y-03: Clamp textScaler to max 1.4 to prevent overflow on compact
      // widgets (filter chips, audio header card) while preserving "Large" text
      // accessibility. Tested at 1.0, 1.2, 1.4. Above 1.4 causes overflow.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clampedScale = mq.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.4,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clampedScale),
          child: child!,
        );
      },
      home: const _InitialScreen(),
    );
  }
}

/// Determines whether to show language selection or home screen
class _InitialScreen extends ConsumerWidget {
  const _InitialScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedAsync = ref.watch(hasCompletedLanguageSelectionProvider);

    return hasCompletedAsync.when(
      data: (hasCompleted) {
        if (hasCompleted) {
          return const HomeScreen();
        } else {
          // ONB-01: Route first-timers to LanguageSelectionScreen.
          // That screen navigates to OnboardingScreen on completion.
          return const LanguageSelectionScreen();
        }
      },
      // H-2: show a labeled loading screen with app branding, not a blank screen
      loading: () => const _StartupLoadingScreen(),
      error: (_, __) => const HomeScreen(), // Fallback to home on error
    );
  }
}

/// START-02: Bilingual branded spinner — shown before locale is read from prefs.
/// Does not depend on locale so text is always readable regardless of saved lang.
class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_rounded, size: 64, color: Colors.teal),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'رسالة الإسلام  •  Message of Islam',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
