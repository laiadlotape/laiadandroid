# Contributing to LAIA

## Quick Start

```bash
git clone https://github.com/laiadlotape/laia
cd laia
# Make changes in your scope
make test   # must pass before submitting PR
```

## Project Structure

| Directory | Scope |
|-----------|-------|
| `config/security/` | Security hardening configs |
| `config/ai/` | AI stack (Ollama, OpenWebUI, models) |
| `config/openclaw/` | OpenClaw restricted mode config |
| `gui/` | Graphical tools (GTK3) |
| `scripts/` | Install and setup scripts |
| `tests/` | Integration tests |
| `docs/` | Documentation |

## Rules

1. **All defaults must be secure** — relaxation is opt-in via GUI
2. Every new feature needs a test in `tests/`
3. Never commit secrets, keys, or personal config
4. Document new features in the relevant `docs/` file
5. Shell scripts must pass `bash -n` (syntax check)
6. JSON/YAML must be valid (CI enforces this)

## Submitting Changes

- Open a PR against `main`
- CI will run all tests automatically
- Security changes need explicit justification
