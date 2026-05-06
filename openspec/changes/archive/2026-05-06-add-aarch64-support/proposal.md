## Why

The add-on currently only supports amd64, excluding users running Home Assistant on arm64 hardware — including the Home Assistant Green, Raspberry Pi 4/5, and other ARM-based hosts. UniFi Poller publishes official `linux_arm64` binaries alongside amd64, so support can be added without building from source.

## What Changes

- `unifi-poller/config.yaml`: Add `aarch64` to the `arch` list
- `unifi-poller/Dockerfile`: Use `ARG TARGETARCH` to select the correct UniFi Poller binary (`linux_amd64` or `linux_arm64`) at build time
- `.github/workflows/ci.yaml`: Add aarch64 to the build matrix; configure `docker/setup-qemu-action` for cross-platform builds
- `.github/workflows/release.yaml`: Build and push `ghcr.io/keirans/ha-addon-unifi-poller-aarch64:{version}` alongside the existing amd64 image
- `unifi-poller/DOCS.md`: Update the architecture support table to mark aarch64 as supported
- `README.md`: Update the architecture table

## Capabilities

### New Capabilities

### Modified Capabilities

- `container-build`: Dockerfile must select the correct binary for the target architecture; image must be built and published per-architecture following the HA naming convention
- `ci-cd-pipeline`: CI must build for both amd64 and aarch64 on every push and release
- `addon-config`: `arch` list in `config.yaml` must include `aarch64`
- `addon-documentation`: Architecture support tables must reflect aarch64 as officially supported

## Impact

- `unifi-poller/config.yaml`
- `unifi-poller/Dockerfile`
- `.github/workflows/ci.yaml`
- `.github/workflows/release.yaml`
- `unifi-poller/DOCS.md`
- `README.md`
- New image published: `ghcr.io/keirans/ha-addon-unifi-poller-aarch64`
- No changes to `run.sh`, options schema, or exporters — runtime behaviour is identical across architectures
