## ADDED Requirements

### Requirement: Dev-only directories excluded from Docker build context
The repository SHALL include a `.dockerignore` file at the root that excludes `openspec/` and other dev-only paths from the Docker build context, regardless of which directory is used as the build root.

#### Scenario: Local build from repo root excludes openspec
- **WHEN** `docker build -f unifi-poller/Dockerfile .` is run from the repository root
- **THEN** the `openspec/` directory SHALL NOT be present in the image layer or build context sent to the Docker daemon

#### Scenario: CI build unaffected
- **WHEN** the CI workflow builds with `context: unifi-poller`
- **THEN** the build SHALL succeed as before, with `.dockerignore` having no negative effect on the scoped context
