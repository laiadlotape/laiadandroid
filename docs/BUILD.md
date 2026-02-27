# Building LAIA from Source

## Prerequisites

- Debian Bookworm or Ubuntu 22.04+ host
- 20 GB free disk space
- Root access (for live-build)

## Quick Build

```bash
make setup-deps   # install live-build (once)
make iso          # build amd64 ISO
make iso-arm64    # build arm64 variant
make test         # run integration tests in Docker
make clean        # remove build artifacts
```

## Build Variables

```bash
VERSION=1.1.0 ARCH=arm64 make iso
```

| Variable | Default | Description |
|----------|---------|-------------|
| `VERSION` | 1.0.0 | Version string embedded in ISO |
| `ARCH` | amd64 | Target: `amd64` or `arm64` |
| `SUITE` | bookworm | Debian release |

## Testing Without an ISO

All tests run in Docker — no hardware needed:

```bash
make test
```

Or directly:
```bash
docker build -t laia-test -f tests/Dockerfile .
docker run --rm laia-test bash tests/run-all.sh
```
