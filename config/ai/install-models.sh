#!/usr/bin/env bash
# Install AI models based on system RAM
# Usage: bash install-models.sh [--all] [--minimal] [model-id...]
set -euo pipefail

log()  { echo -e "\033[0;32m[Models]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
err()  { echo -e "\033[0;31m[ERROR]\033[0m $*"; }

# Detect available RAM in GB
RAM_GB=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)
log "Detected RAM: ${RAM_GB}GB"

# Default models for this RAM level
if [[ $RAM_GB -lt 8 ]]; then
    warn "Less than 8GB RAM detected. Only very small models will work well."
    DEFAULT_MODELS=("gemma3:1b" "gemma3:4b")
elif [[ $RAM_GB -lt 16 ]]; then
    log "8-16GB RAM: Installing compact but capable models"
    DEFAULT_MODELS=("gemma3:4b" "phi4-mini" "llama3.2:3b")
elif [[ $RAM_GB -lt 32 ]]; then
    log "16-32GB RAM: Installing full standard model set"
    DEFAULT_MODELS=("gemma3:4b" "phi4-mini" "llama3.2:3b" "deepseek-r1:7b" "qwen2.5-coder:7b")
else
    log "32GB+ RAM: Installing comprehensive model set"
    DEFAULT_MODELS=("gemma3:12b" "qwen3:8b" "deepseek-r1:8b" "phi4-mini" "qwen2.5-coder:7b")
fi

# Parse arguments
INSTALL_ALL=false
MODELS_TO_INSTALL=()
for arg in "$@"; do
    case "$arg" in
        --all) INSTALL_ALL=true;;
        --minimal) MODELS_TO_INSTALL=("gemma3:1b");;
        *) MODELS_TO_INSTALL+=("$arg");;
    esac
done

if [[ ${#MODELS_TO_INSTALL[@]} -eq 0 ]]; then
    MODELS_TO_INSTALL=("${DEFAULT_MODELS[@]}")
fi

# Ensure Ollama is running
if ! curl -sf http://127.0.0.1:11434/api/tags &>/dev/null; then
    log "Starting Ollama..."
    ollama serve &>/dev/null &
    sleep 3
fi

# Install models
TOTAL=${#MODELS_TO_INSTALL[@]}
log "Installing $TOTAL model(s)..."
for i in "${!MODELS_TO_INSTALL[@]}"; do
    model="${MODELS_TO_INSTALL[$i]}"
    log "[$((i+1))/$TOTAL] Pulling $model..."
    if ollama pull "$model"; then
        log "✅ $model installed"
    else
        warn "Failed to install $model — skipping"
    fi
done

# List installed models
log ""
log "Installed models:"
ollama list
