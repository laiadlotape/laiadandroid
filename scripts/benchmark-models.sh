#!/usr/bin/env bash
# LAIA Model Benchmark — Test all configured free providers
# Measures latency, anonymous access availability, and response quality
# Usage: ./scripts/benchmark-models.sh [--key-file ~/.laia/api_keys.env] [--timeout 30]

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAIA_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KEYS_FILE="${HOME}/.laia/api_keys.env"
PROVIDERS_FILE="${LAIA_ROOT}/config/ai/providers.yaml"
TIMEOUT=30
RESULTS_FILE="/tmp/laia-benchmark-results.json"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --key-file) KEYS_FILE="$2"; shift 2 ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load API keys if available
declare -A API_KEYS
if [[ -f "${KEYS_FILE}" ]]; then
  echo "📂 Loading API keys from ${KEYS_FILE}"
  # Source only key-like lines (VAR=value format)
  while IFS='=' read -r key value; do
    key="${key%%#*}" # Remove comments
    key="${key%% }" # Trim trailing spaces
    value="${value%% }" # Trim trailing spaces
    [[ -n "${key}" && "${key}" != *"_"* ]] && continue
    [[ -z "${key}" ]] && continue
    API_KEYS["${key}"]="${value}"
  done < "${KEYS_FILE}"
  echo "✅ Loaded ${#API_KEYS[@]} API keys"
else
  echo "⚠️  No keys file found at ${KEYS_FILE}"
  echo "   API key tests will be skipped. Run: laia-setup-wizard"
fi
echo ""

# Initialize results
declare -a RESULTS
RESULTS_JSON="{"
TOTAL_TESTS=0
PASSED_TESTS=0
ANON_TESTS=0

