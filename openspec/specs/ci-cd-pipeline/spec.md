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
