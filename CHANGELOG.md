# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-alpha] - 2026-02-27

### Added

#### Phase 1-2: Project Scaffolding ✅
- Flutter project setup with Material Design 3
- Basic app structure (main.dart, routes configuration)
- Message data model with TypeScript-like comments
- App configuration system (API URL, model selection, timeouts)
- Settings screen for API key management
- Basic test structure

#### Phase 3: Chat UI Implementation ✅
- Material Design 3 polished message bubbles
- User vs AI message differentiation with different border radiuses
- Auto-scroll to latest message with smooth animation
- Loading indicator with "LAIA is typing..." status text
- Error state display with icons
- Modern input field with rounded borders
- Disabled state during loading
- AppBar with settings navigation

#### Phase 4: Groq API Integration ✅
- Full Groq API service implementation (chat completions)
- API key validation with timeout handling
- Error handling for 401 (invalid key), 429 (rate limit), and other errors
- Support for Mixtral 8x7B, Llama 2 70B, and Gemma 7B models
- Temperature and token configuration
- Configurable request timeout

#### Phase 5: Build Configuration ✅
- Release APK build configuration
- App Bundle (AAB) build support
- Android manifest with internet permissions

#### Phase 6: Emulator Setup (Optional) ⏳
- Integration test framework prepared
- Emulator configuration documented in README

#### Phase 7: Test Suite ✅
- Unit tests for `ai_service.dart` (API calls, error handling, model selection)
- Widget tests for `chat_screen.dart` (UI rendering, input, navigation)
- Integration test framework for E2E testing
- Test coverage structure (target: >70%)

#### Phase 8: CI/CD Pipeline ✅
- GitHub Actions workflow (`.github/workflows/flutter-build.yml`)
- Automated testing on push/PR
- Automated APK and AAB builds
- Artifact storage (30-day retention)
- Code coverage reporting with Codecov
- Linting with `flutter analyze`
- Fallback job for build-only if tests fail

#### Phase 9: Documentation & Release ✅
- Comprehensive README with:
  - Quick start guide
  - API key setup instructions
  - Model information and comparison
  - Configuration guide
  - Build instructions (APK/AAB)
  - Testing guide
  - Troubleshooting section
  - Performance tips
  - Development guidelines
- CHANGELOG.md (this file)
- Improved .gitignore with Flutter/Dart entries
- Code comments and documentation
- Version: 1.0.0-alpha tagged

### Changed

- Chat UI completely redesigned with Material 3
- Message bubbles now use theme colors instead of hardcoded colors
- Input field now uses theme colors and has focus state
- Settings screen uses theme-aware colors

### Fixed

- Auto-scroll now works smoothly with animation
- Loading state properly disables input field
- Error messages are included in test cases
- Settings screen properly validates API key before saving

### Dependencies

- flutter: ^3.6.2
- http: ^1.1.0
- provider: ^6.0.0
- cupertino_icons: ^1.0.8
- mockito: ^4.4.4
- build_runner: ^2.4.0
- flutter_lints: ^5.0.0

---

## Planned Features (v1.1.0+)

- [ ] Chat history persistence (local SQLite)
- [ ] Multiple conversation sessions
- [ ] Message export to PDF/text
- [ ] Voice input (speech-to-text)
- [ ] Voice output (text-to-speech)
- [ ] Dark mode / Light mode toggle
- [ ] Model selection in UI (not just config)
- [ ] Custom system prompts
- [ ] Image generation support
- [ ] iOS app support
- [ ] Web app version
- [ ] Desktop app (Windows/macOS/Linux)

---

## Known Limitations

1. **iOS Support**: Not yet configured. Will be added in v1.1.0
2. **Offline Mode**: No offline functionality - requires internet
3. **Model Selection**: Currently fixed to Mixtral 8x7B, must edit config to change
4. **Chat History**: Not persisted - clears on app restart
5. **Rate Limiting**: Subject to Groq free tier rate limits

---

## Migration Guide

### From v1.0.0-beta to v1.0.0-alpha

No breaking changes. Direct upgrade possible.

---

## Credits

- **[Groq](https://groq.com)** - Fast open-source LLMs
- **[Flutter](https://flutter.dev)** - UI framework
- **[Material Design 3](https://m3.material.io/)** - Design system

---

## Version History

- **v1.0.0-alpha** (2026-02-27): Initial release with Groq API integration
