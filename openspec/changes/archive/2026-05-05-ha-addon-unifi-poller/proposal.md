## Why

Home Assistant users running UniFi networks have no native way to monitor their network devices within Home Assistant. This add-on packages UniFi Poller as a supervised Home Assistant add-on, enabling users to stream UniFi controller metrics to InfluxDB or Prometheus without maintaining a separate service or container outside of Home Assistant.

## What Changes

- New Home Assistant add-on repository structure following the official HA add-on specification
- `config.yaml` defining add-on metadata, options schema, and architecture support
- `Dockerfile` building from `ghcr.io/home-assistant/base:latest`, downloading the UniFi Poller binary from GitHub releases
- `run.sh` entrypoint script that reads HA options via `bashio`, generates `up.conf` at runtime, and launches `unpoller`
- `options.json` / `schema.json` defining the user-facing configuration surface (controller URL, credentials, InfluxDB/Prometheus endpoints, polling interval)
- GitHub Actions CI pipeline to validate JSON/YAML, build the Docker image, and publish to GitHub Container Registry
- `DOCS.md` and `README.md` for the add-on store listing and user documentation

## Capabilities

### New Capabilities

- `addon-config`: Defines the HA add-on manifest (`config.yaml`) — metadata, versioning, options schema, architecture declarations, and ingress/network settings
- `container-build`: Dockerfile and build pipeline that downloads the UniFi Poller Go binary and produces a minimal, multi-arch-ready container image
- `runtime-entrypoint`: Bash entrypoint (`run.sh`) that translates HA Supervisor options (via `bashio`) into a valid `up.conf` and starts the poller process
- `ci-cd-pipeline`: GitHub Actions workflow to lint, build, and publish the add-on image on push and release events
- `addon-documentation`: User-facing `DOCS.md` and repository `README.md` covering installation, configuration options, and integration examples

### Modified Capabilities

## Impact

- New top-level directory `unifi-poller/` in the repository acting as the add-on root
- No changes to existing code (this is a greenfield add-on)
- Depends on the UniFi Poller binary release artifacts from `github.com/unpoller/unpoller`
- Docker image published to `ghcr.io/<owner>/ha-addon-unifi-poller`
- Requires a reachable UniFi Network Controller and at least one configured exporter (InfluxDB or Prometheus)
