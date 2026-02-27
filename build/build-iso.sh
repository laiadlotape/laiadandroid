#!/usr/bin/env bash
# LAIA ISO Builder using live-build
# Usage: ./build-iso.sh VERSION ARCH SUITE OUTPUT_DIR
set -euo pipefail

VERSION="${1:-1.0.0}"
ARCH="${2:-amd64}"
SUITE="${3:-bookworm}"
OUTPUT_DIR="${4:-build/output}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== LAIA ISO Builder v${VERSION} (${ARCH} / Debian ${SUITE}) ==="

WORKDIR=$(mktemp -d /tmp/laia-build-XXXXXX)
trap "rm -rf $WORKDIR" EXIT
cd "$WORKDIR"

lb config \
    --distribution "$SUITE" \
    --architectures "$ARCH" \
    --debian-installer live \
    --debian-installer-gui true \
    --binary-image iso-hybrid \
    --iso-volume "LAIA ${VERSION}" \
    --iso-application "LAIA Linux" \
    --apt-recommends false \
    --memtest none

mkdir -p config/package-lists
grep -v '^#' "$PROJECT_ROOT/config/packages/base.list" | \
    grep -v '^$' > config/package-lists/laia-base.list.chroot

mkdir -p config/hooks/normal
cp "$PROJECT_ROOT/scripts/post-install.sh" \
    config/hooks/normal/0100-laia-setup.hook.chroot

mkdir -p config/includes.chroot/etc/laia
cp -r "$PROJECT_ROOT/config/security" \
    config/includes.chroot/etc/laia/ 2>/dev/null || true
cp -r "$PROJECT_ROOT/config/openclaw" \
    config/includes.chroot/etc/laia/ 2>/dev/null || true
cp -r "$PROJECT_ROOT/config/ai" \
    config/includes.chroot/etc/laia/ 2>/dev/null || true

mkdir -p config/includes.chroot/usr/local/lib/laia
cp -r "$PROJECT_ROOT/gui" \
    config/includes.chroot/usr/local/lib/laia/ 2>/dev/null || true

lb build

mkdir -p "$OUTPUT_DIR"
mv live-image-*.iso "$OUTPUT_DIR/laia-${VERSION}-${ARCH}.iso" 2>/dev/null || \
mv *.iso "$OUTPUT_DIR/laia-${VERSION}-${ARCH}.iso"

echo "ISO ready: $OUTPUT_DIR/laia-${VERSION}-${ARCH}.iso"
