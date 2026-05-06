## MODIFIED Requirements

### Requirement: Architecture list includes aarch64
The `config.yaml` `arch` field SHALL list both `amd64` and `aarch64`, allowing the Supervisor to install the add-on on both x86-64 and ARM64 hosts.

#### Scenario: aarch64 host can install the add-on
- **WHEN** a user on a Home Assistant Green (aarch64) adds the repository and installs the add-on
- **THEN** the Supervisor SHALL find `aarch64` in the `arch` list and proceed with installation

#### Scenario: amd64 host installation unaffected
- **WHEN** a user on an amd64 host installs the add-on
- **THEN** the Supervisor SHALL continue to find `amd64` in the `arch` list and install normally
