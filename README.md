# UniFi Poller — Home Assistant Add-on Repository

[![CI](https://github.com/keirans/unifipoller-ha/actions/workflows/ci.yaml/badge.svg)](https://github.com/keirans/unifipoller-ha/actions/workflows/ci.yaml)

A Home Assistant add-on repository that packages [UniFi Poller](https://github.com/unpoller/unpoller) as a supervised add-on. Collect metrics from your UniFi Network Controller and export them to InfluxDB or Prometheus for visualisation in Grafana — all managed from the Home Assistant Supervisor.

This is a personal homelab project maintained in spare time and shared for community use. It supports the maintainer's own setup first — bug reports and fixes via pull requests are encouraged and appreciated.

---

## Add-ons

| Add-on | Description |
|---|---|
| [UniFi Poller](unifi-poller/DOCS.md) | Export UniFi controller metrics to InfluxDB or Prometheus |

---

## Installation

### 1. Add this repository to Home Assistant

Click the button below to add the repository directly to your Home Assistant instance:

[![Add Repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fkeirans%2Funifipoller-ha)

Or add it manually:

1. In Home Assistant, navigate to **Settings → Add-ons → Add-on Store**
2. Click the menu icon (**⋮**) in the top-right corner
3. Select **Repositories**
4. Enter `https://github.com/keirans/unifipoller-ha` and click **Add**
5. Close the dialog — the repository will appear in the store

### 2. Install the add-on

1. Find **UniFi Poller** in the Add-on Store (scroll down or search)
2. Click on it, then click **Install**
3. Wait for the image to download

### 3. Configure and start

1. Open the add-on's **Configuration** tab
2. Set your controller URL, username, and password
3. Configure your preferred exporter (InfluxDB is enabled by default)
4. Click **Save**, then click **Start**

See the [full documentation](unifi-poller/DOCS.md) for all configuration options.

---

## Requirements

- Home Assistant with Supervisor (not Home Assistant Core)
- A reachable UniFi Network Controller
- InfluxDB 1.8.x and/or Prometheus 2.x

## Supported Architectures

| Architecture | Supported |
|---|---|
| amd64 (x86-64) | Yes |
| aarch64 (arm64) | Yes |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local build instructions, linting, and the development workflow.
