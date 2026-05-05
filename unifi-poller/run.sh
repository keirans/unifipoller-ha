#!/usr/bin/with-contenv bashio

# Fail fast if no exporter is enabled
if ! bashio::config.true 'influxdb.enabled' && ! bashio::config.true 'prometheus.enabled'; then
    bashio::log.error "At least one exporter (influxdb or prometheus) must be enabled."
    exit 1
fi

# Validate required controller fields
bashio::config.require 'controller.url'
bashio::config.require 'controller.username'
bashio::config.require 'controller.password'

CONTROLLER_URL=$(bashio::config 'controller.url')
CONTROLLER_USER=$(bashio::config 'controller.username')
CONTROLLER_PASS=$(bashio::config 'controller.password')
CONTROLLER_VERIFY_SSL=$(bashio::config 'controller.verify_ssl')
POLLING_INTERVAL=$(bashio::config 'polling_interval')
LOG_LEVEL=$(bashio::config 'log_level')

mkdir -p /etc/unpoller

# Write up.conf
cat > /etc/unpoller/up.conf <<EOF
[unifi]
  [unifi.defaults]
    url        = "${CONTROLLER_URL}"
    user       = "${CONTROLLER_USER}"
    pass       = "${CONTROLLER_PASS}"
    verify_ssl = ${CONTROLLER_VERIFY_SSL}
    sites      = ["all"]

[poller]
  interval = "${POLLING_INTERVAL}s"
EOF

# InfluxDB exporter (v1 only)
if bashio::config.true 'influxdb.enabled'; then
    INFLUXDB_URL=$(bashio::config 'influxdb.url')
    INFLUXDB_DB=$(bashio::config 'influxdb.db')
    INFLUXDB_USER=$(bashio::config 'influxdb.username')
    INFLUXDB_PASS=$(bashio::config 'influxdb.password')

    cat >> /etc/unpoller/up.conf <<EOF

[influxdb]
  url  = "${INFLUXDB_URL}"
  db   = "${INFLUXDB_DB}"
  user = "${INFLUXDB_USER}"
  pass = "${INFLUXDB_PASS}"
EOF
fi

# Prometheus exporter
if bashio::config.true 'prometheus.enabled'; then
    PROMETHEUS_PORT=$(bashio::config 'prometheus.port')

    cat >> /etc/unpoller/up.conf <<EOF

[prometheus]
  http_listen   = ":${PROMETHEUS_PORT}"
  report_errors = false
EOF
else
    cat >> /etc/unpoller/up.conf <<EOF

[prometheus]
  disable = true
EOF
fi

bashio::log.info "Starting UniFi Poller..."

ARGS=(--config /etc/unpoller/up.conf)
[ "${LOG_LEVEL}" = "debug" ] && ARGS+=(--debug)
exec /usr/bin/unpoller "${ARGS[@]}"
