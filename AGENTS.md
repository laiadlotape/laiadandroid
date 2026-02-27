# AGENTS.md — laiadandroid workspace

This is the Android branch of LAIA. Project goal: get LAIA running on Android phones.

## Project Structure
- **Repo**: https://github.com/laiadlotape/laiadandroid
- **Local path**: /home/mcflanagan/.openclaw/laiadandroid/
- **Parent project**: laiadlotape/laia (Linux distro, online-first AI)
- **Android project dir**: /home/mcflanagan/.openclaw/laiadandroid/android/

## Architecture

### Phase 1 (current): Android App
- Flutter app connecting to Groq/OpenRouter from phone
- No dependency on local PC
- APK buildable and testable in emulator

### Phase 2 (future): System App
- LAIA as a privileged system app in AOSP
- Accessible from any Android launcher

### Phase 3 (future): Custom ROM
- LineageOS fork with LAIA baked in
- Boot-to-LAIA option

## Every Session

1. Pull latest from origin/main
2. Check build status: `cd android && flutter build apk --debug 2>&1 | tail -5`
3. Check emulator: `flutter emulators`
4. Read `memory/YYYY-MM-DD.md` for recent context

## Key Commands

```bash
# Setup
cd /home/mcflanagan/.openclaw/laiadandroid/android
flutter pub get
flutter analyze

# Build
flutter build apk --debug

# Run in emulator
flutter emulators --launch <emulator_id>
flutter run

# Test
flutter test
```

## AI Config (LAIA default models)
Configured in `config/ai/config.yaml`:
- Primary: Groq `llama-3.1-8b-instant` (free, 560 tok/sec)
- Fallback: OpenRouter `meta-llama/llama-3.1-8b-instruct:free`
- Local: Ollama `gemma3:4b` (when device has enough RAM)

## Git Workflow
- `main` branch = always working
- Feature branches: `feature/emulator-setup`, `feature/chat-ui`, etc.
- Commit format: `feat:`, `fix:`, `docs:`, `test:`, `chore:`
- Push to origin after every working state
