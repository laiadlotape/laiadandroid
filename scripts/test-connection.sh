#!/usr/bin/env bash
# LAIA — Test AI connection
set -euo pipefail

KEYS_FILE="${HOME}/.laia/api_keys.env"

if [[ ! -f "${KEYS_FILE}" ]]; then
  echo "❌ No LAIA configuration found. Run: laia-setup or laia-config"
  exit 1
fi

source "${KEYS_FILE}"

MODE="${LAIA_MODE:-online}"
echo "Testing LAIA AI connection (mode: ${MODE})..."

case "${MODE}" in
  online)
    curl -sf \
      -H "Authorization: Bearer ${!${LAIA_PROVIDER^^}_API_KEY:-${GROQ_API_KEY:-}}" \
      -H "Content-Type: application/json" \
      -d "{\"model\":\"${LAIA_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Reply with only: LAIA OK\"}],\"max_tokens\":10}" \
      "${LAIA_API_BASE}/chat/completions" \
    | python3 -c "import json,sys; print('✅', json.load(sys.stdin)['choices'][0]['message']['content'])"
    ;;
  local)
    curl -sf "http://127.0.0.1:11434/api/tags" > /dev/null && echo "✅ Local Ollama running"
    ;;
  lan)
    curl -sf "http://${LAIA_LAN_HOST}:${LAIA_LAN_PORT:-11434}/api/tags" > /dev/null \
      && echo "✅ LAN Ollama at ${LAIA_LAN_HOST} reachable"
    ;;
esac
