## MODIFIED Requirements

### Requirement: Pinned upstream binary download
The Dockerfile SHALL use `ARG TARGETARCH` to select the correct UniFi Poller binary for the target architecture at build time. A shell `case` statement SHALL map Docker's `TARGETARCH` value (`amd64`, `arm64`) to the corresponding UniFi Poller release filename suffix (`linux_amd64`, `linux_arm64`). Unsupported architectures SHALL cause the build to fail with an explicit error message.

#### Scenario: Binary present at expected path
- **WHEN** the container image is built for any supported architecture
- **THEN** the `unpoller` binary SHALL be present at `/usr/bin/unpoller` and be executable

#### Scenario: aarch64 binary downloaded for arm64 target
- **WHEN** the image is built with `--platform linux/arm64` or `TARGETARCH=arm64`
- **THEN** the `linux_arm64` release asset SHALL be downloaded from the UniFi Poller GitHub releases

#### Scenario: Unsupported architecture fails fast
- **WHEN** the image is built with an unsupported `TARGETARCH` value
- **THEN** the build SHALL exit with a non-zero status and a message identifying the unsupported architecture

#### Scenario: Version override at build time
- **WHEN** `docker build --build-arg UNPOLLER_VERSION=2.10.0` is invoked
- **THEN** the resulting image SHALL contain the `2.10.0` binary for the target architecture

### Requirement: Image tagged with version and architecture
The built and published image SHALL be tagged with the add-on version as the tag, with the architecture encoded in the image name following the HA Supervisor naming convention (`ha-addon-unifi-poller-amd64`, `ha-addon-unifi-poller-aarch64`).

#### Scenario: Supervisor resolves correct image for aarch64
- **WHEN** the Supervisor installs the add-on on an aarch64 host at version `2.29.0-1`
- **THEN** it SHALL pull `ghcr.io/keirans/ha-addon-unifi-poller-aarch64:2.29.0-1`

#### Scenario: Supervisor resolves correct image for amd64
- **WHEN** the Supervisor installs the add-on on an amd64 host at version `2.29.0-1`
- **THEN** it SHALL pull `ghcr.io/keirans/ha-addon-unifi-poller-amd64:2.29.0-1`
