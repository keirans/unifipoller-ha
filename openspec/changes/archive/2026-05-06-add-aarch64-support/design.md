## Context

The add-on is currently amd64-only. The Dockerfile hardcodes `linux_amd64` in the binary download URL, and `config.yaml` lists only `amd64` in its `arch` field. The HA Supervisor uses the `{arch}` placeholder in the `image` field to select the correct pre-built image per architecture — so the convention for supporting multiple architectures is to publish one image per arch (`ha-addon-unifi-poller-amd64`, `ha-addon-unifi-poller-aarch64`) with the same tag, not a Docker multi-platform manifest.

UniFi Poller v2.39.0 publishes `linux_arm64` binaries on GitHub Releases, confirming the dependency is available.

## Goals / Non-Goals

**Goals:**
- Build and publish `ghcr.io/keirans/ha-addon-unifi-poller-aarch64:{version}` alongside the existing amd64 image
- Allow aarch64 HA hosts to install the add-on from the Supervisor
- Keep a single Dockerfile that handles both architectures

**Non-Goals:**
- armv7 or other ARM variants (binaries exist but out of scope for this change)
- Docker multi-platform manifests — HA uses per-arch image names, not manifests
- Any change to runtime behaviour, options schema, or exporters

## Decisions

**1. Single Dockerfile with `TARGETARCH` ARG**
Docker Buildx sets `TARGETARCH` automatically (`amd64` or `arm64`). A shell conditional maps this to the UniFi Poller binary filename suffix (`linux_amd64` or `linux_arm64`):

```dockerfile
ARG TARGETARCH=amd64
RUN case "${TARGETARCH}" in \
      amd64) UP_ARCH="linux_amd64" ;; \
      arm64) UP_ARCH="linux_arm64" ;; \
      *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac \
    && curl -fsSL "https://github.com/unpoller/unpoller/releases/download/v${UNPOLLER_VERSION}/unpoller_${UNPOLLER_VERSION}_${UP_ARCH}.tar.gz" \
       -o /tmp/unpoller.tar.gz \
    ...
```

Alternative considered: separate Dockerfiles per architecture — rejected because it duplicates all other layers and makes maintenance harder.

**2. Build matrix in CI rather than `--platform` cross-compilation**
The CI `build` job runs once per architecture using a matrix strategy (`[amd64, arm64]`), each producing its own image (`ha-addon-unifi-poller-amd64`, `ha-addon-unifi-poller-aarch64`). QEMU is set up via `docker/setup-qemu-action` to enable cross-compilation on GitHub's amd64 runners.

Alternative considered: single job with `platforms: linux/amd64,linux/arm64` — rejected because it pushes a multi-platform manifest, which the HA Supervisor does not use for image resolution.

**3. HA arch naming: `aarch64` in config.yaml, `arm64` in Docker**
The HA Supervisor uses `aarch64` as its architecture identifier (matching the kernel `uname -m` output on ARM64 hosts). Docker and Go use `arm64`. The image name follows the HA convention (`ha-addon-unifi-poller-aarch64`), while the Dockerfile uses `TARGETARCH=arm64` (Docker's value) to select the binary. The mapping is handled in the CI matrix.

## Risks / Trade-offs

- **QEMU cross-compilation on GitHub runners** → arm64 builds are slower than native. For a small binary-download Dockerfile this is acceptable; build times should remain under 5 minutes.
- **UniFi Poller arm64 binary quality** → the arm64 binary is published by upstream but may have less testing than amd64. Mitigation: document as officially supported and monitor for upstream issues.
- **`TARGETARCH` default value** → if someone runs `docker build` without Buildx (no `--platform` flag), `TARGETARCH` will not be set by Docker and falls back to the `ARG` default (`amd64`). This is the correct safe default.
