# LAIA AI Models Guide

## Overview

LAIA uses [Ollama](https://ollama.com) to run AI models locally on your computer.
**Your data never leaves your device** — no cloud, no subscription, no tracking.

All models listed here are free and open-source.

---

## Pre-installed Models (Default)

These are installed automatically based on your hardware during setup:

| Model | Download Size | RAM Required | Best For |
|-------|--------------|--------------|---------|
| Gemma 3 (1B) | ~0.8 GB | 2 GB | Ultra-fast, basic tasks |
| Gemma 3 (4B) | ~2.5 GB | 4 GB | Fast general use, vision |
| Phi-4 Mini | ~2.5 GB | 4 GB | Coding, reasoning |
| Llama 3.2 (3B) | ~2.0 GB | 3 GB | General, balanced |

---

## Installing More Models

Open a terminal and use `ollama pull`:

```bash
# Reasoning models
ollama pull deepseek-r1:7b       # Best open reasoning model (7B)
ollama pull deepseek-r1:8b       # Llama-based R1 variant

# Coding models
ollama pull qwen2.5-coder:7b     # Best coding model at 7B
ollama pull qwen2.5-coder:3b     # Smaller coding model (lower RAM)

# General models
ollama pull mistral:7b           # Mistral 7B — solid all-rounder
ollama pull qwen3:4b             # Qwen 3 with thinking mode (Oct 2025)
ollama pull qwen3:8b             # Qwen 3 mid-range with thinking
ollama pull gemma3:12b           # Google's 12B with vision support

# High-end (32GB+ RAM or GPU)
ollama pull gemma3:27b           # Google's best Gemma with vision
ollama pull llama3.3:70b         # Near state-of-the-art open model
ollama pull deepseek-r1:70b      # Best open reasoning, approaches o3
```

---

## Hardware Guide

| Your RAM | Recommended Models | Notes |
|----------|-------------------|-------|
| 4–7 GB | gemma3:1b | Very limited — only tiny models |
| 8 GB | gemma3:4b, phi4-mini | Good compact selection |
| 16 GB | + llama3.2:3b, deepseek-r1:7b, qwen2.5-coder:7b | Strong selection |
| 32 GB | + qwen3:8b, gemma3:12b, mistral-nemo | Full library |
| 64 GB+ | + gemma3:27b, llama3.3:70b | Near cloud quality |

---

## Model Families Explained

### 🧠 Reasoning: DeepSeek R1
DeepSeek R1 uses **chain-of-thought** reasoning — it "thinks out loud" before answering.
Great for math, logic, analysis, and complex questions.
```bash
ollama pull deepseek-r1:7b   # 8GB RAM minimum
```

### 💻 Coding: Qwen 2.5 Coder
Best dedicated coding model available for free. Understands 92+ programming languages.
```bash
ollama pull qwen2.5-coder:7b   # 8GB RAM minimum
```

### 👁️ Vision: Gemma 3
Gemma 3 models (1B, 4B, 12B, 27B) can analyze images in addition to text.
```bash
ollama pull gemma3:4b   # Compact vision model
```

### 🔮 Thinking Mode: Qwen 3
Qwen 3 models support a "thinking" mode for deeper reasoning, similar to DeepSeek R1.
```bash
ollama pull qwen3:4b    # 4GB RAM
ollama pull qwen3:8b    # 8GB RAM
```

---

## Web Interface (OpenWebUI)

LAIA includes **OpenWebUI** — a full-featured web interface for chatting with your AI models.

**Access it at:** [http://localhost:3000](http://localhost:3000)

Features:
- Chat with any installed model
- Image uploads (with vision models like Gemma 3)
- Multiple chat history
- Model switching on the fly
- Markdown rendering

---

## Managing Models

```bash
# List installed models
ollama list

# Remove a model (frees disk space)
ollama rm gemma3:4b

# Check Ollama status
ollama ps

# Run a model in terminal
ollama run gemma3:4b
```

---

## Privacy & Security

- Ollama binds to **127.0.0.1 only** — not accessible from other computers on your network
- OpenWebUI also runs on localhost only
- No telemetry, no data collection, no external API calls during inference
- Models are downloaded once and stored locally

---

## Troubleshooting

**Model is slow:**
- Check available RAM with: `free -h`
- Smaller models are faster: try `gemma3:1b` or `gemma3:4b`
- If you have an NVIDIA GPU, Ollama uses it automatically

**Out of disk space:**
```bash
du -sh ~/.ollama/models/   # See how much space models use
ollama rm <model-name>     # Remove unused models
```

**Ollama not running:**
```bash
sudo systemctl status ollama
sudo systemctl start ollama
```

**OpenWebUI not loading:**
```bash
sudo systemctl status laia-openwebui
sudo systemctl restart laia-openwebui
```
