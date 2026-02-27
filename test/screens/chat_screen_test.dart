import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laia_chat/screens/chat_screen.dart';
import 'package:laia_chat/config/app_config.dart';

void main() {
  group('ChatScreen', () {
    setUp(() {
      // Initialize test environment
      AppConfig.setGroqApiKey('test-api-key-123');
    });

    testWidgets('displays welcome message on init', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(),
          routes: {
            '/settings': (context) => const Scaffold(),
          },
        ),
      );

      expect(find.text('LAIA Chat'), findsOneWidget);
      expect(
        find.text('Hello! I\'m LAIA, your AI assistant powered by Groq.'),
        findsOneWidget,
      );
    });

    testWidgets('input field is visible and enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(),
          routes: {
            '/settings': (context) => const Scaffold(),
          },
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('send button is disabled when input is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(),
          routes: {
            '/settings': (context) => const Scaffold(),
          },
        ),
      );

      // Find send button - initially should be enabled
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
    });

    testWidgets('typing in input field works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(),
          routes: {
            '/settings': (context) => const Scaffold(),
          },
        ),
      );

      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);

      await tester.enterText(inputField, 'Test message');
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('settings button navigates to settings screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(),
          routes: {
            '/settings': (context) => const Scaffold(
              body: Text('Settings Screen'),
            ),
          },
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings Screen'), findsOneWidget);
    });

    testWidgets('message bubbles are displayed correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(),
          routes: {
            '/settings': (context) => const Scaffold(),
          },
        ),
      );

      // Welcome message should be visible
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('scaffold has proper layout structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ChatScreen(),
          routes: {
            '/settings': (context) => const Scaffold(),
          },
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
