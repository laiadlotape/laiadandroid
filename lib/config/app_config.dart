/// Application configuration file for LAIA Chat
/// Contains API keys and constants

class AppConfig {
  /// Groq API endpoint
  static const String groqApiUrl = 'https://api.groq.com/openai/v1';
  
  /// Default model to use with Groq API
  static const String defaultModel = 'mixtral-8x7b-32768';
  
  /// API key for Groq (stored in settings)
  /// Note: This is retrieved from user settings at runtime
  static String? groqApiKey;
  
  /// Maximum tokens for a single response
  static const int maxTokens = 1024;
  
  /// Temperature for model responses (0.0 - 2.0)
  static const double temperature = 0.7;
  
  /// Timeout for API requests in seconds
  static const int requestTimeoutSeconds = 30;
  
  /// Initialize config with API key
  static void setGroqApiKey(String key) {
    groqApiKey = key;
  }
  
  /// Check if API key is configured
  static bool get isConfigured => groqApiKey != null && groqApiKey!.isNotEmpty;
}
