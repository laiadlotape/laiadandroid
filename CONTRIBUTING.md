# Contributing to LAIA Chat

Thank you for your interest in contributing! This document provides guidelines and instructions.

## Code of Conduct

- Be respectful and inclusive
- No harassment, discrimination, or offensive language
- Focus on improving the project

## Getting Started

### 1. Fork & Clone

```bash
git clone https://github.com/YOUR_USERNAME/laiadandroid.git
cd laiadandroid
```

### 2. Setup Development Environment

```bash
flutter pub get
flutter doctor  # Check dependencies
```

### 3. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

Use descriptive branch names:
- `feature/chat-history` - New feature
- `fix/crash-on-empty-message` - Bug fix
- `docs/readme-update` - Documentation
- `test/add-unit-tests` - Tests

## Development Guidelines

### Code Style

This project follows [Effective Dart](https://dart.dev/guides/language/effective-dart).

**Quick rules:**
- Use `const` for constants
- Avoid abbreviations (not `msg`, use `message`)
- Use meaningful variable names
- Max line length: 120 characters
- Add documentation comments to public APIs

### Linting

```bash
# Check code quality
flutter analyze

# Fix issues automatically
dart fix --apply
```

### Testing

**All new features must include tests.**

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/services/ai_service_test.dart

# Generate coverage
flutter test --coverage
```

**Test guidelines:**
- Unit test: Test single functions/classes
- Widget test: Test UI components
- Integration test: Test full app flows
- Aim for >70% code coverage

### Documentation

- Add comments to all public methods
- Update README.md for user-facing changes
- Update CHANGELOG.md with your changes
- Add examples for new features

## Submitting Changes

### 1. Commit Messages

Write clear, descriptive commit messages:

```
feat: Add message persistence with SQLite

- Implement MessageDB service
- Add migration system
- Update chat_screen to load history
- Add tests for persistence

Closes #123
```

**Format:** `<type>: <subject>`

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `test`: Tests
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `chore`: Build, deps, etc.

### 2. Push & Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then open a PR on GitHub with:
- Clear title and description
- Link to related issues: `Closes #123`
- Screenshots/videos if UI changes
- Test results

### 3. Code Review

- Address reviewer feedback
- Keep PRs focused (one feature per PR)
- Respond to comments within 48 hours
- Rebase before merging if needed

## PR Checklist

Before submitting:

- [ ] Code follows style guide (`flutter analyze` passes)
- [ ] Tests written and passing (`flutter test` passes)
- [ ] README.md updated (if needed)
- [ ] CHANGELOG.md updated
- [ ] No unnecessary comments or debug code
- [ ] Branch rebased with main (no merge commits)
- [ ] Commit messages are clear

## What to Work On

### Good First Issues

Check the [Issues](https://github.com/laiadlotape/laiadandroid/issues) page for:
- Issues labeled `good-first-issue`
- Issues labeled `help-wanted`

### Priority Features

Currently seeking contributions for:

1. **Chat History Persistence** - Save messages locally
2. **Voice Input/Output** - Speech-to-text and TTS
3. **Image Generation** - Groq image API integration
4. **Dark Mode** - Theme support
5. **iOS Support** - Complete iOS build configuration
6. **Performance** - Optimize message rendering
7. **Accessibility** - WCAG 2.1 AA compliance

## Project Structure

```
lib/
├── main.dart           # App entry point
├── screens/           # UI screens
├── services/          # Business logic (API, DB, etc.)
├── models/            # Data models
├── config/            # Configuration
└── widgets/           # Reusable components (add as needed)

test/
├── unit/              # Unit tests
├── widget/            # Widget tests
└── integration/       # E2E tests

.github/
└── workflows/         # CI/CD pipelines
```

## Common Tasks

### Adding a New Screen

1. Create `lib/screens/my_screen.dart`
2. Add route to `main.dart`
3. Create tests in `test/screens/my_screen_test.dart`
4. Update README with navigation info

### Adding a Service

1. Create `lib/services/my_service.dart`
2. Add unit tests in `test/services/my_service_test.dart`
3. Document public methods
4. Update README if user-facing

### Adding Dependencies

```bash
# Development dependency
flutter pub add --dev mockito

# Production dependency
flutter pub add http
```

Then:
1. Update pubspec.yaml version if breaking
2. Document new dependency in README
3. Test with `flutter pub get && flutter test`

## Testing API Locally

### Without Groq API Key

```dart
// In tests, mock the API response
expect(AppConfig.isConfigured, true);
```

### With Real Groq API Key

1. Get key from [console.groq.com](https://console.groq.com)
2. Set in settings or environment: `GROQ_API_KEY=gsk_...`
3. Run app and test manually

## Getting Help

- **Documentation**: Check README.md and code comments
- **Issues**: Open an issue with detailed description
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact maintainer if needed

## Code Review Feedback

Common feedback you might receive:

- **"Add tests"** - Write unit/widget tests for your code
- **"Add docs"** - Add documentation comments
- **"Simplify"** - Reduce complexity or lines of code
- **"Performance"** - Optimize loops, queries, rebuilds
- **"Consistency"** - Match existing code style

**Responding to feedback:**
1. Thank the reviewer
2. Ask for clarification if unclear
3. Make changes and push again
4. Mark conversations as resolved

## Merging

Once approved:
- Maintainer will merge the PR
- Your branch will be deleted
- Changes appear in next release

## Release Process

When ready for a release:

1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Create git tag: `git tag v1.0.0`
4. Push: `git push origin v1.0.0`
5. Create GitHub Release with notes

## Questions?

Open an issue or discussion on GitHub, or contact the maintainer.

---

**Thank you for contributing! 🎉**
