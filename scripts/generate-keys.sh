#!/bin/bash

set -e

echo "=================================="
echo "WireGuard Key Generation Script"
echo "=================================="
echo ""

# Check if wireguard-tools is installed
if ! command -v wg &> /dev/null; then
    echo "ERROR: wireguard-tools is not installed!"
    echo "Please install it first:"
    echo "  Ubuntu/Debian: sudo apt install wireguard-tools"
    echo "  Arch: sudo pacman -S wireguard-tools"
    echo "  macOS: brew install wireguard-tools"
    exit 1
fi

# Navigate to project root
cd "$(dirname "$0")/.."

# Function to generate a key pair
generate_keypair() {
    local name=$1
    local dir=$2

    echo "Generating keys for: $name"

    # Generate private key
    wg genkey > "$dir/${name}_private.key"
    chmod 600 "$dir/${name}_private.key"

    # Generate public key from private key
    wg pubkey < "$dir/${name}_private.key" > "$dir/${name}_public.key"
    chmod 644 "$dir/${name}_public.key"

    echo "  Private key: $dir/${name}_private.key"
    echo "  Public key:  $dir/${name}_public.key"
    echo ""
}

# Generate server keys
echo "1. Generating Server Keys"
echo "-------------------------"
generate_keypair "server" "server/keys"

# Generate Docker client keys
echo "2. Generating Docker Client Keys (client1)"
echo "-------------------------------------------"
generate_keypair "client1" "client/keys"

# Generate native client keys
echo "3. Generating Native Client Keys"
echo "---------------------------------"
for i in {2..4}; do
    generate_keypair "client$i" "native-clients/keys"
done

echo "=================================="
echo "Key Generation Complete!"
echo "=================================="
echo ""
echo "Generated keys:"
echo "  - Server (10.8.0.1)"
echo "  - Client1 (10.8.0.2) - Docker test client"
echo "  - Client2 (10.8.0.3) - Native client"
echo "  - Client3 (10.8.0.4) - Native client"
echo "  - Client4 (10.8.0.5) - Native client"
echo ""
echo "IMPORTANT: Private keys are set to 600 permissions and are"
echo "excluded from git via .gitignore. Keep them secure!"
echo ""
echo "Next steps:"
echo "  1. Review the generated public keys"
echo "  2. The keys are already in place for the Docker containers"
echo "  3. Run: docker-compose up -d"
echo ""
