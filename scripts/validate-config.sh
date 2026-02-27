#!/usr/bin/env bash
# Validate LAIA config before build
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

chk() {
  local desc="$1" file="$2"
  [[ -f "$ROOT/$file" ]] && echo "  ✅ $desc" || \
    { echo "  ❌ Missing: $desc ($file)"; ERRORS=$((ERRORS+1)); }
}

echo "Validating LAIA configuration..."
chk "Base packages"        "config/packages/base.list"
chk "Security harden.sh"  "config/security/harden.sh"
chk "OpenClaw config"     "config/openclaw/openclaw-restricted.json"
chk "AI stack installer"  "config/ai/install-ai-stack.sh"
chk "Build script"        "build/build-iso.sh"

[[ $ERRORS -eq 0 ]] || { echo "❌ $ERRORS error(s). Fix before building."; exit 1; }
echo "✅ All checks passed"
