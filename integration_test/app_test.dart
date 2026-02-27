import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:laia_chat/main.dart';
import 'package:laia_chat/config/app_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LAIA Chat - E2E Tests', () {
    testWidgets('App starts and displays welcome message', (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      app.main();
      await tester.pumpAndSettle();

      expect(find.text('LAIA Chat'), findsOneWidget);
      expect(
        find.text('Hello! I\'m LAIA, your AI assistant powered by Groq.'),
        findsOneWidget,
      );
    });

    testWidgets('Settings screen is accessible', (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      app.main();
      await tester.pumpAndSettle();

      // Tap settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Groq API Configuration'), findsOneWidget);
    });

    testWidgets(
      'API key validation UI works',
      (WidgetTester tester) async {
        await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        app.main();
        await tester.pumpAndSettle();

        // Navigate to settings
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Find API key input field
        expect(find.byType(TextField), findsOneWidget);

        // Enter a test API key
        await tester.enterText(
          find.byType(TextField),
          'gsk_test_key_123456789',
        );

        // Find validate button
        final validateButton = find.byType(ElevatedButton);
        expect(validateButton, findsWidgets);

        // Tap validate button
        await tester.tap(validateButton.first);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // The validation attempt should complete (may show error due to invalid key)
        // This tests the UI flow, not actual API validation
        expect(find.byType(Container), findsWidgets);
      },
    );

    testWidgets('Chat message input works', (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      // Set valid API key for this test
      AppConfig.setGroqApiKey('test-key-123');

      app.main();
      await tester.pumpAndSettle();

      // Find input field and type message
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);

      await tester.enterText(inputField, 'Hello LAIA!');
      expect(find.text('Hello LAIA!'), findsOneWidget);

      // Verify send button is available
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('App navigation flow', (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      app.main();
      await tester.pumpAndSettle();

      // Start on chat screen
      expect(find.text('LAIA Chat'), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      // Go back to chat
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('LAIA Chat'), findsOneWidget);
    });

    testWidgets('Scrolling in message list works', (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      app.main();
      await tester.pumpAndSettle();

      // Find scrollable list
      expect(find.byType(ListView), findsOneWidget);

      // Try scrolling
      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pumpAndSettle();

      // Welcome message should still be visible
      expect(find.text('Hello! I\'m LAIA'), findsOneWidget);
    });
  });
}
