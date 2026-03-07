# WireGuard VPN Client
FROM alpine:latest

# Install WireGuard and testing tools
RUN apk add --no-cache \
    wireguard-tools \
    iptables \
    iproute2 \
    curl \
    iputils \
    bind-tools \
    bash

# Create WireGuard config directory
RUN mkdir -p /etc/wireguard

# Copy configuration file
COPY docker-client.conf /etc/wireguard/wg0.conf

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set proper permissions on config
RUN chmod 600 /etc/wireguard/wg0.conf

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD ping -c 1 10.8.0.1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
