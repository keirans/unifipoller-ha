## 1. Repository Scaffold

- [x] 1.1 Create top-level `unifi-poller/` add-on directory in the repository
- [x] 1.2 Create `repository.yaml` at the repository root with `name: "UniFi Poller"`, `url: "https://github.com/keirans/unifipoller-ha"`, and `maintainer` fields
- [x] 1.3 Create `.gitignore` entries for build artifacts (e.g., `*.tar.gz`, local binary)

## 2. Add-on Manifest (addon-config)

- [x] 2.1 Create `unifi-poller/config.yaml` with `name`, `version`, `slug`, `description`, `arch: [amd64]`, `startup`, `boot`, `init`, `url`, and `homeassistant` fields
- [x] 2.2 Add the `image` field pointing to `ghcr.io/{owner}/ha-addon-unifi-poller:{arch}-{version}`
- [x] 2.3 Define `options` block with defaults: `controller.url`, `controller.username`, `controller.password`, `controller.verify_ssl`, `influxdb.enabled`, `influxdb.url`, `influxdb.db`, `influxdb.username`, `influxdb.password`, `prometheus.enabled`, `prometheus.port`, `polling_interval`, `log_level`
- [x] 2.4 Define matching `schema` block with correct types for all options (mark controller credentials as required with no default)
- [x] 2.5 Validate `config.yaml` with `yq` to confirm it parses correctly

## 3. Dockerfile (container-build)

- [x] 3.1 Create `unifi-poller/Dockerfile` using `FROM ghcr.io/home-assistant/base:latest`
- [x] 3.2 Add `ARG UNPOLLER_VERSION` and download the correct amd64 binary from the GitHub releases URL using `curl` or `wget`
- [x] 3.3 Install the binary to `/usr/bin/unpoller` and set executable permissions
- [x] 3.4 Remove temporary download files in the same `RUN` layer to keep the image minimal
- [x] 3.5 Copy `run.sh` into the image at `/etc/services.d/unifi-poller/run` (or the path declared in `config.yaml`) and set executable
- [ ] 3.6 Build the image locally with `docker build` and confirm `unpoller --version` runs inside the container

## 4. Runtime Entrypoint (runtime-entrypoint)

- [x] 4.1 Create `unifi-poller/run.sh` with `#!/usr/bin/with-contenv bashio` shebang
- [x] 4.2 Read controller options using `bashio::config` and guard required fields with `bashio::config.require`
- [x] 4.3 Write the `[unifi.defaults]` section to `/etc/unpoller/up.conf` using controller URL, username, password, and verify_ssl
- [x] 4.4 Conditionally write `[influxdb]` section when `influxdb.enabled` is `true`
- [x] 4.5 Conditionally write `[prometheus]` section when `prometheus.enabled` is `true`
- [x] 4.6 Pass `--debug` flag to `unpoller` when `log_level` is `debug`
- [x] 4.7 Replace the shell with `exec unpoller --config /etc/unpoller/up.conf` (no subshell or backgrounding)
- [ ] 4.8 Smoke-test `run.sh` locally with mock `bashio` stubs or inside the container with test option values

## 5. CI/CD Pipeline (ci-cd-pipeline)

- [x] 5.1 Create `.github/workflows/ci.yaml` with `on: push` (branches: `[main]`) and `on: pull_request` triggers
- [x] 5.2 Add `lint` job: run `jq .` on all `*.json` files and `yq e '.' ` on all `*.yaml`/`*.yml` files in `unifi-poller/`
- [x] 5.3 Add `build` job that depends on `lint`, using `docker/build-push-action` to build the image
- [x] 5.4 Set `push: false` on pull requests and `push: true` only on push to `main` or on release events
- [x] 5.5 Create `.github/workflows/release.yaml` triggered by `release: [published]` that builds and pushes the image tagged `amd64-{tag}` to `ghcr.io`
- [x] 5.6 Configure GHCR login step using `docker/login-action` with `secrets.GITHUB_TOKEN`
- [ ] 5.7 Validate the workflows by opening a test PR and confirming lint and build jobs run correctly

## 6. Documentation (addon-documentation)

- [x] 6.1 Create `unifi-poller/DOCS.md` with sections: Prerequisites, Installation, Configuration Options, Exporters, Compatibility, Security, Troubleshooting
- [x] 6.2 Document every `config.yaml` option with its type, default, and description in `DOCS.md`
- [x] 6.3 Add a security note in `DOCS.md` recommending a dedicated read-only UniFi controller account
- [x] 6.4 Add an architecture support section noting `amd64` only in current release
- [x] 6.5 Add an Exporters section to `DOCS.md` explaining push (InfluxDB) vs pull (Prometheus) models, dual-exporter resource implications, and the single controller limitation
- [x] 6.6 Add a compatibility table to `DOCS.md` covering InfluxDB (1.8.x official, 1.10/1.11 community, 2.x unsupported), Prometheus (2.x required), and Loki (not supported), with a definition of "community-supported"
- [x] 6.7 Create or update `README.md` at the repository root with: description, link to `unifi-poller/DOCS.md`, and badges (build status, version)
- [x] 6.8 Add an Installation section to `README.md` with numbered steps: navigate to Add-on Store → Repositories, add `https://github.com/keirans/unifipoller-ha`, find and install the add-on, configure before starting
- [x] 6.9 Add an "Add Repository" deep-link badge to `README.md` that opens the HA Supervisor repository dialog pre-filled with `https://github.com/keirans/unifipoller-ha`
- [x] 6.10 Create `CONTRIBUTING.md` at the repository root with sections: Prerequisites, Local Build (`docker build --build-arg UNPOLLER_VERSION=<ver>`), Local Run (example `docker run` with options), Linting (`jq` and `yq` commands), and Pull Request process
- [x] 6.11 Add a Development Workflow section to `CONTRIBUTING.md` referencing OpenSpec: explain it manages change proposals and tasks, direct contributors to `openspec/changes/` for active work and `openspec/specs/` for capability specs, and include the `openspec list` command
