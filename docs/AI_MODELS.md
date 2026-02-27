# AI Models & Providers Guide

LAIA supports multiple AI modes. Choose one based on your needs.

**Status:** All providers tested on 2026-02-26. See `docs/MODEL_BENCHMARK.md` for detailed results.

## ☁️ Online Free Models

Free cloud APIs with no hardware requirements. All require API key (no truly anonymous access).

**Recommendation:** Start with **Groq** (fastest, easiest signup, most generous free tier)

### Provider Comparison (2026-02-26 Benchmark)

| Provider | Model | Latency | Quality | Rate Limit | Setup Time | Cost | Status |
|----------|-------|---------|---------|-----------|-----------|------|--------|
| **Groq** ⭐ | llama-3.1-8b-instant | 155ms | Excellent | 30/min | 3 min | Free | ✅ Working |
| **OpenRouter** | llama-3.1-8b-free | 108ms | Excellent | 20/min | 4 min | Free | ✅ Working |
| **Google AI** | gemini-2.0-flash | 139ms | Excellent | 15/min | 3 min | Free | ✅ Working |
| **Mistral** | open-mistral-7b | 187ms | Very Good | 1/sec | 4 min | Free | ✅ Working |
| **HuggingFace** | Llama-3.1-8B | 225ms | Good | Varies | 3 min | Free | ⚠️ Deprecated |

**Legend:** ✅ = Tested working, ⚠️ = Issues found (see MODEL_BENCHMARK.md)

### Groq (⭐ Recommended)

**Speed:** 300–560 tokens/sec (fastest free tier)  
**Setup:** 30 seconds  
**Models:** Llama 3.1 8B/70B, Gemma 2 9B, Mixtral 8x7B  

```bash
# Get API key at: https://console.groq.com
curl -X POST https://api.groq.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.1-8b-instant",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 100
  }'
```

### OpenRouter

**Models:** 200+ free models (Llama, Phi, Gemma, Mistral, DeepSeek R1)  
**Setup:** 1 minute  
**Signup:** https://openrouter.ai

Aggregates dozens of free models under one API. Append `:free` to model IDs.

```bash
curl -X POST https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/llama-3.1-8b-instruct:free",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### HuggingFace Inference

**⚠️ Deprecated:** The old `api-inference.huggingface.co` endpoint was discontinued as of 2026-02.

**Models:** 100k+ open models (via new endpoints)  
**Status:** Endpoint deprecated, endpoint migration in progress

**Recommendation:** Use **OpenRouter** instead (easier, same models, better uptime)

**Legacy code (no longer works):**
```bash
# DEPRECATED — DO NOT USE
curl -X POST https://api-inference.huggingface.co/v1/chat/completions
```

**If you need HuggingFace models:**
- Option 1: Use OpenRouter (many HF models available)
- Option 2: Run locally with `transformers` library + Ollama
- Option 3: Use new HuggingFace Endpoints (requires setup)

### Mistral AI

**Models:** Mistral 7B Open, Mixtral 8x7B  
**Signup:** https://console.mistral.ai  

```bash
curl -X POST https://api.mistral.ai/v1/chat/completions \
  -H "Authorization: Bearer $MISTRAL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "open-mistral-7b",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

### Google AI Studio

**Models:** Gemini 2.0 Flash (vision-capable), Gemini 1.5 Flash  
**Signup:** https://aistudio.google.com/apikey  

```bash
curl -X POST https://generativelanguage.googleapis.com/v1beta/openai/chat/completions \
  -H "x-goog-api-key: $GOOGLE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.0-flash",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

## 🖥️ Local Models (Ollama)

Run models on your computer. Fully private, works offline.

### Hardware Requirements

| Tier | RAM | Models | Setup Time |
|------|-----|--------|------------|
| **Minimal** | 4-8 GB | Gemma 3 1B–4B | 5 min |
| **Standard** | 16 GB | Gemma 3 4B–7B models | 10 min |
| **Powerful** | 32+ GB | All models, 70B capable | 10 min |

### Recommended Models

**Compact (4B–7B):**
- `gemma3:4b` — Best all-rounder, vision-capable
- `phi4-mini` — Best for coding
- `deepseek-r1:7b` — Strong reasoning

**Powerful (70B):**
- `llama3.3:70b` — Near-frontier quality
- `deepseek-r1:70b` — Best open reasoning

### Install

```bash
# Install Ollama
curl https://ollama.ai/install.sh | sh

# Pull a model
ollama pull gemma3:4b

# Run
ollama serve
```

The model runs at `http://127.0.0.1:11434`. LAIA auto-detects it.

## 🌐 LAN Remote (Ollama on Network)

Connect to Ollama running on another machine (home server, workstation, etc.).

### Server Setup

On the machine running Ollama, ensure it listens on all interfaces:

```bash
sudo systemctl edit ollama
# Add or modify:
# [Service]
# Environment="OLLAMA_HOST=0.0.0.0:11434"

sudo systemctl restart ollama
```

Verify:
```bash
curl http://localhost:11434/api/tags
```

### Client Setup

In LAIA setup, choose "LAN Remote" and enter:
- **Host:** `192.168.1.100` (your server's IP)
- **Port:** `11434` (default)

LAIA will auto-detect available models and use them.

## Switching Modes

Change AI mode at any time:

```bash
bash /opt/laia/scripts/setup-ai-provider.sh
```

Or use the GUI:
```bash
laia-config  # Open configurator → AI Keys tab
```

## Testing Your Setup

```bash
bash /opt/laia/scripts/test-connection.sh
```

This verifies your chosen AI mode is working.
