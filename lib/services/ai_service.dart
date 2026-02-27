/// AI Service for communicating with Groq API
/// Handles chat completions and message streaming

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/message.dart';

class AiService {
  /// Make a chat request to Groq API
  /// Returns a Message with the AI response
  static Future<Message> chatCompletion({
    required List<Map<String, String>> messages,
    String? model,
  }) async {
    if (!AppConfig.isConfigured) {
      throw Exception('Groq API key not configured. Please set it in settings.');
    }

    final String apiKey = AppConfig.groqApiKey!;
    final String apiModel = model ?? AppConfig.defaultModel;
    
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.groqApiUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': apiModel,
          'messages': messages,
          'temperature': AppConfig.temperature,
          'max_tokens': AppConfig.maxTokens,
        }),
      ).timeout(
        Duration(seconds: AppConfig.requestTimeoutSeconds),
        onTimeout: () => throw Exception('API request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          role: 'assistant',
          timestamp: DateTime.now(),
        );
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your Groq API key.');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please wait and try again.');
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception('API Error: ${error['message'] ?? 'Unknown error'}');
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

  /// Validate API key by making a simple test request
  /// Returns true if key is valid, false otherwise
  static Future<bool> validateApiKey(String apiKey) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.groqApiUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': AppConfig.defaultModel,
          'messages': [
            {'role': 'user', 'content': 'Hi'},
          ],
          'max_tokens': 1,
        }),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available models
  /// Note: This would require an endpoint from Groq API
  static Future<List<String>> getAvailableModels() async {
    // For now, return known Groq models
    return [
      'mixtral-8x7b-32768',
      'llama2-70b-4096',
      'gemma-7b-it',
    ];
  }
}
