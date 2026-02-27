#!/bin/bash
# LAIA post-install hook (called during live-build chroot)
set -e

systemctl enable apparmor    2>/dev/null || true
systemctl enable fail2ban    2>/dev/null || true
systemctl enable unattended-upgrades 2>/dev/null || true

ufw default deny incoming
ufw default allow outgoing
ufw --force enable

mkdir -p /etc/laia
echo "LAIA_VERSION=1.0.0" > /etc/laia/version
echo "Post-install complete."
