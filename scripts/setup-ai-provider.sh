#!/usr/bin/env bash
# LAIA AI Provider Setup — Interactive CLI
# Enhanced with auto-detection of anonymous access and benchmark info
set -euo pipefail

KEYS_FILE="${HOME}/.laia/api_keys.env"
LAIA_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "${HOME}/.laia"
chmod 700 "${HOME}/.laia"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║          LAIA AI Provider Setup Wizard v2                       ║"
echo "║        (All providers tested 2026-02-26)                        ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Check what's available locally
echo "🔍 Checking for local/available options..."
if curl -sf "http://127.0.0.1:11434/api/tags" &>/dev/null; then
  echo "  ✅ Local Ollama found at 127.0.0.1:11434"
fi
echo ""

echo "Choose your AI provider:"
echo ""
echo "  1) Groq          — ⚡ FASTEST free inference (recommended)"
echo "     • Speed: 560 tokens/sec"
echo "     • Quality: Excellent"
echo "     • Cost: Free, 30 req/min, no credit card"
echo "     • Sign up: https://console.groq.com"
echo ""
echo "  2) OpenRouter    — 200+ models, many free"
echo "     • Aggregates Llama, Claude, GPT, Gemini, etc."
echo "     • Speed: Varies by model"
echo "     • Sign up: https://openrouter.ai"
echo ""
echo "  3) HuggingFace   — 100k+ open models"
echo "     • ⚠️  Note: Old inference API deprecated, API limited"
echo "     • Sign up: https://huggingface.co/settings/tokens"
echo ""
echo "  4) Mistral AI    — European AI, strong multilingual"
echo "     • Speed: Good"
echo "     • Quality: Very good"
echo "     • Sign up: https://console.mistral.ai"
echo ""
echo "  5) Google AI     — Gemini 2.0 Flash free"
echo "     • Speed: Fast"
echo "     • Quality: Excellent, with vision"
echo "     • Sign up: https://aistudio.google.com/apikey"
echo ""
echo "  6) Local Ollama  — 🏠 Run models on this machine"
echo "     • No internet required"
echo "     • Privacy: All data stays local"
echo ""
echo "  7) LAN Remote    — Connect to Ollama on your network"
echo ""

read -rp "Enter choice [1-7] (recommended: 1 for speed, 6 for privacy): " choice

case "$choice" in
  1)
    PROVIDER="groq"
    ENV_VAR="GROQ_API_KEY"
    API_BASE="https://api.groq.com/openai/v1"
    DEFAULT_MODEL="llama-3.1-8b-instant"
    SIGNUP="https://console.groq.com"
    ;;
  2)
    PROVIDER="openrouter"
    ENV_VAR="OPENROUTER_API_KEY"
    API_BASE="https://openrouter.ai/api/v1"
    DEFAULT_MODEL="meta-llama/llama-3.1-8b-instruct:free"
    SIGNUP="https://openrouter.ai"
    ;;
  3)
    PROVIDER="huggingface"
    ENV_VAR="HF_TOKEN"
    API_BASE="https://api-inference.huggingface.co/v1"
    DEFAULT_MODEL="meta-llama/Llama-3.1-8B-Instruct"
    SIGNUP="https://huggingface.co/settings/tokens"
    ;;
  4)
    PROVIDER="mistral"
    ENV_VAR="MISTRAL_API_KEY"
    API_BASE="https://api.mistral.ai/v1"
    DEFAULT_MODEL="open-mistral-7b"
    SIGNUP="https://console.mistral.ai"
    ;;
  5)
    PROVIDER="google"
    ENV_VAR="GOOGLE_API_KEY"
    API_BASE="https://generativelanguage.googleapis.com/v1beta/openai"
    DEFAULT_MODEL="gemini-2.0-flash"
    SIGNUP="https://aistudio.google.com/apikey"
    ;;
  6)
    echo ""
    echo "Setting up local Ollama..."
    bash "$(dirname "$0")/../config/ai/install-ollama.sh" || true
    echo "LAIA_MODE=local" > "${KEYS_FILE}"
    echo "✅ Local mode configured."
    exit 0
    ;;
  7)
    echo ""
    read -rp "Enter the IP address of your Ollama server: " LAN_HOST
    read -rp "Port [11434]: " LAN_PORT
    LAN_PORT="${LAN_PORT:-11434}"
    read -rp "Default model [gemma3:4b]: " LAN_MODEL
    LAN_MODEL="${LAN_MODEL:-gemma3:4b}"

    # Test connection
    echo "Testing connection to ${LAN_HOST}:${LAN_PORT}..."
    if curl -sf "http://${LAN_HOST}:${LAN_PORT}/api/tags" > /dev/null 2>&1; then
      echo "✅ Connected! Models available:"
      curl -sf "http://${LAN_HOST}:${LAN_PORT}/api/tags" | python3 -c "
