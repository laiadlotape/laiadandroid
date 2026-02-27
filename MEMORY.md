# MEMORY.md — laiadandroid

## Project Genesis
- Created 2026-02-26 as Android port of laiadlotape/laia
- GitHub: https://github.com/laiadlotape/laiadandroid
- Based on laia commit c3b8e7a (comprehensive model benchmark + fallback chain)

## Architecture Decision
- Phase 1: Flutter APK (fastest path, reuses Groq API integration)
- Phase 2: System app integration (AOSP)
- Phase 3: Custom ROM (LineageOS fork)

## Toolchain Status
- Java 21: ✅ installed
- Flutter: ❌ not installed yet
- Android SDK: ❌ not installed yet
- Emulator: ❌ not set up yet

## Default AI Config
- Groq llama-3.1-8b-instant as primary (best free model, 155ms, 560 tok/sec)
- OpenRouter :free models as fallback
- config/ai/config.yaml updated with fallback chain

## Key Notes
- sudo password: estaes
- Parent laia project: /home/mcflanagan/.openclaw/laia/
- This project dir: /home/mcflanagan/.openclaw/laiadandroid/
