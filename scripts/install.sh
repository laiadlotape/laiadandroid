#!/usr/bin/env bash
# LAIA Installer — transforms an existing Debian/Ubuntu system into LAIA
# Usage: curl -fsSL https://raw.githubusercontent.com/laiadlotape/laia/main/scripts/install.sh | sudo bash
# Or:    sudo bash scripts/install.sh [--minimal] [--no-ai] [--no-gui]
set -euo pipefail

LAIA_VERSION="1.0.0"
LAIA_DIR="/opt/laia"
LOG_FILE="/var/log/laia-install.log"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

log()     { echo -e "${GREEN}[LAIA]${NC} $*"   | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"  | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"    | tee -a "$LOG_FILE"; exit 1; }
section() { echo -e "\n${BLUE}──── $* ────${NC}" | tee -a "$LOG_FILE"; }

MINIMAL=false; NO_AI=false; NO_GUI=false
for arg in "$@"; do
  case $arg in
    --minimal) MINIMAL=true ;;
    --no-ai)   NO_AI=true   ;;
    --no-gui)  NO_GUI=true  ;;
  esac
done

section "LAIA v${LAIA_VERSION} Installation"
[[ $EUID -eq 0 ]] || error "Run as root: sudo bash install.sh"
grep -qiE "debian|ubuntu" /etc/os-release 2>/dev/null || \
  error "LAIA requires Debian or Ubuntu."

RAM_GB=$(awk '/MemTotal/{printf "%.0f",$2/1024/1024}' /proc/meminfo)
[[ $RAM_GB -ge 4 ]] || warn "Only ${RAM_GB}GB RAM — AI models may run slowly"

section "1/5 Updating system"
apt-get update -qq && apt-get upgrade -y -qq

section "2/5 Installing base packages"
PKGS=$(grep -v '^#' "$LAIA_DIR/config/packages/base.list" 2>/dev/null | \
       grep -v '^$' | tr '\n' ' ')
[[ -n "$PKGS" ]] || PKGS="ufw fail2ban apparmor apparmor-utils curl git python3"
apt-get install -y -qq $PKGS

section "3/5 Security hardening"
bash "$LAIA_DIR/config/security/harden.sh"

section "4/5 OpenClaw (restricted mode)"
bash "$LAIA_DIR/config/openclaw/setup-restricted.sh"

if [[ "$NO_AI" == "false" ]]; then
  section "5/5 AI stack (Ollama + OpenWebUI)"
  bash "$LAIA_DIR/config/ai/install-ai-stack.sh"
else
  section "5/5 Skipping AI stack (--no-ai)"
fi

if [[ "$NO_GUI" == "false" ]]; then
  log "Installing LAIA GUI tools..."
  bash "$LAIA_DIR/gui/laia-configurator/install.sh" 2>/dev/null || true
fi

section "Installation complete"
log "Run 'laia-config' to open the security configurator"
log "AI interface: http://localhost:3000"
log "Docs: https://github.com/laiadlotape/laia/tree/main/docs"
log ""
read -rp "Reboot now to apply all settings? [y/N]: " REBOOT
[[ "$REBOOT" =~ ^[Yy]$ ]] && reboot