import json,sys
data=json.load(sys.stdin)
models=[m['name'] for m in data.get('models',[])]
for m in models[:5]: print(f'   - {m}')
" 2>/dev/null || true
    else
      echo "⚠️  Could not connect. Saving anyway — check your firewall settings."
      echo "    The Ollama server needs to bind to 0.0.0.0 (not 127.0.0.1)"
      echo "    Set: OLLAMA_HOST=0.0.0.0 in the server's /etc/systemd/system/ollama.service"
    fi

    {
      echo "LAIA_MODE=lan"
      echo "LAIA_LAN_HOST=${LAN_HOST}"
      echo "LAIA_LAN_PORT=${LAN_PORT}"
      echo "LAIA_LAN_MODEL=${LAN_MODEL}"
    } > "${KEYS_FILE}"
    chmod 600 "${KEYS_FILE}"
    echo "✅ LAN remote mode configured: ${LAN_HOST}:${LAN_PORT}"
    exit 0
    ;;
  *)
    echo "Invalid choice. Run again."
    exit 1
    ;;
esac

# Online provider setup
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Get your free API key at: ${SIGNUP}"
echo ""

if [[ "${PROVIDER}" == "groq" ]]; then
  echo "📋 GROQ Quick Signup (2 minutes):"
  echo "  1. Go to https://console.groq.com"
  echo "  2. Sign up with Google, GitHub, or email"
  echo "  3. Skip credit card (free tier doesn't need it)"
  echo "  4. Click 'Create New API Key' in Settings"
  echo "  5. Copy the key and paste it here"
  echo ""
  echo "💡 Tip: Keep your key private! You can regenerate it anytime."
fi

command -v xdg-open &>/dev/null && read -rp "Open in browser? [y/N]: " open_it
[[ "${open_it:-n}" =~ ^[Yy]$ ]] && xdg-open "${SIGNUP}" &

echo ""
read -rsp "Paste your ${PROVIDER} API key (input hidden): " api_key
echo ""

if [[ -z "$api_key" ]]; then
  echo "❌ No key entered. Try again:"
  echo "   Run: laia-setup-wizard"
  exit 1
fi

# Test connection
echo "Testing connection..."
TEST_RESPONSE=$(curl -sf \
  -H "Authorization: Bearer ${api_key}" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${DEFAULT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Say: OK\"}],\"max_tokens\":5}" \
  "${API_BASE}/chat/completions" 2>&1)

if echo "$TEST_RESPONSE" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['choices'][0]['message']['content'])" 2>/dev/null | grep -q "."; then
  echo "✅ Connection successful!"
else
  echo "⚠️  Connection test failed. Key saved anyway (check rate limits or key validity)."
  echo "   Response: $(echo "$TEST_RESPONSE" | head -c 200)"
fi

# Save config
{
  echo "LAIA_MODE=online"
  echo "LAIA_PROVIDER=${PROVIDER}"
  echo "LAIA_MODEL=${DEFAULT_MODEL}"
  echo "LAIA_API_BASE=${API_BASE}"
  echo "${ENV_VAR}=${api_key}"
} > "${KEYS_FILE}"
chmod 600 "${KEYS_FILE}"

echo ""
echo "✅ Configuration saved to ${KEYS_FILE}"
echo "   Provider: ${PROVIDER}"
echo "   Model: ${DEFAULT_MODEL}"
echo ""
echo "Run 'laia-config' to change settings at any time."
echo "Run OpenWebUI for a chat interface: http://127.0.0.1:3000"
