# LAIA Chat - Flutter Android App

A lightweight, fast AI chat application powered by [Groq's API](https://groq.com), built with Flutter.

**Features:**
- ✨ Clean Material Design UI
- 🚀 Blazing fast responses via Groq API
- 💬 Real-time chat messaging
- ⚙️ Easy API key configuration
- 🔒 Secure (free tier, no credit card required)
- 📱 Works on Android 5.0+

## Quick Start

### Prerequisites

- **Flutter SDK** 3.6.2 or higher
- **Android SDK** (API 21+)
- **Groq API Key** (free - get it at [console.groq.com](https://console.groq.com))

### 1. Get a Groq API Key

1. Visit [console.groq.com](https://console.groq.com)
2. Sign up (no credit card needed)
3. Create an API key
4. Copy your API key

### 2. Clone & Setup

```bash
git clone https://github.com/laiadlotape/laiadandroid.git
cd laiadandroid
flutter pub get
```

### 3. Run the App

```bash
# On emulator
flutter run

# On physical device
flutter run
```

### 4. Configure API Key

1. Open the app
2. Tap **Settings** (⚙️)
3. Paste your Groq API key
4. Tap **Validate API Key**
5. Tap **Save API Key**

### 5. Start Chatting!

Tap the message input field and start talking to LAIA.

---

## Available AI Models

The app includes access to these Groq-hosted models (free tier):

| Model | Size | Speed | Best For |
|-------|------|-------|----------|
| **Mixtral 8x7B** | 8x7B MoE | ⚡⚡⚡ Very Fast | General chat, coding, creative tasks |
| **Llama 2 70B** | 70B | ⚡⚡ Fast | Complex reasoning, detailed answers |
| **Gemma 7B** | 7B | ⚡⚡⚡ Fastest | Quick responses, efficient |

**Model is fixed to Mixtral 8x7B in this version.** To change models, edit `lib/config/app_config.dart`:

```dart
static const String defaultModel = 'mixtral-8x7b-32768';  // Change this line
```

Rebuild with `flutter run`.

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── chat_screen.dart     # Main chat UI
│   └── settings_screen.dart # API key configuration
├── services/
│   └── ai_service.dart      # Groq API integration
├── models/
│   └── message.dart         # Message data model
└── config/
    └── app_config.dart      # App configuration & constants
    
test/
├── services/
│   └── ai_service_test.dart # Unit tests for AI service
├── screens/
│   └── chat_screen_test.dart # Widget tests for chat UI
└── widget_test.dart         # Basic widget test

android/                      # Android-specific configuration
ios/                         # iOS configuration (not configured)
```

---

## Configuration

### API Configuration (`lib/config/app_config.dart`)

```dart
class AppConfig {
  static const String groqApiUrl = 'https://api.groq.com/openai/v1';
  static const String defaultModel = 'mixtral-8x7b-32768';
  static const int maxTokens = 1024;        // Max response length
  static const double temperature = 0.7;    // Creativity (0.0-2.0)
  static const int requestTimeoutSeconds = 30;
}
```

**Tweak these to customize behavior:**
- **maxTokens**: Increase for longer responses (uses more API quota)
- **temperature**: Lower (0.0) = more focused, Higher (2.0) = more creative
- **requestTimeoutSeconds**: Increase if you have slow internet

---

## Building for Release

### APK (Android)

```bash
# Generate release APK
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
# File size: ~50-70 MB
```

### AAB (Google Play)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/services/ai_service_test.dart
flutter test test/screens/chat_screen_test.dart
```

### Generate Coverage Report

```bash
flutter test --coverage
# Report: coverage/lcov.info
```

---

## Troubleshooting

### "API key not configured"

**Problem:** App says "Please configure your Groq API key in settings"

**Solution:**
1. Open Settings (⚙️)
2. Paste your API key from [console.groq.com](https://console.groq.com)
3. Tap "Validate API Key" - wait for ✓
4. Tap "Save API Key"

### "Invalid API key"

**Problem:** Validation fails with "Invalid API key"

**Solution:**
1. Double-check your key is copied completely (no extra spaces)
2. Verify the key is from [console.groq.com](https://console.groq.com), not another service
3. Try generating a new key in Groq Console
4. Check your internet connection

### "Rate limit exceeded"

**Problem:** "Rate limit exceeded. Please wait and try again."

**Solution:**
- Groq free tier has rate limits. Wait a few seconds and retry.
- Premium tier available at [console.groq.com](https://console.groq.com)

### "Network timeout"

**Problem:** "API request timeout"

**Solution:**
1. Check your internet connection
2. Increase timeout in `lib/config/app_config.dart`:
   ```dart
   static const int requestTimeoutSeconds = 60; // increased from 30
   ```
3. Rebuild: `flutter run`

### App crashes on startup

**Problem:** App won't start or crashes immediately

**Solution:**
```bash
# Clean build
flutter clean
flutter pub get
flutter run

# If still broken, check logs:
flutter run -v
```

### Emulator connection issues

**Problem:** "Device not found" when running `flutter run`

**Solution:**
```bash
# List available devices
flutter devices

# Start emulator if not running
emulator -avd <emulator_name>

# Then run
flutter run
```

---

## Development

### Code Style

This project follows:
- [Effective Dart](https://dart.dev/guides/language/effective-dart) conventions
- Flutter [Analysis Options](analysis_options.yaml)

Run linter:
```bash
flutter analyze
```

### Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## CI/CD

This project includes GitHub Actions workflows:

- **Flutter Build**: Runs on every push to master
  - Analyzes code
  - Runs tests
  - Builds APK
  - Stores APK as artifact

View in `.github/workflows/flutter-build.yml`

---

## Performance Tips

1. **Use Mixtral 8x7B** (default) for best speed/quality balance
2. **Lower maxTokens** for faster responses:
   ```dart
   static const int maxTokens = 512; // instead of 1024
   ```
3. **Keep temperature around 0.7** for balanced responses
4. **Use Wi-Fi** instead of cellular for better performance

---

## Privacy & Security

- 🔒 **Your API key** is stored locally in the app's secure storage
- 🌐 **Messages** are sent to Groq's servers (check [Groq Privacy Policy](https://groq.com/privacy))
- ✅ **No tracking** - this app has no analytics or telemetry
- 📱 **Android only** - iOS support can be added

---

## License

MIT License - See `LICENSE` file

---

## Support

**Issues?** Check the [Troubleshooting](#troubleshooting) section above.

**Groq API Issues?** Contact [Groq Support](https://groq.com/support)

**Found a bug?** Open an issue on [GitHub](https://github.com/laiadlotape/laiadandroid/issues)

---

## What's Next?

Potential improvements:
- [ ] Message persistence (save chat history)
- [ ] Multiple chat sessions
- [ ] Image generation
- [ ] Voice input/output
- [ ] Dark mode
- [ ] Model selection in UI
- [ ] Conversation export
- [ ] iOS support

---

## Credits

- **[Groq](https://groq.com)** - Fast, open-source LLMs
- **[Flutter](https://flutter.dev)** - Beautiful native apps
- **[Material Design 3](https://m3.material.io/)** - Design system

---

**Made with ❤️ by [@laiadlotape](https://github.com/laiadlotape)**

Last updated: 2026-02-27
