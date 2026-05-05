## Context

Three issues identified affecting runtime correctness and build hygiene:

1. **Log level branching**: The script forks into two separate `exec` paths — one with `--debug` and one without — to handle the log level. This is fragile: adding any future flag requires duplicating the exec line again, and the pattern invites subtle divergence between branches.

2. **Prometheus not disabled**: When `prometheus.enabled` is `false`, the `[prometheus]` section is simply omitted from `up.conf`. UniFi Poller defaults to starting its Prometheus listener on `:9130` even when the section is absent, so the listener starts regardless of user intent and appears in logs as running.

3. **Unguarded Docker build context**: The CI workflows correctly set `context: unifi-poller`, so `openspec/` is already outside the build context for CI builds. However, local builds using `docker build -f unifi-poller/Dockerfile .` and any HA builder tooling that uses the repo root as context would include `openspec/` in the image. A `.dockerignore` at the repo root closes this gap unconditionally.

## Goals / Non-Goals

**Goals:**
- Single `exec` path for launching `unpoller`, with arguments built cleanly before the exec
- Prometheus listener positively disabled in `up.conf` when `prometheus.enabled` is `false`
- Dev-only directories excluded from all Docker build contexts via `.dockerignore`

**Non-Goals:**
- Changing any other `run.sh` behaviour
- Modifying `config.yaml` or the Dockerfile itself
- Restructuring the repository layout

## Decisions

**1. Bash array for command arguments**
Replace the dual-`exec` pattern with a single Bash array (`ARGS`) that is populated conditionally before the final `exec`. This keeps one execution path and makes it trivial to add future flags without duplication.

```bash
ARGS=(--config /etc/unpoller/up.conf)
[ "${LOG_LEVEL}" = "debug" ] && ARGS+=(--debug)
exec /usr/bin/unpoller "${ARGS[@]}"
```

Alternative considered: keeping two `exec` branches but adding a comment — rejected because it compounds with every new flag added.

**2. Explicit `disable = true` in `[prometheus]` when disabled**
Write a `[prometheus]` section with `disable = true` unconditionally, regardless of `prometheus.enabled`. This overrides UniFi Poller's default behaviour of starting the listener when no section is present.

```toml
[prometheus]
  disable        = true
```

When enabled, the full section is written instead (with `http_listen` and `report_errors`).

Alternative considered: relying on omitting the section — rejected because this is the bug itself; UniFi Poller defaults to enabled.

**3. `.dockerignore` at the repo root**
A single `.dockerignore` at the repository root excludes `openspec/`, `.github/`, `CONTRIBUTING.md`, and other dev-only paths. This guards all build invocations regardless of which tool or command is used, without requiring changes to any Dockerfile or workflow.

Alternative considered: CI step that deletes `openspec/` before building — rejected because CI context is already scoped to `unifi-poller/` and the problem is local/fallback builds, not CI. A `.dockerignore` is the idiomatic, permanent solution.

Alternative considered: renaming `openspec/config.yaml` to a non-YAML extension in the repo — rejected as it would break OpenSpec CLI tooling and addresses only one file rather than the whole directory.
