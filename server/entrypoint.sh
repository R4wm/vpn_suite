#!/bin/sh

set -e

echo "=================================="
echo "WireGuard VPN Server Starting"
echo "=================================="
echo ""

# Note: IP forwarding is enabled via docker-compose.yml sysctls

# Display configuration
echo ""
echo "Server Configuration:"
echo "  VPN Network: 10.8.0.0/24"
echo "  Server IP: 10.8.0.1"
echo "  Listen Port: 51820 (UDP)"
echo ""

# Start WireGuard
echo "Starting WireGuard interface wg0..."
wg-quick up wg0

echo ""
echo "=================================="
echo "WireGuard Server Status"
echo "=================================="
wg show wg0

echo ""
echo "=================================="
echo "Server is running!"
echo "=================================="
echo "Configured peers:"
wg show wg0 peers | nl
echo ""
echo "Logs will appear below..."
echo ""

# Keep container running and show connection logs
tail -f /dev/null
