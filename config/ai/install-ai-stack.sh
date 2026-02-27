#!/usr/bin/env bash
# Install complete LAIA AI stack
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== LAIA AI Stack Installer ==="
echo "This will install: Ollama + default AI models + OpenWebUI"
echo ""

# Check disk space (models need 4-20GB)
FREE_GB=$(df -BG / | awk 'NR==2 {gsub("G",""); print $4}')
if [[ $FREE_GB -lt 10 ]]; then
    echo "⚠️  Only ${FREE_GB}GB free disk space. Models need 4-20GB. Consider --minimal."
fi

echo "1/3 Installing Ollama..."
bash "$SCRIPT_DIR/install-ollama.sh"

echo "2/3 Installing AI models..."
bash "$SCRIPT_DIR/install-models.sh"

echo "3/3 Installing OpenWebUI..."
bash "$SCRIPT_DIR/install-openwebui.sh"

echo ""
echo "✅ AI stack installed!"
echo "   Ollama API:  http://localhost:11434"
echo "   OpenWebUI:   http://localhost:3000"
echo ""
echo "Open your browser and go to: http://localhost:3000"
