# LAIA Linux

> **L**inux **A**I **I**ntelligent **A**ppliance — A secure, portable, AI-ready Linux distribution.

[![Build & Test](https://github.com/laiadlotape/laia/workflows/Build%20%26%20Test/badge.svg)](https://github.com/laiadlotape/laia/actions)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL3-blue.svg)](LICENSE)
[![Hardware: x86_64 / arm64](https://img.shields.io/badge/Hardware-x86__64%20%7C%20arm64-green.svg)](#hardware-requirements)

LAIA is a minimal, secure Linux distribution built on Debian Stable, designed to be:
- **Cloned in minutes** — one script replicates a full working system
- **AI-ready** — Ollama + curated free models pre-installed and running locally
- **Security-first** — hardened kernel, AppArmor, restricted firewall, safe OpenClaw config
- **Windows-friendly** — graphical setup wizard and familiar UX patterns
- **Portable** — tested on modest hardware, runs live from USB

## Quick Start

```bash
# Install on existing Debian/Ubuntu system:
curl -fsSL https://raw.githubusercontent.com/laiadlotape/laia/main/scripts/install.sh | sudo bash

# Or build ISO from source:
make iso
```

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | x86_64 / arm64, 2 cores | 4+ cores |
| RAM | 8 GB | 16 GB (for larger AI models) |
| Storage | 32 GB | 64+ GB |
| Network | Required for setup | — |

Tested on: Raspberry Pi 5, generic x86_64 laptops, old Intel MacBooks, mini PCs (N100 chipset).

## What's Included

- **Base**: Debian Bookworm + XFCE (lightweight, Windows-familiar)
- **AI stack**: Ollama + OpenWebUI + curated free models (Gemma 2, Phi-4 Mini, Llama 3.2, Mistral)
- **Security**: AppArmor enforcing, UFW firewall, fail2ban, automatic security updates
- **OpenClaw**: Pre-installed in maximally restricted mode with GUI configurator
- **LAIA Tools**: Graphical security configurator, first-run setup wizard, model manager

## Documentation

- [Installation Guide](docs/INSTALL.md)
- [User Guide](docs/USER_GUIDE.md)
- [Security Configuration](docs/SECURITY.md)
- [AI Models Guide](docs/AI_MODELS.md)
- [Building from Source](docs/BUILD.md)
- [Contributing](docs/CONTRIBUTING.md)

## Philosophy

LAIA exists because setting up a secure, AI-capable Linux system takes days.
We believe it should take minutes.

Security is not optional. Every default is hardened. You relax restrictions
through a GUI that explains the risks as you go.

## License

GPL-3.0 — see [LICENSE](LICENSE)
