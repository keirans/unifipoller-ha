ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

ARG UNPOLLER_VERSION=2.29.0
ARG TARGETARCH=amd64

RUN apk add --no-cache curl \
    && case "${TARGETARCH}" in \
         amd64) UP_ARCH="linux_amd64" ;; \
         arm64) UP_ARCH="linux_arm64" ;; \
         *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
       esac \
    && curl -fsSL \
        "https://github.com/unpoller/unpoller/releases/download/v${UNPOLLER_VERSION}/unpoller_${UNPOLLER_VERSION}_${UP_ARCH}.tar.gz" \
        -o /tmp/unpoller.tar.gz \
    && tar -xzf /tmp/unpoller.tar.gz -C /tmp \
    && mv /tmp/unpoller /usr/bin/unpoller \
    && chmod +x /usr/bin/unpoller \
    && rm -rf /tmp/unpoller.tar.gz /tmp/unpoller_* \
    && mkdir -p /etc/unpoller

COPY run.sh /etc/services.d/unifi-poller/run
RUN chmod +x /etc/services.d/unifi-poller/run
