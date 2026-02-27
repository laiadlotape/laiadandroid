#!/bin/bash
set -e

FLUTTER="/home/mcflanagan/.openclaw/flutter/bin/flutter"
export ANDROID_HOME="/home/mcflanagan/.openclaw/android-sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

VERSION=$(grep "version:" pubspec.yaml | head -1 | awk '{print $2}')
echo "🚀 Building LAIA Android v$VERSION for release..."

$FLUTTER build apk --release
$FLUTTER build appbundle

APK="build/app/outputs/flutter-apk/app-release.apk"
AAB="build/app/outputs/bundle/release/app-release.aab"

echo "✅ Release APK: $APK ($(du -sh $APK | cut -f1))"
echo "✅ Release AAB: $AAB ($(du -sh $AAB | cut -f1))"
echo ""
echo "Upload to GitHub Releases:"
echo "  gh release create v$VERSION $APK $AAB --title 'LAIA Android v$VERSION' --notes 'Release build'"
