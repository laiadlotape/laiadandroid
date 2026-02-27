<div align="center">

# LAIA

**The AI-ready Linux distribution.**  
Online free models · Local inference · LAN remote · Privacy-first

[![Build Status](https://github.com/laiadlotape/laia/actions/workflows/build-test.yml/badge.svg)](https://github.com/laiadlotape/laia/actions)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![Debian Bookworm](https://img.shields.io/badge/base-Debian%20Bookworm-red.svg)](https://debian.org)

</div>

## What is LAIA?

LAIA is a Debian-based Linux distribution built around one idea: **AI should just work**, without requiring powerful hardware, expensive APIs, or complex setup.

**Three ways to use AI with LAIA — choose what fits you:**

| Mode | Setup time | Requirements | Best for |
|------|-----------|--------------|----------|
| ☁️ **Online Free** | 30 seconds | Free API key | Everyone — no hardware needed |
| 🖥️ **Local** | 5–10 min | 4GB+ RAM | Privacy, offline use |
| 🌐 **LAN Remote** | 10 seconds | Ollama on another machine | Home labs, shared servers |

## Quick Start

### Option 1: Online Free (Recommended)

1. Get a free API key from [Groq](https://console.groq.com) — no credit card needed
2. Install LAIA and run `laia-setup`
3. Choose "Online Free" → "Groq" → paste your key
4. Done — 300+ tokens/second, free

### Option 2: Local Inference

```bash
laia-setup  # choose "Local" → picks models based on your RAM
```

### Option 3: LAN Remote

```bash
laia-setup  # choose "LAN Remote" → enter your Ollama server IP
```

## Free Online Providers

| Provider | Speed | Free Models | Signup |
|----------|-------|-------------|--------|
| **Groq** ⭐ | 300–560 tok/sec | Llama 3.1 8B/70B, Gemma 2, Mixtral | [console.groq.com](https://console.groq.com) |
| **OpenRouter** | Varies | 50+ free models (`:free` suffix) | [openrouter.ai](https://openrouter.ai) |
| **HuggingFace** | Varies | 100k+ open models | [huggingface.co](https://huggingface.co) |
| **Mistral AI** | Fast | Mistral 7B open | [console.mistral.ai](https://console.mistral.ai) |
| **Google AI Studio** | Fast | Gemini 2.0 Flash | [aistudio.google.com](https://aistudio.google.com) |

## Features

- **Seamless provider switching** — change from Groq to local Ollama in one command
- **OpenWebUI** — beautiful chat interface, works with all providers
- **OpenClaw** — AI assistant integrated into the desktop (restrictive by default)
- **Security-first** — AppArmor profiles, UFW rules, fail2ban, sysctl hardening
- **Portable** — runs on x86_64 and ARM64 (Pi 4/5 friendly)
- **Frictionless** — LAIA setup wizard gets you running in under 2 minutes

## Architecture

```
┌─────────────────────────────────────────────┐
│              User Applications               │
│         OpenWebUI · OpenClaw · Apps         │
├─────────────────────────────────────────────┤
│              LAIA AI Router                  │
│   (mode: online | local | lan)              │
├──────────────┬──────────────┬───────────────┤
│  Online Free │    Local     │  LAN Remote   │
│  Groq/OR/HF  │   Ollama     │  Ollama/LMS   │
│  /OpenAI API │  127.0.0.1   │  192.168.x.x  │
└──────────────┴──────────────┴───────────────┘
│              Debian Bookworm Base            │
│              XFCE · Security Layer          │
└─────────────────────────────────────────────┘
```

## Installation

```bash
# Download and run installer
curl -fsSL https://raw.githubusercontent.com/laiadlotape/laia/master/scripts/install.sh | sudo bash

# Or clone and install
git clone https://github.com/laiadlotape/laia
cd laia && sudo bash scripts/install.sh
```

## Configuration

```bash
laia-setup          # First-time AI setup wizard
laia-config         # GUI settings (GTK3)
laia-test           # Test current AI connection
```

## Docs

- [Installation Guide](docs/INSTALL.md)
- [AI Models & Providers](docs/AI_MODELS.md)
- [Security](docs/SECURITY.md)
- [Build from source](docs/BUILD.md)
- [Contributing](docs/CONTRIBUTING.md)

## License

GPL-3.0 — see [LICENSE](LICENSE). Free to use, modify, and distribute.
