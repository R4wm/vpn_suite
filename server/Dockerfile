# WireGuard VPN Server
FROM alpine:latest

# Install WireGuard and required tools
RUN apk add --no-cache \
    wireguard-tools \
    iptables \
    ip6tables \
    iproute2 \
    bash

# Create WireGuard config directory
RUN mkdir -p /etc/wireguard

# Copy configuration file
COPY wg0.conf /etc/wireguard/wg0.conf

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set proper permissions on config
RUN chmod 600 /etc/wireguard/wg0.conf

# Expose WireGuard port
EXPOSE 51820/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wg show wg0 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
