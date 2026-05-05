## MODIFIED Requirements

### Requirement: Conditional exporter sections
The `run.sh` script SHALL always write a `[prometheus]` section to `up.conf`. When `prometheus.enabled` is `true`, the section SHALL contain `http_listen` and `report_errors`. When `prometheus.enabled` is `false`, the section SHALL contain `disable = true` to prevent UniFi Poller from starting its listener by default.

#### Scenario: Disabled exporter explicitly turned off
- **WHEN** `prometheus.enabled` is `false`
- **THEN** `up.conf` SHALL contain a `[prometheus]` section with `disable = true`

#### Scenario: Enabled exporter included
- **WHEN** `influxdb.enabled` is `true`
- **THEN** `up.conf` SHALL contain an `[influxdb]` section with `url`, `db`, `user`, and `pass` from options

#### Scenario: Prometheus listener does not start when disabled
- **WHEN** `prometheus.enabled` is `false` and the add-on starts
- **THEN** no Prometheus metrics endpoint SHALL be accessible and the add-on log SHALL not report Prometheus as running

### Requirement: Log level configurable
The `run.sh` script SHALL build a Bash argument array before invoking `unpoller` and SHALL append `--debug` to that array when `log_level` is `debug`. The final `exec` SHALL use this array, ensuring a single execution path regardless of log level.

#### Scenario: Debug logging enabled
- **WHEN** `log_level` is `debug`
- **THEN** `unpoller` SHALL be started with the `--debug` flag and emit verbose output to the HA log

#### Scenario: Non-debug log level produces single exec path
- **WHEN** `log_level` is any value other than `debug`
- **THEN** `unpoller` SHALL be started without `--debug` via the same `exec` statement used for debug mode
