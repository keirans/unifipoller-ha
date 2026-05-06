## MODIFIED Requirements

### Requirement: Architecture tables reflect aarch64 as officially supported
Both `DOCS.md` and `README.md` SHALL update their architecture support tables to show `aarch64` as officially supported, removing any "planned" or provisional status.

#### Scenario: aarch64 shown as supported in DOCS.md
- **WHEN** a user on an aarch64 device reads `DOCS.md`
- **THEN** they SHALL see `aarch64` listed as officially supported with no caveats

#### Scenario: aarch64 shown as supported in README.md
- **WHEN** a prospective user browses the repository on GitHub
- **THEN** the README architecture table SHALL show both `amd64` and `aarch64` as supported
