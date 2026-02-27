class AppConfig {
  static const String defaultProvider = 'groq';
  static const String defaultModel = 'llama-3.1-8b-instant';
  static const String groqApiBase = 'https://api.groq.com/openai/v1';
  static const String openrouterApiBase = 'https://openrouter.ai/api/v1';
  static const String fallbackModel = 'meta-llama/llama-3.1-8b-instruct:free';
  static const String apiKeyPref = 'laia_api_key';
  static const String providerPref = 'laia_provider';
  static const String modelPref = 'laia_model';
  static const String appVersion = '0.1.0-alpha';
}
