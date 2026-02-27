import 'dart:convert';
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
}
