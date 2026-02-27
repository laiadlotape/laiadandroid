#!/usr/bin/env bash
LAIA_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# New AI config files
[[ -f "$LAIA_ROOT/config/ai/providers.yaml" ]] || { echo "Missing: config/ai/providers.yaml"; exit 1; }
[[ -f "$LAIA_ROOT/config/ai/config.yaml" ]] || { echo "Missing: config/ai/config.yaml"; exit 1; }
[[ -f "$LAIA_ROOT/config/ai/models.yaml" ]] || { echo "Missing: config/ai/models.yaml"; exit 1; }

# New scripts
[[ -f "$LAIA_ROOT/scripts/setup-ai-provider.sh" ]] || { echo "Missing: scripts/setup-ai-provider.sh"; exit 1; }
[[ -f "$LAIA_ROOT/scripts/test-connection.sh" ]] || { echo "Missing: scripts/test-connection.sh"; exit 1; }
[[ -x "$LAIA_ROOT/scripts/setup-ai-provider.sh" ]] || { echo "Not executable: scripts/setup-ai-provider.sh"; exit 1; }
[[ -x "$LAIA_ROOT/scripts/test-connection.sh" ]] || { echo "Not executable: scripts/test-connection.sh"; exit 1; }

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('$LAIA_ROOT/config/ai/providers.yaml'))" || { echo "Invalid YAML: config/ai/providers.yaml"; exit 1; }
python3 -c "import yaml; yaml.safe_load(open('$LAIA_ROOT/config/ai/config.yaml'))" || { echo "Invalid YAML: config/ai/config.yaml"; exit 1; }
python3 -c "import yaml; yaml.safe_load(open('$LAIA_ROOT/config/ai/models.yaml'))" || { echo "Invalid YAML: config/ai/models.yaml"; exit 1; }

# Validate shell scripts
bash -n "$LAIA_ROOT/scripts/setup-ai-provider.sh" || { echo "Syntax error: scripts/setup-ai-provider.sh"; exit 1; }
bash -n "$LAIA_ROOT/scripts/test-connection.sh" || { echo "Syntax error: scripts/test-connection.sh"; exit 1; }

# Check models.yaml has required sections
grep -q "^online:" "$LAIA_ROOT/config/ai/models.yaml" || { echo "Missing 'online:' section in models.yaml"; exit 1; }
grep -q "^local:" "$LAIA_ROOT/config/ai/models.yaml" || { echo "Missing 'local:' section in models.yaml"; exit 1; }
grep -q "^lan:" "$LAIA_ROOT/config/ai/models.yaml" || { echo "Missing 'lan:' section in models.yaml"; exit 1; }

# Check providers.yaml has required providers
for provider in groq openrouter huggingface mistral google; do
  grep -q "^  $provider:" "$LAIA_ROOT/config/ai/providers.yaml" || { echo "Missing provider: $provider"; exit 1; }
done

echo "✅ All AI config tests passed"
