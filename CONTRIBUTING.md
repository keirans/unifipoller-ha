# Contributing to UniFi Poller HA Add-on

Thank you for contributing. This document covers how to build and test the add-on locally, run the linters, and understand the development workflow.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (for building and testing the image locally)
- `jq` (JSON linting): `brew install jq` / `apt install jq`
- `yamllint` (YAML linting): `pip install yamllint`
- [openspec](https://www.npmjs.com/package/@fission-ai/openspec) (development task tracking): `npm install -g @fission-ai/openspec`

---

## Local Build

Build the add-on container image locally, pinning to a specific UniFi Poller version:

```bash
docker build \
  --build-arg UNPOLLER_VERSION=2.9.0 \
  -t ha-addon-unifi-poller:local \
  unifi-poller/
```

To build with a different UniFi Poller version:

```bash
docker build \
  --build-arg UNPOLLER_VERSION=2.10.0 \
  -t ha-addon-unifi-poller:local \
  unifi-poller/
```

Verify the binary is present and executable:

```bash
docker run --rm ha-addon-unifi-poller:local /usr/bin/unpoller --version
```

---

## Local Run

The add-on normally reads its configuration from the Home Assistant Supervisor. For local smoke-testing, you can mount a config file directly:

1. Create a minimal `up.conf`:

```toml
[unifi]
  [unifi.defaults]
    url        = "https://your-controller:8443"
    user       = "readonly-user"
    pass       = "secret"
    verify_ssl = false
    sites      = ["all"]

[influxdb]
  url  = "http://localhost:8086"
  db   = "unifi"
  user = ""
  pass = ""
```

2. Run the container with the config mounted:

```bash
docker run --rm \
  -v "$(pwd)/up.conf:/etc/unpoller/up.conf:ro" \
  --entrypoint /usr/bin/unpoller \
  ha-addon-unifi-poller:local \
  --config /etc/unpoller/up.conf
```

---

## Linting

Run these checks before opening a pull request. The CI pipeline runs the same checks.

**JSON files:**

```bash
find unifi-poller -name '*.json' -print0 | xargs -0 -I{} sh -c 'jq . "{}" > /dev/null && echo "OK: {}"'
```

**YAML files:**

```bash
yamllint -d "{extends: default, rules: {line-length: {max: 120}}}" \
  $(find . -name '*.yaml' -o -name '*.yml' | grep -v '.github' | grep -v 'openspec')
```

---

## Pull Request Process

1. Fork the repository and create a feature branch from `main`
2. Make your changes — keep them focused on a single concern
3. Run the linters above and fix any issues
4. Open a pull request against `main` with a clear description of what changed and why
5. CI will run lint and build checks automatically
6. A maintainer will review and merge

---

## Development Workflow

This project uses **[OpenSpec](https://www.npmjs.com/package/@fission-ai/openspec)** to manage change proposals, design decisions, capability specifications, and implementation tasks.

### Understanding the structure

```
openspec/
├── config.yaml          # Project context used by all changes
├── changes/             # In-progress and completed changes
│   └── <change-name>/
│       ├── proposal.md  # What and why
│       ├── design.md    # How (technical decisions)
│       ├── specs/       # Capability requirements
│       └── tasks.md     # Implementation checklist
└── specs/               # Merged capability specifications
```

### Common commands

List active changes and their progress:

```bash
openspec list
```

Check the status and remaining tasks for a change:

```bash
openspec status --change <change-name>
```

Get implementation instructions for the next task:

```bash
openspec instructions apply --change <change-name>
```

### Proposing a change

Before starting significant new work, create a change proposal:

```bash
openspec new change "<your-change-name>"
```

Then fill in `proposal.md`, `design.md`, `specs/`, and `tasks.md` — or use the `/opsx:propose` Claude Code skill to generate them from a description.
