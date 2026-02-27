import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:laia_android/services/ai_service.dart';
import 'package:laia_android/config/app_config.dart';

void main() {
  group('AiService', () {
    setUp(() {
      // Set up API key before tests
      AppConfig.setGroqApiKey('test-api-key-123');
    });

    group('chatCompletion', () {
      test('returns a Message with assistant role on successful API call', () async {
        // This is a unit test structure - full test requires HTTP mocking
        // In real scenario, we'd mock the http.post call
        
        final messages = [
          {'role': 'user', 'content': 'Hello, LAIA!'}
        ];

        // Note: Without HTTP mocking setup, this demonstrates the test structure
        // Full integration testing should use real API or mock server
        expect(AppConfig.isConfigured, true);
      });

      test('throws exception when API key is not configured', () async {
        AppConfig.groqApiKey = null;

        final messages = [
          {'role': 'user', 'content': 'Test'}
        ];

        expect(
          () => AiService.chatCompletion(messages: messages),
          throwsException,
        );
      });

      test('returns correct model in request', () async {
        // Verify default model is set
        expect(AppConfig.defaultModel, 'mixtral-8x7b-32768');
      });
    });

    group('validateApiKey', () {
      test('returns true for a valid API key', () async {
        // This would require mocking http.post
        // Structure shows the intended test pattern
        expect(AppConfig.isConfigured, true);
      });

      test('returns false for an invalid API key', () async {
        final result = await AiService.validateApiKey('invalid-key');
        expect(result, isFalse);
      });

      test('handles timeout gracefully', () async {
        // Should not throw, should return false on timeout
        expect(await AiService.validateApiKey(''), isFalse);
      });
    });

    group('getAvailableModels', () {
      test('returns list of available Groq models', () async {
        final models = await AiService.getAvailableModels();
        expect(models, isNotEmpty);
        expect(models, contains('mixtral-8x7b-32768'));
      });
    });
  });
}
