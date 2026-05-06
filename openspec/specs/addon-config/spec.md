## ADDED Requirements

### Requirement: Valid HA add-on manifest
The add-on SHALL include a `config.yaml` at the root of the add-on directory that conforms to the Home Assistant Add-on Configuration specification.

#### Scenario: Supervisor validates manifest on install
- **WHEN** a user adds the repository and installs the add-on
- **THEN** the Supervisor SHALL parse `config.yaml` without errors and present the add-on in the store UI

### Requirement: Add-on metadata fields
The `config.yaml` SHALL declare `name`, `version`, `slug`, `description`, `arch`, `url`, `startup`, `boot`, `init`, and `homeassistant` fields with correct values. The `arch` field SHALL list both `amd64` and `aarch64`.

#### Scenario: Version string format
- **WHEN** the add-on `version` field is inspected
- **THEN** it SHALL match the pattern `<upstream_version>-<addon_revision>` (e.g., `2.9.0-1`)

#### Scenario: Architecture declaration
- **WHEN** the add-on is installed on an amd64 host
- **THEN** the Supervisor SHALL find `amd64` in the `arch` list and proceed with installation

#### Scenario: aarch64 host can install the add-on
- **WHEN** a user on a Home Assistant Green (aarch64) adds the repository and installs the add-on
- **THEN** the Supervisor SHALL find `aarch64` in the `arch` list and proceed with installation

### Requirement: Options schema with sensible defaults
The `config.yaml` SHALL declare an `options` block with default values and a `schema` block that validates user-supplied values before the add-on starts.

#### Scenario: Default options applied on first install
- **WHEN** a user installs the add-on without editing any options
- **THEN** the Supervisor SHALL populate options with the declared defaults and the add-on SHALL start without error

#### Scenario: Invalid option rejected by Supervisor
- **WHEN** a user enters a value that does not match the declared schema type (e.g., a string where an integer is expected)
- **THEN** the Supervisor SHALL reject the configuration and display a validation error before starting the add-on

### Requirement: Single controller only
The options schema SHALL support exactly one UniFi controller. Controller options SHALL be flat keys (`controller.url`, `controller.username`, `controller.password`, `controller.verify_ssl`) and SHALL NOT use an array or list structure.

#### Scenario: Only one controller configurable
- **WHEN** a user opens the add-on configuration in the Supervisor
- **THEN** they SHALL see a single set of controller fields with no ability to add additional controllers

### Requirement: Controller credentials as required options
The options schema SHALL mark UniFi controller `url`, `username`, and `password` as required fields with no defaults.

#### Scenario: Missing controller URL
- **WHEN** the user attempts to start the add-on with `controller.url` empty or absent
- **THEN** the add-on SHALL fail to start and log a clear error indicating the missing field

### Requirement: Exporter default state
The `config.yaml` options block SHALL default `influxdb.enabled` to `true` and `prometheus.enabled` to `false`, so a new install targets InfluxDB without requiring any Prometheus configuration.

#### Scenario: Default install targets InfluxDB only
- **WHEN** a user installs the add-on and does not change any exporter options
- **THEN** `influxdb.enabled` SHALL be `true` and `prometheus.enabled` SHALL be `false`

### Requirement: Exporter selection
The options schema SHALL allow the user to enable or disable the InfluxDB exporter and/or the Prometheus exporter independently.

#### Scenario: Only InfluxDB enabled
- **WHEN** `influxdb.enabled` is `true` and `prometheus.enabled` is `false`
- **THEN** the generated `up.conf` SHALL contain a valid `[influxdb]` section and no `[prometheus]` section

#### Scenario: Both exporters enabled
- **WHEN** both `influxdb.enabled` and `prometheus.enabled` are `true`
- **THEN** the generated `up.conf` SHALL contain both `[influxdb]` and `[prometheus]` sections

### Requirement: InfluxDB options use v1 field shape only
The InfluxDB options block SHALL expose only the fields required for InfluxDB 1.x: `url`, `db`, `username`, and `password`. No InfluxDB 2.x fields (`token`, `org`, `bucket`) SHALL be present in the schema.

#### Scenario: v1 fields present
- **WHEN** the user configures the InfluxDB exporter
- **THEN** the Supervisor config panel SHALL show `url`, `db`, `username`, and `password` fields and no others

#### Scenario: No v2 fields exposed
- **WHEN** the `config.yaml` schema is inspected
- **THEN** it SHALL contain no reference to `token`, `org`, or `bucket` fields

### Requirement: Image reference in manifest
The `config.yaml` SHALL reference the container image published to GitHub Container Registry using the `image` field, so the Supervisor pulls the pre-built image rather than building locally.

#### Scenario: Image pulled on install
- **WHEN** the add-on is installed
- **THEN** the Supervisor SHALL pull the image matching `ghcr.io/keirans/ha-addon-unifi-poller-{arch}:{version}` without requiring a local build

### Requirement: Repository manifest at repo root
The repository SHALL include a `repository.yaml` file at the root level so the Home Assistant Supervisor recognises it as a valid add-on repository when the user adds `https://github.com/keirans/unifipoller-ha` as a custom source.

#### Scenario: Supervisor accepts repository URL
- **WHEN** a user adds `https://github.com/keirans/unifipoller-ha` in the Supervisor Repositories dialog
- **THEN** the Supervisor SHALL fetch and validate `repository.yaml` and display the repository as a recognised source without error

#### Scenario: Add-on appears in store after repo added
- **WHEN** the repository has been added successfully
- **THEN** the UniFi Poller add-on SHALL appear in the Add-on Store, ready to install
