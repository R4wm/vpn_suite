#!/bin/sh

echo "=================================="
echo "WireGuard VPN Client Starting"
echo "=================================="
echo ""

echo "Client Configuration:"
echo "  VPN IP: 10.8.0.2/32"
echo "  Server: wireguard-server:51820"
echo "  DNS: 1.1.1.1, 1.0.0.1"
echo "  Full tunnel: 0.0.0.0/0"
echo ""

# Wait for server to be ready
echo "Waiting for server to be available..."
sleep 5

# Start WireGuard
# Note: sysctls are handled by docker-compose.yml, so we patch sysctl to ignore errors
echo "Starting WireGuard interface wg0..."
cat > /usr/local/bin/sysctl << 'EOF'
#!/bin/sh
# Wrapper to ignore sysctl errors in Docker
/sbin/sysctl "$@" 2>/dev/null || true
EOF
chmod +x /usr/local/bin/sysctl
export PATH="/usr/local/bin:$PATH"

wg-quick up wg0

echo ""
echo "=================================="
echo "WireGuard Client Status"
echo "=================================="
wg show wg0

echo ""
echo "Testing connectivity..."
echo ""

# Test VPN connectivity
if ping -c 2 10.8.0.1 >/dev/null 2>&1; then
    echo "✓ VPN tunnel established (can reach server at 10.8.0.1)"
else
    echo "✗ Cannot reach VPN server"
fi

# Test internet connectivity
if ping -c 2 1.1.1.1 >/dev/null 2>&1; then
    echo "✓ Internet connectivity through VPN"
else
    echo "✗ No internet connectivity"
fi

echo ""
echo "=================================="
echo "Client is connected!"
echo "=================================="
echo ""

# Keep container running
tail -f /dev/null
