## ADDED Requirements

### Requirement: Read options via bashio
The `run.sh` script SHALL use `bashio::config` to read all add-on options and SHALL NOT read environment variables or files outside the Supervisor-provided options store directly.

#### Scenario: Options available at runtime
- **WHEN** the add-on starts
- **THEN** `bashio::config 'controller.url'` SHALL return the value the user configured in the Supervisor UI

### Requirement: Generate up.conf before launching unpoller
The `run.sh` script SHALL generate a valid `up.conf` TOML file at `/etc/unpoller/up.conf` from the resolved options before executing `unpoller`.

#### Scenario: Config file written before exec
- **WHEN** `run.sh` runs
- **THEN** `/etc/unpoller/up.conf` SHALL exist and contain the controller URL, credentials, and enabled exporter sections before `unpoller` is exec'd

### Requirement: Controller section always written
The `run.sh` script SHALL write a `[unifi]` section in `up.conf` containing `url`, `user`, `pass`, and `verify_ssl` from the options.

#### Scenario: Controller block present in generated config
- **WHEN** the add-on starts with valid controller options
- **THEN** `up.conf` SHALL contain a `[unifi.defaults]` (or equivalent) block with the configured URL and credentials

### Requirement: Conditional exporter sections
The `run.sh` script SHALL only write an exporter section (`[influxdb]` or `[prometheus]`) when the corresponding `enabled` option is `true`.

#### Scenario: Disabled exporter omitted
- **WHEN** `prometheus.enabled` is `false`
- **THEN** `up.conf` SHALL NOT contain a `[prometheus]` section

#### Scenario: Enabled exporter included
- **WHEN** `influxdb.enabled` is `true`
- **THEN** `up.conf` SHALL contain an `[influxdb]` section with `url`, `db`, `user`, and `pass` from options

### Requirement: Fail fast if no exporter is enabled
The `run.sh` script SHALL check that at least one exporter is enabled before generating `up.conf`. If both `influxdb.enabled` and `prometheus.enabled` are `false`, the script SHALL log a clear error and exit with a non-zero status.

#### Scenario: Both exporters disabled
- **WHEN** both `influxdb.enabled` and `prometheus.enabled` are `false`
- **THEN** `run.sh` SHALL log an error message explaining that at least one exporter must be enabled, and SHALL exit without writing `up.conf` or launching `unpoller`

### Requirement: Fail fast on missing required options
The `run.sh` script SHALL use `bashio::config.required` (or equivalent guard) for controller `url`, `username`, and `password`, exiting with a non-zero status and a log message if any are absent.

#### Scenario: Missing password causes clean failure
- **WHEN** `controller.password` is empty or not set
- **THEN** `run.sh` SHALL log an error via `bashio::log.error` and exit before writing any config or launching `unpoller`

### Requirement: Exec unpoller without forking
The `run.sh` script SHALL use `exec unpoller` (not a subshell or background process) so that s6-overlay can manage the process lifecycle correctly.

#### Scenario: unpoller is PID 1 substitute
- **WHEN** `run.sh` completes successfully
- **THEN** the `unpoller` process SHALL replace the shell process and be directly supervised by s6

### Requirement: Log level configurable
The `run.sh` script SHALL pass a `--debug` flag to `unpoller` when the `log_level` option is set to `debug`.

#### Scenario: Debug logging enabled
- **WHEN** `log_level` is `debug`
- **THEN** `unpoller` SHALL be started with the debug flag and emit verbose output to the HA log
