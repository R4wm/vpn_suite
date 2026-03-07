#!/bin/bash

set -e

# Check if wireguard-tools is installed
if ! command -v wg &> /dev/null; then
    echo "ERROR: wireguard-tools is not installed!"
    echo "Please install it first."
    exit 1
fi

# Check if client number is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <client_number>"
    echo ""
    echo "Example: $0 6"
    echo "  This will create client6 with IP 10.8.0.6"
    echo ""
    echo "Current clients:"
    echo "  - client1 (10.8.0.2) - Docker test client"
    echo "  - client2 (10.8.0.3) - Native client"
    echo "  - client3 (10.8.0.4) - Native client"
    echo "  - client4 (10.8.0.5) - Native client"
    echo ""
    echo "Available IPs: 10.8.0.6 - 10.8.0.254"
    exit 1
fi

CLIENT_NUM=$1
CLIENT_IP="10.8.0.$CLIENT_NUM"
CLIENT_NAME="client$CLIENT_NUM"

# Validate IP is in valid range
if [ "$CLIENT_NUM" -lt 6 ] || [ "$CLIENT_NUM" -gt 254 ]; then
    echo "ERROR: Client number must be between 6 and 254"
    echo "IPs 10.8.0.1-10.8.0.5 are already allocated"
    exit 1
fi

# Navigate to project root
cd "$(dirname "$0")/.."

# Create keys directory if it doesn't exist
mkdir -p native-clients/keys

# Check if client already exists
if [ -f "native-clients/keys/${CLIENT_NAME}_private.key" ]; then
    echo "WARNING: Client $CLIENT_NAME already exists!"
    read -p "Overwrite existing keys? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "=================================="
echo "Adding New WireGuard Client"
echo "=================================="
echo "Client: $CLIENT_NAME"
echo "VPN IP: $CLIENT_IP/32"
echo ""

# Generate keys
echo "Generating keys..."
wg genkey > "native-clients/keys/${CLIENT_NAME}_private.key"
chmod 600 "native-clients/keys/${CLIENT_NAME}_private.key"

wg pubkey < "native-clients/keys/${CLIENT_NAME}_private.key" > "native-clients/keys/${CLIENT_NAME}_public.key"
chmod 644 "native-clients/keys/${CLIENT_NAME}_public.key"

PRIVATE_KEY=$(cat "native-clients/keys/${CLIENT_NAME}_private.key")
PUBLIC_KEY=$(cat "native-clients/keys/${CLIENT_NAME}_public.key")
SERVER_PUBLIC_KEY=$(cat "server/keys/server_public.key")

# Create client config
echo "Creating client configuration..."
cat > "native-clients/${CLIENT_NAME}.conf" << EOF
[Interface]
Address = $CLIENT_IP/32
PrivateKey = $PRIVATE_KEY
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
# IMPORTANT: Replace YOUR_SERVER_PUBLIC_IP with your actual server's public IP address
Endpoint = YOUR_SERVER_PUBLIC_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

chmod 600 "native-clients/${CLIENT_NAME}.conf"

echo ""
echo "=================================="
echo "Client Created Successfully!"
echo "=================================="
echo ""
echo "Configuration file: native-clients/${CLIENT_NAME}.conf"
echo ""
echo "Next steps:"
echo ""
echo "1. Add this peer block to server/wg0.conf:"
echo ""
echo "# $CLIENT_NAME"
echo "[Peer]"
echo "PublicKey = $PUBLIC_KEY"
echo "AllowedIPs = $CLIENT_IP/32"
echo ""
echo "2. Restart the WireGuard server:"
echo "   docker-compose restart wireguard-server"
echo ""
echo "3. Update the Endpoint in native-clients/${CLIENT_NAME}.conf with your server's public IP"
echo ""
echo "4. Import the config into your WireGuard client"
echo ""
