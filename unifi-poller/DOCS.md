# UniFi Poller Add-on

Collect metrics from your UniFi Network Controller and export them to InfluxDB or Prometheus for visualisation in Grafana.

---

## Prerequisites

Before starting the add-on, ensure you have:

- A reachable **UniFi Network Controller** (UDM, UDM Pro, CloudKey, or self-hosted)
- At least one of the following running and accessible from your Home Assistant host:
  - **InfluxDB 1.8.x** (officially supported) with a database created for UniFi Poller
  - **Prometheus 2.x** configured to scrape this add-on's metrics endpoint
- A dedicated **read-only UniFi account** for the add-on (see [Security](#security))

---

## Installation

See the [README](https://github.com/keirans/unifipoller-ha) for repository installation steps.

Once the repository is added, install this add-on from the Add-on Store, configure the options below, then click **Start**.

---

## Configuration Options

| Option | Type | Default | Description |
|---|---|---|---|
| `controller.url` | string | `https://unifi.local:8443` | Full URL of the UniFi controller — see note below |
| `controller.username` | string | _(required)_ | Username of the UniFi account used for polling |
| `controller.password` | string | _(required)_ | Password for the above account |
| `controller.verify_ssl` | boolean | `false` | Verify the controller's SSL certificate. Disable for self-signed certs |
| `influxdb.enabled` | boolean | `true` | Enable the InfluxDB exporter |
| `influxdb.url` | string | `http://localhost:8086` | URL of the InfluxDB 1.x instance |
| `influxdb.db` | string | `unifi` | InfluxDB database name |
| `influxdb.username` | string | _(empty)_ | InfluxDB username (leave empty if auth is disabled) |
| `influxdb.password` | string | _(empty)_ | InfluxDB password (leave empty if auth is disabled) |
| `prometheus.enabled` | boolean | `false` | Enable the Prometheus metrics endpoint |
| `prometheus.port` | integer | `9130` | Port on which the Prometheus `/metrics` endpoint is exposed |
| `polling_interval` | integer | `30` | How often (in seconds) to poll the controller |
| `log_level` | string | `info` | Log verbosity: `info`, `debug`, `warn`, or `error` |

> **Controller URL by hardware type:**
>
> | Controller type | URL format | Example |
> |---|---|---|
> | UDM, UDM Pro, UDM SE, UCG | `https://<ip>` (no port) | `https://10.0.0.1` |
> | CloudKey Gen2, self-hosted Network Application | `https://<ip>:8443` | `https://10.0.0.1:8443` |
>
> UniFi OS devices (UDM family) use port 443 and a different API path. Using `:8443` with a UDM will result in a 404 authentication error.
>
> **Note:** Only a single UniFi controller is supported per add-on instance.

---

## Exporters

This add-on supports two independent export targets. At least one must be enabled.

### InfluxDB (push model)

UniFi Poller actively **pushes** metric data to InfluxDB on every poll interval. Data accumulates in InfluxDB over time and is queried directly by Grafana.

- Storage requirements grow continuously; set a [retention policy](https://docs.influxdata.com/influxdb/v1.8/guides/downsample_and_retain/) to manage disk usage
- No inbound network port is required on the add-on
- Default and recommended for most setups

### Prometheus (pull model)

UniFi Poller exposes a `/metrics` endpoint and waits for Prometheus to **scrape** it on Prometheus's own schedule. Prometheus stores the data in its own time-series database.

- Storage requirements are managed by Prometheus's own retention settings
- Requires an open inbound port (`prometheus.port`, default `9130`) so Prometheus can reach the add-on
- Your Prometheus instance must be configured with a scrape job pointing at `http://<ha-host>:<port>/metrics`

### Running both simultaneously

Both exporters can be enabled at the same time. Be aware that:

- Metrics are stored independently in two separate systems, each with their own retention policies and disk usage
- The Prometheus port must be accessible from your Prometheus instance
- Duplicate data ingestion may increase load on the UniFi controller

---

## Compatibility

| Exporter | Version | Support level |
|---|---|---|
| InfluxDB | 1.8.x | **Officially supported** |
| InfluxDB | 1.10, 1.11 | Community supported |
| InfluxDB | 2.x | Not supported |
| Prometheus | 2.x | **Officially supported** |
| Loki | any | Not supported |

**Community supported** means these versions are not tested by the maintainers but have been reported to work by community members. Issues should include full reproduction details (controller version, InfluxDB version, add-on version, and relevant log output). The same level of support as 1.8.x cannot be guaranteed.

---

## Security

- Create a **dedicated read-only UniFi account** for this add-on. Do not use your administrator account.
  In the UniFi console: _Settings → Admins & Users → Add Admin_ — assign the **Read Only** role.
- Controller credentials are stored in the Home Assistant options store, which is encrypted at rest by the Supervisor. However, any add-on running on your system can read add-on options via the Supervisor API. Use a least-privilege account to limit exposure.
- If your controller uses a self-signed certificate, set `controller.verify_ssl` to `false`. For production use, consider provisioning a trusted certificate.

---

## Architecture

This add-on supports the following CPU architectures:

| Architecture | Supported |
|---|---|
| amd64 (x86-64) | Yes |
| arm64 (aarch64) | Not yet — planned for a future release |
| armv7 | Not yet |

If you require arm64 support, please [open an issue](https://github.com/keirans/unifipoller-ha/issues).

---

## Troubleshooting

**Add-on fails to start with "At least one exporter must be enabled"**
Enable either `influxdb.enabled` or `prometheus.enabled` (or both) in the configuration.

**Add-on fails to start with a missing field error**
Ensure `controller.url`, `controller.username`, and `controller.password` are all set.

**No data appearing in InfluxDB/Grafana**
- Confirm the InfluxDB URL is reachable from the Home Assistant host
- Check that the database name matches what Grafana is querying
- Set `log_level` to `debug` and check the add-on log for connection errors

**Prometheus scrape returning no data**
- Confirm Prometheus can reach `http://<ha-host>:<prometheus.port>/metrics`
- Check the add-on log for startup errors
- Ensure the port is not blocked by a firewall
