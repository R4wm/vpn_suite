#!/bin/bash

set -e

echo "=================================================="
echo "WireGuard VPN Connectivity Test"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Helper function for test results
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        FAILED=$((FAILED + 1))
    fi
}

# Navigate to project root
cd "$(dirname "$0")/.."

echo "1. Checking Docker Containers"
echo "------------------------------"

if docker ps --format "{{.Names}}" | grep -q "wireguard-server"; then
    test_result 0 "Server container is running"
else
    test_result 1 "Server container is not running"
    echo ""
    echo "Please start the containers with: docker-compose up -d"
    exit 1
fi

if docker ps --format "{{.Names}}" | grep -q "wireguard-client"; then
    test_result 0 "Client container is running"
else
    test_result 1 "Client container is not running"
fi

echo ""
echo "2. WireGuard Server Status"
echo "---------------------------"
echo ""
docker exec wireguard-server wg show wg0 2>/dev/null || {
    test_result 1 "Cannot get server WireGuard status"
    exit 1
}
echo ""
test_result 0 "Server WireGuard interface is up"

echo ""
echo "3. WireGuard Client Status"
echo "---------------------------"
echo ""
docker exec wireguard-client wg show wg0 2>/dev/null || {
    test_result 1 "Cannot get client WireGuard status"
    exit 1
}
echo ""
test_result 0 "Client WireGuard interface is up"

echo ""
echo "4. VPN Tunnel Connectivity"
echo "---------------------------"

# Test client can reach server VPN IP
if docker exec wireguard-client ping -c 3 -W 2 10.8.0.1 >/dev/null 2>&1; then
    test_result 0 "Client can reach server VPN IP (10.8.0.1)"
else
    test_result 1 "Client cannot reach server VPN IP (10.8.0.1)"
fi

echo ""
echo "5. Internet Connectivity Through VPN"
echo "--------------------------------------"

# Test internet via Cloudflare DNS
if docker exec wireguard-client ping -c 3 -W 2 1.1.1.1 >/dev/null 2>&1; then
    test_result 0 "Client can reach internet (ping 1.1.1.1)"
else
    test_result 1 "Client cannot reach internet (ping 1.1.1.1)"
fi

# Test Google DNS as alternative
if docker exec wireguard-client ping -c 3 -W 2 8.8.8.8 >/dev/null 2>&1; then
    test_result 0 "Client can reach Google DNS (8.8.8.8)"
else
    test_result 1 "Client cannot reach Google DNS (8.8.8.8)"
fi

echo ""
echo "6. DNS Resolution"
echo "------------------"

# Test DNS resolution
if docker exec wireguard-client nslookup google.com >/dev/null 2>&1; then
    test_result 0 "DNS resolution works (google.com)"
else
    test_result 1 "DNS resolution failed (google.com)"
fi

echo ""
echo "7. Public IP Check"
echo "-------------------"

# Get client's public IP (should be server's IP if VPN is working)
CLIENT_IP=$(docker exec wireguard-client curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "failed")

if [ "$CLIENT_IP" != "failed" ] && [ -n "$CLIENT_IP" ]; then
    echo "Client's public IP: $CLIENT_IP"
    test_result 0 "Public IP check successful"
    echo ""
    echo -e "${YELLOW}NOTE:${NC} If this is your server's IP, the VPN is routing correctly."
    echo -e "${YELLOW}NOTE:${NC} If this is NOT your server's IP, check NAT/routing configuration."
else
    test_result 1 "Could not determine public IP"
fi

echo ""
echo "8. Peer Handshake Check"
echo "------------------------"

# Check if handshake is established
HANDSHAKE=$(docker exec wireguard-server wg show wg0 latest-handshakes | grep -c "^" || echo "0")

if [ "$HANDSHAKE" -gt 0 ]; then
    test_result 0 "Peer handshake established ($HANDSHAKE peer(s))"
    echo ""
    echo "Connected peers:"
    docker exec wireguard-server wg show wg0 peers | nl
else
    test_result 1 "No peer handshake detected"
fi

echo ""
echo "=================================================="
echo "Test Summary"
echo "=================================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! VPN is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
fi
