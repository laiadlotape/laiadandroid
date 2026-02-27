# LAIA Build System
DISTRO_NAME  := laia
VERSION      := 1.0.0
ARCH         := amd64
SUITE        := bookworm
OUTPUT_DIR   := build/output
ISO_NAME     := $(DISTRO_NAME)-$(VERSION)-$(ARCH).iso

.PHONY: all iso clean setup-deps test validate info iso-arm64

all: iso

## Install live-build and deps
setup-deps:
	@echo "Installing build dependencies..."
	sudo apt-get install -y live-build live-boot live-config \
	    squashfs-tools genisoimage syslinux isolinux
	@echo "Done."

## Validate config before build
validate:
	@bash scripts/validate-config.sh

## Build ISO
iso: validate
	@echo "Building LAIA $(VERSION) for $(ARCH)..."
	@mkdir -p $(OUTPUT_DIR)
	@chmod +x build/build-iso.sh
	@./build/build-iso.sh $(VERSION) $(ARCH) $(SUITE) $(OUTPUT_DIR)
	@echo "ISO ready: $(OUTPUT_DIR)/$(ISO_NAME)"

## Run tests in Docker (no ISO needed)
test:
	docker build -t laia-test -f tests/Dockerfile .
	docker run --rm laia-test bash tests/run-all.sh

## Clean build artifacts
clean:
	rm -rf $(OUTPUT_DIR) build/chroot build/binary build/cache
	@echo "Cleaned."

## Show config
info:
	@echo "Version:  $(VERSION)"
	@echo "Arch:     $(ARCH)"
	@echo "Base:     Debian $(SUITE)"
	@echo "Output:   $(OUTPUT_DIR)/$(ISO_NAME)"

iso-arm64:
	ARCH=arm64 $(MAKE) iso
