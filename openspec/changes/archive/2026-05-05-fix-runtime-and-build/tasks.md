## 1. Fix Log Level Handling

- [x] 1.1 Replace the dual-`exec` log level branches with a single Bash `ARGS` array initialised to `(--config /etc/unpoller/up.conf)`
- [x] 1.2 Append `--debug` to `ARGS` when `LOG_LEVEL` equals `debug`
- [x] 1.3 Replace both `exec` calls with a single `exec /usr/bin/unpoller "${ARGS[@]}"`

## 2. Fix Prometheus Disable Behaviour

- [x] 2.1 When `prometheus.enabled` is `false`, write a `[prometheus]` section containing `disable = true` instead of omitting the section
- [x] 2.2 Verify the existing enabled-path still writes `http_listen` and `report_errors` correctly

## 3. Add .dockerignore

- [x] 3.1 Create `.dockerignore` at the repository root excluding `openspec/`, `.github/`, `CONTRIBUTING.md`, `*.md`, and `.git/`
- [x] 3.2 Add a note to the Local Build section of `CONTRIBUTING.md` explaining that `openspec/` is in `.dockerignore` and why (HA Supervisor would otherwise treat it as an add-on candidate)

## 4. Validate

- [ ] 4.1 Run the updated `run.sh` with `prometheus.enabled: false` and confirm no Prometheus listener appears in the add-on log
- [ ] 4.2 Run with `log_level: debug` and confirm `--debug` is passed; run with `log_level: info` and confirm it is not
- [ ] 4.3 Run `docker build -f unifi-poller/Dockerfile .` from the repo root and confirm `openspec/` is absent from the image
