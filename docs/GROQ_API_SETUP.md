# Groq API Setup Guide

This guide walks you through setting up your Groq API key to use LAIA Chat.

## What is Groq?

[Groq](https://groq.com) is an AI infrastructure company that provides access to **open-source LLMs** (Large Language Models) through a fast, free API.

**Key Features:**
- ⚡ **Ultra-fast** inference (20+ tokens/second)
- 🆓 **Completely free** - no credit card required
- 🔓 **Open-source models** - Mixtral, Llama 2, Gemma
- 🌍 **Worldwide** - available globally
- 📱 **Mobile-friendly** - works on Android and iOS

## Step 1: Visit Groq Console

1. Open [console.groq.com](https://console.groq.com) in your browser
2. You'll see the Groq Console login page

## Step 2: Sign Up (First Time)

If you don't have a Groq account:

1. Click **"Sign Up"** or **"Get Started"**
2. Choose sign-up method:
   - Email address
   - Google account
   - GitHub account
3. Fill in your details (no credit card needed!)
4. Verify your email if prompted
5. Complete any verification steps

## Step 3: Create API Key

Once logged in:

1. Look for **"API Keys"** or **"Keys"** in the menu
2. Click **"Create New Key"** or **"+ New API Key"**
3. You'll see a modal with your new API key
4. **COPY THE KEY** - you'll need it in the app
   - Key format: `gsk_...` (long string starting with "gsk_")
5. Optionally name it (e.g., "LAIA Android App")
6. Click **"Create"** or **"Confirm"**

**⚠️ Important:** Copy your key immediately. You won't be able to see it again after closing the modal.

## Step 4: Configure LAIA Chat

### On Android Device/Emulator:

1. **Open LAIA Chat** app
2. Tap **Settings** (⚙️) in the top right
3. You'll see **"Groq API Configuration"**
4. Paste your API key in the **"API Key"** field
5. Tap **"Validate API Key"** - wait for ✓ (check mark)
6. Tap **"Save API Key"** - should see success message
7. Go back to chat and start talking to LAIA!

### Via Environment Variable (Development):

If developing or testing:

```bash
export GROQ_API_KEY=gsk_your_key_here
flutter run
```

## Step 5: Verify It Works

1. Go back to the chat screen
2. Type a message: "Hello, LAIA!"
3. You should get a response within 1-2 seconds

If it doesn't work, see [Troubleshooting](#troubleshooting).

---

## Available Models

Groq provides access to these models **(all free)**:

### Mixtral 8x7B (Default)
```
Model: mixtral-8x7b-32768
Speed: ⚡⚡⚡ Fastest
Quality: ⭐⭐⭐⭐ Great
Best for: General chat, coding, creative writing
```

Example response time: **0.5-1 second**

### Llama 2 70B
```
Model: llama2-70b-4096
Speed: ⚡⚡ Fast
Quality: ⭐⭐⭐⭐⭐ Excellent
Best for: Complex reasoning, detailed answers
```

Example response time: **1-2 seconds**

### Gemma 7B
```
Model: gemma-7b-it
Speed: ⚡⚡⚡ Fastest
Quality: ⭐⭐⭐ Good
Best for: Quick responses, lightweight tasks
```

Example response time: **0.3-0.5 second**

### To Change Model:

Edit `lib/config/app_config.dart`:

```dart
// Change this line
static const String defaultModel = 'mixtral-8x7b-32768';

// To one of:
// static const String defaultModel = 'llama2-70b-4096';
// static const String defaultModel = 'gemma-7b-it';
```

Then rebuild:
```bash
flutter run
```

---

## API Key Security

### ✅ Safe:
- Storing in app's secure storage (encrypted)
- Using in private, personal apps
- Restricting to known domains (if available)

### ❌ Unsafe:
- Sharing your API key publicly
- Committing to GitHub
- Embedding in frontend code sent to users
- Using in production without domain restrictions

### Best Practices:

1. **Never commit your key** to Git:
   ```bash
   echo "GROQ_API_KEY=gsk_..." >> .env
   # Add to .gitignore
   ```

2. **Use environment variables** in production
3. **Rotate keys regularly** - generate new ones
4. **Delete unused keys** - remove old ones from console
5. **Use IP whitelisting** if available in Groq Console

---

## Rate Limits

The free tier has rate limits:

| Metric | Limit |
|--------|-------|
| Requests/minute | 30 |
| Tokens/minute | 3,000 |
| Max tokens/request | 4,096 |

**If you hit the limit:**
- ✅ Wait 1 minute and try again
- ✅ Use shorter responses (lower `maxTokens`)
- ✅ Upgrade to paid tier at [console.groq.com](https://console.groq.com)

---

## Troubleshooting

### "Invalid API key"
**Problem:** Validation fails

**Solutions:**
1. Copy the key again (no extra spaces!)
2. Make sure it starts with `gsk_`
3. Generate a new key in Groq Console
4. Check internet connection

### "Rate limit exceeded"
**Problem:** Gets error after a few messages

**Solutions:**
1. Wait 1 minute before sending more messages
2. Lower `maxTokens` in config (uses fewer tokens per response)
3. Upgrade to Groq's paid tier

### "Timeout error"
**Problem:** Takes too long to get response

**Solutions:**
1. Check internet speed (try: `ping google.com`)
2. Use a faster model: `gemma-7b-it`
3. Increase timeout in `app_config.dart`:
   ```dart
   static const int requestTimeoutSeconds = 60;
   ```

### "No response from Groq"
**Problem:** Groq API is down or not responding

**Solutions:**
1. Check [Groq Status Page](https://status.groq.com)
2. Try in 5-10 minutes
3. Verify your internet connection
4. Check API key in Groq Console

### "Wrong model selected"
**Problem:** Using a model that's not available

**Solutions:**
1. Check available models in Groq Console
2. Use default: `mixtral-8x7b-32768`
3. Make sure model name matches exactly

---

## Advanced: Self-Hosting or Proxying

If you want to run models locally:

1. **Ollama** - Run open-source models locally
2. **LocalAI** - Self-hosted, compatible with OpenAI API
3. **LM Studio** - User-friendly local model runner

To use with LAIA, change `groqApiUrl` in `app_config.dart`:

```dart
static const String groqApiUrl = 'http://localhost:8000/v1';  // Your local server
```

---

## Resources

- **Groq Console**: [console.groq.com](https://console.groq.com)
- **Groq Docs**: [docs.groq.com](https://docs.groq.com)
- **Groq Community**: [Discord](https://discord.gg/groq)
- **API Reference**: [OpenAI-compatible API](https://docs.groq.com/openai)

---

## Questions?

- 📖 Check the [README.md](../README.md)
- 🆘 Open an issue on [GitHub](https://github.com/laiadlotape/laiadandroid/issues)
- 💬 Join [Groq Discord](https://discord.gg/groq)

---

**Happy chatting! 🚀**
