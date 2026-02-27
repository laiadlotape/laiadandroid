#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
FLUTTER="/home/mcflanagan/.openclaw/flutter/bin/flutter"
ANDROID_SDK="/home/mcflanagan/.openclaw/android-sdk"

export ANDROID_HOME="$ANDROID_SDK"
export PATH="$PATH:$ANDROID_SDK/cmdline-tools/latest/bin:$ANDROID_SDK/platform-tools:$ANDROID_SDK/build-tools/35.0.1"

echo "🔧 Building LAIA Android APK..."
cd "$PROJECT_ROOT/android"

echo "📦 Getting dependencies..."
$FLUTTER pub get

echo "🏗️  Building debug APK..."
$FLUTTER build apk --debug

APK="$PROJECT_ROOT/android/build/app/outputs/flutter-apk/app-debug.apk"
if [ -f "$APK" ]; then
  SIZE=$(du -sh "$APK" | cut -f1)
  echo "✅ APK built: $APK ($SIZE)"
  cp "$APK" "$PROJECT_ROOT/laia-android-debug.apk"
  echo "📱 Copied to: $PROJECT_ROOT/laia-android-debug.apk"
else
  echo "❌ APK not found"
  exit 1
fi
