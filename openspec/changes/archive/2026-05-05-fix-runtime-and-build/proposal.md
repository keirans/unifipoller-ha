## Why

Three bugs affect runtime correctness and build hygiene: the log level in `run.sh` is handled via branching `exec` paths, disabling the Prometheus exporter has no effect because UniFi Poller starts its listener by default when no config section is present, and the Docker build context is unguarded against dev-only files (specifically `openspec/`) being included in images built outside of CI.

## What Changes

- `run.sh`: Replace the dual-`exec` log level pattern with a single `exec` that passes the correct flag based on the validated `log_level` option
- `run.sh`: When `prometheus.enabled` is `false`, write an explicit `[prometheus]` section containing `disable = true` rather than omitting the section, so UniFi Poller does not start its listener
- `.dockerignore`: Add a repo-root `.dockerignore` excluding `openspec/` and other dev-only paths so local and fallback builds cannot include them in the image
- `CONTRIBUTING.md`: Document why `openspec/` is excluded from Docker builds

## Capabilities

### New Capabilities

### Modified Capabilities

- `runtime-entrypoint`: Requirements for log level handling and Prometheus disable behaviour are changing
- `container-build`: Requirement added that dev-only directories are excluded from the Docker build context via `.dockerignore`
- `addon-documentation`: `CONTRIBUTING.md` must explain the `.dockerignore` exclusion and its rationale

## Impact

- `unifi-poller/run.sh`
- `.dockerignore` (new file at repo root)
- `CONTRIBUTING.md` (documentation update)
- Users with `prometheus.enabled: false` will see the Prometheus listener stop appearing in logs after the fix
- Local `docker build` invocations from the repo root will no longer include `openspec/` in the image
