## ADDED Requirements

### Requirement: Lint workflow validates JSON and YAML
The CI pipeline SHALL include a lint job that runs `jq` on all `*.json` files and `yq` on all `*.yaml`/`*.yml` files in the add-on directory, failing the workflow if any file is malformed.

#### Scenario: Invalid JSON fails CI
- **WHEN** a pull request introduces a syntactically invalid JSON file
- **THEN** the lint job SHALL fail and block the PR from merging

#### Scenario: Valid files pass lint
- **WHEN** all JSON and YAML files are well-formed
- **THEN** the lint job SHALL exit with code 0

### Requirement: Build job runs after lint passes
The Docker build job SHALL depend on the lint job completing successfully before it runs.

#### Scenario: Build skipped on lint failure
- **WHEN** the lint job fails
- **THEN** the build job SHALL not start

### Requirement: Image built and pushed on main branch push
The CI pipeline SHALL build and push the Docker image to GitHub Container Registry when a commit is pushed to the `main` branch.

#### Scenario: Image tagged as latest on main push
- **WHEN** a commit is pushed to `main`
- **THEN** the image SHALL be pushed with the `amd64-latest` tag

### Requirement: Image tagged with version on release
The CI pipeline SHALL build and push the Docker image with the version tag when a GitHub Release is published.

#### Scenario: Release tag matches config.yaml version
- **WHEN** a GitHub Release with tag `v2.9.0-1` is published
- **THEN** the image SHALL be pushed with the tag `amd64-2.9.0-1`

### Requirement: GHCR authentication via GITHUB_TOKEN
The CI pipeline SHALL authenticate to GitHub Container Registry using the automatically-provided `GITHUB_TOKEN` secret, requiring no manually-managed credentials.

#### Scenario: Push succeeds without manual secrets
- **WHEN** the build-and-push job runs in a GitHub Actions context
- **THEN** it SHALL authenticate to `ghcr.io` using `secrets.GITHUB_TOKEN` and push successfully

### Requirement: Workflow triggered on pull requests for validation only
The CI pipeline SHALL run the lint and build jobs on pull requests targeting `main`, but SHALL NOT push the image.

#### Scenario: PR build does not pollute registry
- **WHEN** a pull request is opened or updated
- **THEN** the image is built but not pushed to the registry

### Requirement: Build matrix covers amd64 and aarch64
The CI build job SHALL use a matrix strategy with both `amd64` and `aarch64` entries, producing one image per architecture on every run. QEMU SHALL be set up via `docker/setup-qemu-action` to enable cross-compilation on GitHub's amd64 runners.

#### Scenario: aarch64 image built alongside amd64 on every push
- **WHEN** a commit is pushed to `main`
- **THEN** the build job SHALL run twice — once for `amd64` and once for `aarch64` — and push both images to GHCR

#### Scenario: Both images built (not pushed) on pull requests
- **WHEN** a pull request is opened or updated
- **THEN** both `amd64` and `aarch64` builds SHALL run without pushing to the registry

#### Scenario: QEMU enables arm64 cross-compilation
- **WHEN** the `aarch64` matrix entry runs on a GitHub-hosted amd64 runner
- **THEN** `docker/setup-qemu-action` SHALL be invoked before the build step so that arm64 emulation is available

### Requirement: CI matrix maps HA arch names to Docker TARGETARCH values
The CI matrix SHALL define both the HA architecture name (e.g., `aarch64`) used in the image name and the Docker `TARGETARCH` value (e.g., `arm64`) used by Buildx and the Dockerfile. These SHALL be passed as separate matrix fields.

#### Scenario: aarch64 image uses arm64 TARGETARCH
- **WHEN** the matrix entry for `aarch64` runs
- **THEN** the Docker build SHALL be invoked with `--build-arg TARGETARCH=arm64` and the image SHALL be tagged `ha-addon-unifi-poller-aarch64`

#### Scenario: amd64 image uses amd64 TARGETARCH
- **WHEN** the matrix entry for `amd64` runs
- **THEN** the Docker build SHALL be invoked with `--build-arg TARGETARCH=amd64` and the image SHALL be tagged `ha-addon-unifi-poller-amd64`

### Requirement: Per-arch images tagged with version on release
The release workflow SHALL build and push both `ha-addon-unifi-poller-amd64:{version}` and `ha-addon-unifi-poller-aarch64:{version}` when a GitHub Release is published, using the same matrix strategy as the CI build job.

#### Scenario: Release publishes both arch images
- **WHEN** a GitHub Release with tag `v2.29.0-1` is published
- **THEN** both `ghcr.io/keirans/ha-addon-unifi-poller-amd64:2.29.0-1` and `ghcr.io/keirans/ha-addon-unifi-poller-aarch64:2.29.0-1` SHALL be pushed to GHCR
