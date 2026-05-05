## Context

UniFi Poller is a standalone Go binary that polls a UniFi Network Controller and exports metrics to InfluxDB or Prometheus. Home Assistant users who run a UniFi network currently must run this binary as a separate system service or Docker container outside of HA, with no supervised lifecycle management.

This design packages UniFi Poller as a Home Assistant Add-on (supervised app), so it runs under the HA Supervisor alongside other add-ons with a consistent installation, configuration, and update experience.

The add-on is a thin wrapper: it downloads the upstream UniFi Poller binary, translates HA Supervisor options into a `up.conf` file at runtime, and launches the binary. No Go code is authored; all logic is in Bash.

## Goals / Non-Goals

**Goals:**
- Package UniFi Poller as a compliant HA add-on with a valid `config.yaml`
- Let users configure controller URL, credentials, exporters (InfluxDB/Prometheus), and polling interval through the HA Supervisor UI
- Publish a container image to GitHub Container Registry on each release
- Validate configuration and fail fast with readable error messages
- Provide user documentation in the add-on store format

**Non-Goals:**
- Native HA integration (no entities, no states, no `manifest.json` for `custom_components`)
- Building UniFi Poller from source — we use the upstream published binary
- Multi-architecture support in v1 (amd64 only; arm64 is a future addition)
- Ingress / HA UI proxy for any UniFi Poller web interface
- Bundling InfluxDB or Prometheus — users point to external or separately-hosted instances
- Multiple UniFi controllers — only a single controller is supported in v1; the options schema uses flat keys, not arrays

## Decisions

**1. Base image: `ghcr.io/home-assistant/base:latest`**
Chosen over a raw Alpine or Debian image because it is the HA-endorsed base, includes `bashio` and `s6-overlay` pre-installed, and ensures compatibility with the Supervisor's expectations for add-on containers.
Alternative considered: `alpine:latest` — rejected because it requires manually installing `bashio` and s6, increasing maintenance burden and risk of version drift.

**2. Download binary at Docker build time, pinned to a specific upstream version**
The Dockerfile fetches the UniFi Poller binary from the GitHub releases API during `docker build`, pinning the exact version. The add-on version string tracks the upstream version plus an add-on revision suffix (e.g., `2.9.0-1`).
Alternative considered: Building from source inside the Dockerfile — rejected because it requires a Go toolchain in the image, significantly increases image size and build time, and adds no value since upstream publishes pre-built amd64 binaries.

**3. Runtime config generation via `run.sh` + `bashio`**
The `run.sh` entrypoint reads all options using `bashio::config` calls and writes a `up.conf` (TOML) file before exec'ing the `unpoller` binary. This is the idiomatic HA add-on pattern and avoids encoding HA-specific logic into any config template files that users might try to edit directly.
Alternative considered: Mounting a user-supplied config file — rejected because the HA options schema (validated by the Supervisor) is the source of truth; allowing a raw config file would bypass validation.

**4. Options schema: flat, opinionated defaults; single controller**
The `config.yaml` options schema exposes the most commonly needed UniFi Poller settings (controller URL/user/pass, InfluxDB URL/database, Prometheus port, polling interval) as flat top-level keys with sensible defaults. Advanced TOML overrides are out of scope for v1. Only a single controller is supported — the schema uses flat `controller.*` keys rather than an array, making configuration straightforward and validation unambiguous.
Alternative considered: Exposing the full `up.conf` as a raw text field — rejected because it bypasses the Supervisor's options validation and makes the UI unusable for most users.

**6. Default exporter state: InfluxDB enabled, Prometheus disabled**
InfluxDB 1.8.x is the primary officially-supported target, so `influxdb.enabled` defaults to `true` and `prometheus.enabled` defaults to `false`. This means a new install works with just controller credentials and an InfluxDB URL, with no Prometheus configuration required. Users who want Prometheus (or both) opt in explicitly.

Both exporters may be enabled simultaneously. They use fundamentally different data delivery models — InfluxDB is push (UniFi Poller writes on each poll interval) and Prometheus is pull (Prometheus scrapes an exposed `/metrics` endpoint). Running both is valid but carries resource implications: two metric stores, two retention policies, and an open port for Prometheus scraping. These are documented explicitly in `DOCS.md`.

If both exporters are disabled, `run.sh` SHALL fail fast with a clear error rather than starting an add-on that silently exports nothing.

**5. CI/CD: GitHub Actions with `docker/build-push-action`**
Builds the image on push to `main` and on version tags. Tags are pushed to `ghcr.io`. JSON/YAML linting runs before the build step.
Alternative considered: Building locally and pushing manually — rejected as it is not reproducible and does not scale.

## Risks / Trade-offs

- **Upstream binary availability** → If the UniFi Poller GitHub release asset URL changes format, the build breaks. Mitigation: pin the full release URL in the Dockerfile ARG and update via dependabot or a manual PR when upgrading.
- **HA Supervisor API changes** → `bashio` is updated independently of the base image. Mitigation: pin `bashio` version in build or rely on the base image's bundled version.
- **UniFi controller API compatibility** → UniFi Poller has known compatibility constraints with specific controller firmware versions. Mitigation: document supported controller versions in `DOCS.md`; this is an upstream concern, not the add-on's to solve.
- **amd64-only in v1** → Users on Raspberry Pi (arm64) cannot use the add-on. Mitigation: clearly document architecture support; add arm64 in a follow-up change once binary availability is confirmed.
- **Credentials stored in HA options** → Controller username/password are stored in HA's options store (encrypted at rest by the Supervisor, but readable via the API by any add-on). Mitigation: document this in `DOCS.md` and recommend using a read-only controller account.

## Migration Plan

Greenfield add-on — no migration required. Installation is via the HA Add-on Store after adding the repository URL.

## Open Questions

- Is a `CHANGELOG.md` required by the add-on store, or is the GitHub releases page sufficient?

---

## Resolved Decisions

**InfluxDB version support**
Only InfluxDB 1.x is supported. InfluxDB 1.8.x is the officially tested and supported target. Versions 1.10 and 1.11 are expected to work but are community-supported only (not tested by maintainers). InfluxDB 2.x is not supported — its API and authentication model (`token`/`org`/`bucket`) differ entirely from v1 and UniFi Poller treats them as separate exporters.

The options schema exposes only v1 fields: `url`, `db`, `username`, `password`. No v2 fields (`token`, `org`, `bucket`) are exposed. The `run.sh` writes only the `[influxdb]` TOML section (v1), never `[influxdb2]`.

**Prometheus version support**
Prometheus 2.x is required. No other Prometheus-compatible endpoints (e.g., VictoriaMetrics, Thanos) are officially supported.

**Loki**
Not supported in this release. UniFi Poller does not natively export to Loki; this is out of scope.
