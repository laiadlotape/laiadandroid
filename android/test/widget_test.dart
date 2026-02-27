import 'package:flutter_test/flutter_test.dart';
import 'package:laia_android/config/app_config.dart';
import 'package:laia_android/models/message.dart';

void main() {
  group('AppConfig', () {
    test('default provider is groq',
        () => expect(AppConfig.defaultProvider, 'groq'));
    test('default model is llama-3.1-8b-instant',
        () => expect(AppConfig.defaultModel, 'llama-3.1-8b-instant'));
  });
  group('Message', () {
    test('toJson has role and content', () {
      final m = Message(
        id: '1',
        content: 'test',
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );
      expect(m.toJson()['role'], 'user');
      expect(m.toJson()['content'], 'test');
    });
  });
}
