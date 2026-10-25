#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

SERVER="${SERVER_OVERRIDE:-192.168.0.116}"
SERVER_PORT="${SERVER_PORT_OVERRIDE:-51820}"
CLIENT_ID="${CLIENT_ID:-}"
TMP_DIR="$(mktemp -d)"
TMP_CONF="${TMP_DIR}/wgtest0.conf"
WG_IF="wgtest0"

usage() {
  cat <<USAGE
Usage:
  $0
  $0 --client-id <id>

Default mode tests the existing live Linux client key on the server.
--client-id mode decrypts native-clients/encrypted/<id>.conf.enc and tests that profile.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --client-id)
      CLIENT_ID="${2:-}"
      shift 2
      ;;
    --server)
      SERVER="${2:-}"
      shift 2
      ;;
    --port)
      SERVER_PORT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

cleanup() {
  if sudo -n wg show "${WG_IF}" >/dev/null 2>&1; then
    sudo -n wg-quick down "${TMP_CONF}" >/dev/null 2>&1 || true
  fi
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "Fetching live Linux client material from ${SERVER}..."
if [[ -n "${CLIENT_ID}" ]]; then
  ensure_passphrase_file
  load_server_env
  "${SCRIPT_DIR}/decrypt-client-config.sh" "${CLIENT_ID}" --output "${TMP_CONF}" >/dev/null
  # Keep same-LAN tests limited to the VPN subnet and server LAN.
  sed -i "s|^AllowedIPs = .*|AllowedIPs = ${SERVER_VPN_CIDR}, ${SERVER_LAN_CIDR}|" "${TMP_CONF}"
  sed -i '/^DNS = /d' "${TMP_CONF}"
else
  load_server_env
  SERVER_PUB="$(ssh -o BatchMode=yes r4wm@${SERVER} 'sudo -n cat /etc/wireguard/server_public.key')"
  CLIENT_PRIV="$(ssh -o BatchMode=yes r4wm@${SERVER} 'sudo -n cat /etc/wireguard/client_linux_private.key')"

  cat > "${TMP_CONF}" <<CONF
[Interface]
Address = 10.8.0.3/32
PrivateKey = ${CLIENT_PRIV}

[Peer]
PublicKey = ${SERVER_PUB}
Endpoint = ${SERVER}:${SERVER_PORT}
AllowedIPs = ${SERVER_VPN_CIDR}, ${SERVER_LAN_CIDR}
PersistentKeepalive = 25
CONF
fi
chmod 600 "${TMP_CONF}"

echo "Bringing up temporary WireGuard tunnel..."
sudo -n wg-quick up "${TMP_CONF}"

echo "Checking handshake status..."
sudo -n wg show

echo "Pinging server VPN IP 10.8.0.1..."
ping -c 3 10.8.0.1

echo "Pinging LAN test target ${SERVER_LAN_TEST_IP}..."
ping -c 3 "${SERVER_LAN_TEST_IP}"

echo "Route check (wg routes only):"
ip route | grep -E '10\.8\.0\.0/24|192\.168\.0\.0/24' || true

if [[ -n "${CLIENT_ID}" ]]; then
  PUB_KEY="$(awk -F',' -v id="${CLIENT_ID}" 'NR>1 && $1==id {print $4}' "${CLIENT_REGISTRY}")"
  if [[ -n "${PUB_KEY}" ]]; then
    echo "Server handshake row for ${CLIENT_ID}:"
    ssh -o BatchMode=yes "r4wm@${SERVER}" "sudo -n wg show wg0 latest-handshakes | grep '${PUB_KEY}' || true"
  fi
fi

echo "Native connectivity test completed successfully."
