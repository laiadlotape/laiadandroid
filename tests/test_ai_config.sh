#!/usr/bin/env bash
# LAIA AI Config Tests — Improved with graceful degradation
set -euo pipefail

LAIA_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
WARNINGS=0

test_file() {
  local file="$1"
  local description="$2"
  if [[ -f "$file" ]]; then
    echo "✅ $description"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo "❌ Missing: $description ($file)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

test_executable() {
  local file="$1"
  local description="$2"
  if [[ -x "$file" ]]; then
    echo "✅ $description (executable)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo "❌ Not executable: $description"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

validate_yaml() {
  local file="$1"
  local description="$2"
  if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
    echo "✅ Valid YAML: $description"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo "❌ Invalid YAML: $description ($file)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

validate_bash() {
  local file="$1"
  local description="$2"
  if bash -n "$file" 2>/dev/null; then
    echo "✅ Valid shell syntax: $description"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    echo "❌ Syntax error: $description"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

echo "═══════════════════════════════════════════════════════════"
echo "LAIA AI Config Tests (graceful mode, no key required)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Required files
echo "Checking configuration files..."
test_file "$LAIA_ROOT/config/ai/providers.yaml" "config/ai/providers.yaml"
test_file "$LAIA_ROOT/config/ai/config.yaml" "config/ai/config.yaml"
test_file "$LAIA_ROOT/config/ai/models.yaml" "config/ai/models.yaml"
echo ""

echo "Checking scripts..."
test_file "$LAIA_ROOT/scripts/setup-ai-provider.sh" "scripts/setup-ai-provider.sh"
test_file "$LAIA_ROOT/scripts/test-connection.sh" "scripts/test-connection.sh"
test_file "$LAIA_ROOT/scripts/benchmark-models.sh" "scripts/benchmark-models.sh"
test_executable "$LAIA_ROOT/scripts/setup-ai-provider.sh" "setup-ai-provider.sh"
test_executable "$LAIA_ROOT/scripts/test-connection.sh" "test-connection.sh"
test_executable "$LAIA_ROOT/scripts/benchmark-models.sh" "benchmark-models.sh"
echo ""

echo "Validating YAML syntax..."
validate_yaml "$LAIA_ROOT/config/ai/providers.yaml" "providers.yaml"
validate_yaml "$LAIA_ROOT/config/ai/config.yaml" "config.yaml"
validate_yaml "$LAIA_ROOT/config/ai/models.yaml" "models.yaml"
echo ""

echo "Validating shell script syntax..."
validate_bash "$LAIA_ROOT/scripts/setup-ai-provider.sh" "setup-ai-provider.sh"
validate_bash "$LAIA_ROOT/scripts/test-connection.sh" "test-connection.sh"
validate_bash "$LAIA_ROOT/scripts/benchmark-models.sh" "benchmark-models.sh"
echo ""

echo "Checking providers.yaml structure..."
for provider in groq openrouter huggingface mistral google; do
  if grep -q "^  $provider:" "$LAIA_ROOT/config/ai/providers.yaml"; then
    echo "✅ Provider configured: $provider"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ Missing provider: $provider"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
done
echo ""

echo "Checking API keys (optional)..."
if [[ -f "${HOME}/.laia/api_keys.env" ]]; then
  echo "✅ API keys file found"
  TESTS_PASSED=$((TESTS_PASSED + 1))
else
  echo "⚠️  No API keys configured (run: laia-setup-wizard)"
  WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo "═══════════════════════════════════════════════════════════"
if [[ $TESTS_FAILED -eq 0 ]]; then
  if [[ $WARNINGS -gt 0 ]]; then
    echo "✅ Config tests passed ($TESTS_PASSED passed, $WARNINGS warning)"
    echo "   Recommendations:"
    echo "   • Run: laia-setup-wizard"
    echo "   • Or use local Ollama for offline mode"
  else
    echo "✅ All AI config tests passed ($TESTS_PASSED tests)"
  fi
  exit 0
else
  echo "❌ Config tests failed ($TESTS_FAILED failed, $TESTS_PASSED passed)"
  exit 1
fi
