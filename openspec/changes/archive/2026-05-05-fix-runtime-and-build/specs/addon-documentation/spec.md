## ADDED Requirements

### Requirement: CONTRIBUTING.md explains Docker build context exclusion
The `CONTRIBUTING.md` SHALL include an explanation that the `openspec/` directory is excluded from Docker images via `.dockerignore`, stating the reason (HA Supervisor scans subdirectories for `config.yaml` files and would attempt to parse `openspec/config.yaml` as an add-on manifest) and confirming that this has no effect on CI builds.

#### Scenario: Contributor understands why openspec is excluded
- **WHEN** a contributor reads the Local Build section of `CONTRIBUTING.md`
- **THEN** they SHALL find a note that `openspec/` is listed in `.dockerignore` and an explanation that this prevents the HA Supervisor from misidentifying it as an add-on
