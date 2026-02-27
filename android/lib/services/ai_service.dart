import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../config/app_config.dart';

class AIService {
  final String apiKey;
  final String provider;
  final String model;

  AIService({
    required this.apiKey,
    this.provider = AppConfig.defaultProvider,
    this.model = AppConfig.defaultModel,
  });

  String get apiBase => provider == 'groq'
      ? AppConfig.groqApiBase
      : AppConfig.openrouterApiBase;

  Future<String> chat(List<Message> messages) async {
    final response = await http
        .post(
          Uri.parse('$apiBase/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            if (provider == 'openrouter')
              'HTTP-Referer': 'https://github.com/laiadlotape/laiadandroid',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages.map((m) => m.toJson()).toList(),
            'max_tokens': 1024,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content']
          as String;
    } else if (response.statusCode == 401) {
      throw Exception('API key inválida. Ve a Ajustes para configurarla.');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Stream<String> chatStream(List<Message> messages) async* {
    final request = http.Request(
      'POST',
      Uri.parse('$apiBase/chat/completions'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      if (provider == 'openrouter')
        'HTTP-Referer': 'https://github.com/laiadlotape/laiadandroid',
    });
    request.body = jsonEncode({
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'max_tokens': 2048,
      'stream': true,
    });

    final client = http.Client();
    try {
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }

      await for (final chunk in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (chunk.startsWith('data: ')) {
          final data = chunk.substring(6);
          if (data == '[DONE]') break;
          try {
            final json = jsonDecode(data);
            final delta = json['choices'][0]['delta']['content'];
            if (delta != null) {
              yield delta as String;
            }
          } catch (_) {
            // Ignore parse errors
          }
        }
      }
    } catch (e) {
      throw Exception('Streaming error: $e');
    } finally {
      client.close();
    }
  }
}
