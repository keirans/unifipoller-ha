## ADDED Requirements

### Requirement: HA base image
The Dockerfile SHALL use `ghcr.io/home-assistant/base:latest` as the `FROM` instruction to ensure `bashio` and s6-overlay are available.

#### Scenario: Image builds successfully
- **WHEN** `docker build` is run against the Dockerfile
- **THEN** the build SHALL complete without error and produce an image containing the `unpoller` binary and `run.sh`

### Requirement: Pinned upstream binary download
The Dockerfile SHALL download the UniFi Poller binary from the official GitHub releases for a version pinned via a build ARG (`UNPOLLER_VERSION`).

#### Scenario: Binary present at expected path
- **WHEN** the container image is built
- **THEN** the `unpoller` binary SHALL be present at `/usr/bin/unpoller` and be executable

#### Scenario: Version override at build time
- **WHEN** `docker build --build-arg UNPOLLER_VERSION=2.10.0` is invoked
- **THEN** the resulting image SHALL contain the `2.10.0` binary

### Requirement: Minimal image footprint
The Dockerfile SHALL remove any temporary files (downloaded archives, checksum files) created during the binary installation step.

#### Scenario: No leftover build artifacts
- **WHEN** the final image layer is inspected
- **THEN** no `.tar.gz` or intermediate download files SHALL be present

### Requirement: run.sh copied into image
The Dockerfile SHALL copy `run.sh` into the image and mark it executable, placing it at the path registered in `config.yaml` as the add-on entrypoint.

#### Scenario: Entrypoint runs on container start
- **WHEN** the container is started
- **THEN** `run.sh` SHALL execute and pass control to `unpoller`

### Requirement: Image tagged with version and architecture
The built and published image SHALL be tagged with the pattern `{arch}-{version}` (e.g., `amd64-2.9.0-1`) as required by the HA Supervisor image resolution.

#### Scenario: Supervisor resolves correct image tag
- **WHEN** the Supervisor installs the add-on on an amd64 host at version `2.9.0-1`
- **THEN** it SHALL pull the tag `amd64-2.9.0-1` from the registry
