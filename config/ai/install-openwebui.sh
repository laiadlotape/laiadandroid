#!/usr/bin/env bash
# Install OpenWebUI — web interface for Ollama
# Runs as a local service, accessible at http://localhost:3000
set -euo pipefail

log() { echo "[OpenWebUI] $*"; }

log "Installing OpenWebUI..."

# Check Python
if ! command -v python3 &>/dev/null; then
    apt-get install -y python3 python3-pip python3-venv
fi

# Create virtual environment
VENV_DIR="/opt/laia/openwebui"
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Install OpenWebUI
pip install open-webui

log "✅ OpenWebUI installed"

# Create systemd service
cat > /etc/systemd/system/laia-openwebui.service << 'EOF'
[Unit]
Description=LAIA OpenWebUI
After=network.target ollama.service
Wants=ollama.service

[Service]
Type=simple
Environment="OLLAMA_BASE_URL=http://127.0.0.1:11434"
Environment="WEBUI_AUTH=False"
Environment="HOST=127.0.0.1"
Environment="PORT=3000"
Environment="DATA_DIR=/var/lib/laia/openwebui"
ExecStart=/opt/laia/openwebui/bin/open-webui serve
Restart=on-failure
RestartSec=5s
User=laia-webui
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/var/lib/laia/openwebui

[Install]
WantedBy=multi-user.target
EOF

# Create dedicated user and data dir
useradd -r -s /bin/false laia-webui 2>/dev/null || true
mkdir -p /var/lib/laia/openwebui
chown laia-webui:laia-webui /var/lib/laia/openwebui

systemctl daemon-reload
systemctl enable laia-openwebui
systemctl start laia-openwebui

log "✅ OpenWebUI running at http://127.0.0.1:3000"
