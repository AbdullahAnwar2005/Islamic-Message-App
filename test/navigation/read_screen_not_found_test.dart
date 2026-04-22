import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alghaya_men_alkhalg/presentation/screens/read_screen.dart';
import 'package:alghaya_men_alkhalg/providers/message_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'NAV-01: ReadScreen shows error UI and does not crash when message is not found',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override the provider to return an empty list, simulating a missing message
            messagesWithTranslationsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('ar')],
            home: ReadScreen(messageId: 9999),
          ),
        ),
      );

      // It takes a frame for FutureProvider to resolve
      await tester.pumpAndSettle();

      // Verify the error screen is shown instead of a StateError crash
      // We look for the "Message not found" icon or background
      expect(find.byIcon(Icons.find_in_page_outlined), findsOneWidget);
    },
  );
}
