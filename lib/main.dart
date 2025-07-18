import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui' as ui;
import 'data/local/initialization/initialize_app_content.dart';
import 'data/remote/services/supabase_services.dart';
import 'data/remote/services/sync_content_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final container = ProviderContainer();
  final db = container.read(databaseProvider);

  final initializer = ContentInitializer(db);
  await initializer.initialize(force: true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Supabase.initialize(
    url: 'https://rrkdezxuegeemyuxmzcq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJya2Rlenh1ZWdlZW15dXhtemNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4OTYzNDUsImV4cCI6MjA2NzQ3MjM0NX0.j1RgzW5ol6mmAx1P80FpZCaxOWp-qvXC5zxIKs2291A',
  );
  final hasConnection = await Connectivity().checkConnectivity();
  if (hasConnection != ConnectivityResult.none) {
    final syncService = SyncService(db, SupabaseService());
    await syncService.syncMessages();
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      builder: (context, child) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: child!,
      ),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
