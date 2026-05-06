## 1. Dockerfile

- [x] 1.1 Add `ARG TARGETARCH=amd64` before the `RUN` instruction that downloads the binary
- [x] 1.2 Replace the hardcoded `linux_amd64` suffix with a `case "${TARGETARCH}"` statement that maps `amd64` → `linux_amd64`, `arm64` → `linux_arm64`, and fails with an explicit error for unsupported architectures
- [x] 1.3 Update the default `ARG UNPOLLER_VERSION` to `2.29.0` to match the current `config.yaml` version

## 2. Add-on config

- [x] 2.1 Add `aarch64` to the `arch` list in `unifi-poller/config.yaml`

## 3. CI workflow

- [x] 3.1 Add `docker/setup-qemu-action` step to the build job in `.github/workflows/ci.yaml`, before the Docker build step
- [x] 3.2 Convert the build job to a matrix strategy with entries for `amd64` (TARGETARCH=amd64) and `aarch64` (TARGETARCH=arm64)
- [x] 3.3 Update image name references in ci.yaml to use the matrix arch value (`ha-addon-unifi-poller-${{ matrix.ha_arch }}`)
- [x] 3.4 Pass `--build-arg TARGETARCH=${{ matrix.docker_arch }}` to the Docker build command

## 4. Release workflow

- [x] 4.1 Add `docker/setup-qemu-action` step to the release job in `.github/workflows/release.yaml`
- [x] 4.2 Apply the same matrix strategy (amd64 + aarch64) to the release build job
- [x] 4.3 Update image name and build-arg references in release.yaml to match the matrix values

## 5. Documentation

- [x] 5.1 Update the architecture table in `unifi-poller/DOCS.md` to show `aarch64` as officially supported (remove "planned" status)
- [x] 5.2 Update the architecture table in `README.md` to show `aarch64` as officially supported
