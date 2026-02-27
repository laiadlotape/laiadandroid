# LAIA Installation Guide

## Method 1: Quick Install (existing Debian/Ubuntu)

Fastest way — transforms your current system:

```bash
curl -fsSL https://raw.githubusercontent.com/laiadlotape/laia/main/scripts/install.sh | sudo bash
```

Options:
- `--minimal` — skip XFCE desktop, install security + AI stack only
- `--no-ai` — skip Ollama/OpenWebUI (install later with `sudo bash /opt/laia/config/ai/install-ai-stack.sh`)
- `--no-gui` — skip graphical tools (headless server use)

## Method 2: ISO (clean install)

Best for new machines or USB-booting:

1. Download latest ISO from [Releases](https://github.com/laiadlotape/laia/releases)
2. Flash to USB:
   ```bash
   sudo dd if=laia-1.0.0-amd64.iso of=/dev/sdX bs=4M status=progress
   ```
3. Boot from USB → follow graphical installer

## Method 3: Build from Source

```bash
git clone https://github.com/laiadlotape/laia
cd laia
make setup-deps   # install live-build
make iso          # build amd64 ISO (~20 min)
```

## After Install

1. Run `laia-config` → Security Configurator
2. Open **http://localhost:3000** → AI chat interface
3. The setup wizard runs on first boot

## Minimum Requirements

- Debian 12 (Bookworm) or Ubuntu 22.04+
- 8 GB RAM (4 GB works for small AI models)
- 32 GB storage