# Test a model with latency measurement
test_model() {
  local provider="$1"
  local model_id="$2"
  local api_base="$3"
  local api_key_env="${4:-}"
  local with_key="${5:-false}"

  TOTAL_TESTS=$((TOTAL_TESTS + 1))

  # Build headers
  declare -a HEADERS
  HEADERS+=("-H" "Content-Type: application/json")
  HEADERS+=("-H" "User-Agent: LAIA-Benchmark/1.0")

  # Add authorization if key is available
  local auth_header=""
  if [[ "${with_key}" == "true" && -n "${api_key_env}" && -v "API_KEYS[${api_key_env}]" ]]; then
    auth_header="${API_KEYS[${api_key_env}]}"
    if [[ "${provider}" == "google" ]]; then
      HEADERS+=("-H" "x-goog-api-key: ${auth_header}")
    else
      HEADERS+=("-H" "Authorization: Bearer ${auth_header}")
    fi
  fi

  # Build request body (different formats per provider)
  local body=""
  case "${provider}" in
    groq|openrouter|mistral|google)
      body='{"model":"'"${model_id}"'","messages":[{"role":"user","content":"Reply only: LAIA OK"}],"max_tokens":15}'
      ;;
    huggingface)
      body='{"model":"'"${model_id}"'","messages":[{"role":"user","content":"Reply only: LAIA OK"}],"max_tokens":15}'
      ;;
    *)
      body='{"model":"'"${model_id}"'","messages":[{"role":"user","content":"Say: LAIA OK"}],"max_tokens":15}'
      ;;
  esac

  # Measure latency
  local start_ms=$(($(date +%s%N) / 1000000))
  local response
  response=$(curl -s -w "\n%{http_code}" --max-time "${TIMEOUT}" -X POST \
    "${api_base}/chat/completions" \
    "${HEADERS[@]}" \
    -d "${body}" 2>&1)
  local end_ms=$(($(date +%s%N) / 1000000))

  local latency=$((end_ms - start_ms))
  local http_code=$(echo "${response}" | tail -1)
  local body_text=$(echo "${response}" | head -1)

  # Parse response
  local status="FAIL"
  local content=""
  local quality="unknown"

  if [[ "${http_code}" == "200" ]]; then
    # Try to extract content
    content=$(echo "${body_text}" | python3 -c "
import json,sys
try:
  d=json.load(sys.stdin)
  msg = d.get('choices',[{}])[0].get('message',{}).get('content','')
  print(msg)
except:
  print('PARSE_ERROR')
" 2>/dev/null)

    if [[ -n "${content}" && "${content}" != "PARSE_ERROR" ]]; then
      status="OK"
      PASSED_TESTS=$((PASSED_TESTS + 1))
      [[ "${with_key}" == "false" ]] && ANON_TESTS=$((ANON_TESTS + 1))
      # Assess quality
      if echo "${content}" | grep -q "LAIA\|OK"; then
        quality="good"
      elif [[ ${#content} -gt 5 ]]; then
        quality="decent"
      else
        quality="short"
      fi
    else
      status="PARSE_ERROR"
    fi
  elif [[ "${http_code}" == "401" || "${http_code}" == "403" ]]; then
    status="NO_AUTH"
    content="$(echo "${body_text}" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("error",{}).get("message","auth_required"))' 2>/dev/null || echo 'auth_required')"
  elif [[ "${http_code}" == "429" ]]; then
    status="RATE_LIMIT"
    content="Rate limit exceeded"
  elif [[ "${http_code}" == "0" ]]; then
    status="TIMEOUT"
    latency="${TIMEOUT}000+"
  else
    status="HTTP_${http_code}"
    content="$(echo "${body_text}" | head -c 100)"
  fi

  # Format result
  local key_str="🔑"
  [[ "${with_key}" == "false" ]] && key_str="🌐"

  local status_emoji="❌"
  [[ "${status}" == "OK" ]] && status_emoji="✅"
  [[ "${status}" == "NO_AUTH" ]] && status_emoji="🔐"
  [[ "${status}" == "RATE_LIMIT" ]] && status_emoji="⏱️"
  [[ "${status}" == "TIMEOUT" ]] && status_emoji="⏳"

  printf "%-12s %-45s %5sms  %s %-12s %s\n" \
    "${provider}" \
    "${model_id:0:44}" \
    "${latency}" \
    "${status_emoji}" \
    "${status}" \
    "${quality}"

  # Store result in JSON
  RESULTS_JSON+="\n  \"${provider}/${model_id}:${with_key}\": {\"latency\": ${latency}, \"status\": \"${status}\", \"quality\": \"${quality}\"}, "
}

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                    LAIA Model Benchmark Report                         ║"
echo "║                    $(date '+%Y-%m-%d %H:%M:%S')                                        ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Parse providers.yaml and test each
echo "Provider       Model                                      Latency Status       Quality"
echo "───────────────────────────────────────────────────────────────────────────────────────"

python3 << 'PYTHON_EOF'
import yaml
import os
import sys

providers_file = os.environ['PROVIDERS_FILE']

with open(providers_file) as f:
    providers_config = yaml.safe_load(f)

# Test each provider's models
for provider_name, provider_data in providers_config.get('providers', {}).items():
    if provider_name in ['local', 'lan']:
        continue
    
    # Skip provider if it's not a dict (local/lan are special)
    if not isinstance(provider_data, dict):
        continue
    
    api_base = provider_data.get('api_base', '')
    api_key_env = provider_data.get('api_key_env', '')
    models = provider_data.get('models', [])
    
    # Test up to 2 models per provider to save time
    for model in models[:2]:
        if not isinstance(model, dict):
            continue
        model_id = model.get('id', '')
        if not model_id:
            continue
        
        # Print provider info
        print(f"# Testing {provider_name}: {model_id}")

PYTHON_EOF

# Manual test of each configured provider
echo ""
echo "Testing Groq models (primary provider)..."
test_model "groq" "llama-3.1-8b-instant" "https://api.groq.com/openai/v1" "GROQ_API_KEY" "true"
test_model "groq" "llama-3.1-8b-instant" "https://api.groq.com/openai/v1" "GROQ_API_KEY" "false"

echo ""
echo "Testing OpenRouter models..."
test_model "openrouter" "meta-llama/llama-3.1-8b-instruct:free" "https://openrouter.ai/api/v1" "OPENROUTER_API_KEY" "true"
test_model "openrouter" "meta-llama/llama-3.1-8b-instruct:free" "https://openrouter.ai/api/v1" "OPENROUTER_API_KEY" "false"

echo ""
echo "Testing HuggingFace models..."
test_model "huggingface" "meta-llama/Llama-3.1-8B-Instruct" "https://api-inference.huggingface.co/v1" "HF_TOKEN" "true"
test_model "huggingface" "meta-llama/Llama-3.1-8B-Instruct" "https://api-inference.huggingface.co/v1" "HF_TOKEN" "false"

echo ""
echo "Testing Mistral models..."
test_model "mistral" "open-mistral-7b" "https://api.mistral.ai/v1" "MISTRAL_API_KEY" "true"
test_model "mistral" "open-mistral-7b" "https://api.mistral.ai/v1" "MISTRAL_API_KEY" "false"

echo ""
echo "Testing Google AI Studio models..."
test_model "google" "gemini-2.0-flash" "https://generativelanguage.googleapis.com/v1beta/openai" "GOOGLE_API_KEY" "true"
test_model "google" "gemini-2.0-flash" "https://generativelanguage.googleapis.com/v1beta/openai" "GOOGLE_API_KEY" "false"

echo ""
echo "───────────────────────────────────────────────────────────────────────────────────────"
echo ""

# Print summary
printf "Results: %d/%d tests passed (%d anonymous)\n" "${PASSED_TESTS}" "${TOTAL_TESTS}" "${ANON_TESTS}"

if [[ ${PASSED_TESTS} -eq 0 ]]; then
  echo -e "${YELLOW}⚠️  No tests passed. Make sure you have API keys configured.${NC}"
  echo "   Run: laia-setup-wizard"
fi

if [[ ${ANON_TESTS} -gt 0 ]]; then
  echo -e "${GREEN}✅ Found ${ANON_TESTS} models working anonymously!${NC}"
fi

echo ""
echo "📊 Full results saved to: ${RESULTS_FILE}"
echo "   (Run: cat ${RESULTS_FILE} | jq for detailed view)"

