#!/usr/bin/env bash
# Install Ollama — the local AI model runner
set -euo pipefail

log() { echo "[Ollama] $*"; }

log "Installing Ollama..."

# Check for existing installation
if command -v ollama &>/dev/null; then
    CURRENT=$(ollama --version 2>/dev/null | head -1 || echo "unknown")
    log "Ollama already installed: $CURRENT"
    log "Updating..."
fi

# Official installer (from ollama.com)
curl -fsSL https://ollama.com/install.sh | sh

# Verify installation
if ! command -v ollama &>/dev/null; then
    echo "ERROR: Ollama installation failed"
    exit 1
fi

log "✅ Ollama installed: $(ollama --version)"

# Configure Ollama service for LAIA (localhost only, autostart)
OLLAMA_SERVICE="/etc/systemd/system/ollama.service"
if [[ -f "$OLLAMA_SERVICE" ]]; then
    # Ensure it only binds to localhost (security)
    if ! grep -q "OLLAMA_HOST" "$OLLAMA_SERVICE"; then
        sed -i '/\[Service\]/a Environment="OLLAMA_HOST=127.0.0.1"' "$OLLAMA_SERVICE"
        log "Configured Ollama to bind localhost only (security)"
    fi
    systemctl daemon-reload
    systemctl enable ollama
    systemctl start ollama
fi

log "Ollama service running on http://127.0.0.1:11434"
