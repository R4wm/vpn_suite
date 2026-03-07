#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

CLIENT_ID="${1:-}"
SERVER_HOST_OVERRIDE="${2:-}"

if [[ -z "${CLIENT_ID}" ]]; then
  echo "Usage: $0 <client-id> [server-host]" >&2
  exit 1
fi

require_cmd ssh
require_cmd sed
require_cmd awk
ensure_dirs
ensure_passphrase_file
load_server_env

if [[ -n "${SERVER_HOST_OVERRIDE}" ]]; then
  SERVER_HOST="${SERVER_HOST_OVERRIDE}"
fi

PUB_KEY="$(awk -F',' -v id="${CLIENT_ID}" 'NR>1 && $1==id {print $4}' "${CLIENT_REGISTRY}")"
if [[ -z "${PUB_KEY}" ]]; then
  echo "ERROR: client id not found in registry: ${CLIENT_ID}" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
TMP_CONF="${TMP_DIR}/wgtst1.conf"
WG_IF="wgtst1"

cleanup() {
  if sudo -n wg show "${WG_IF}" >/dev/null 2>&1; then
    sudo -n wg-quick down "${TMP_CONF}" >/dev/null 2>&1 || true
  fi
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

VPN_SUITE_PASSPHRASE_FILE="${PASSPHRASE_FILE}" "${SCRIPT_DIR}/decrypt-client-config.sh" "${CLIENT_ID}" --output "${TMP_CONF}" >/dev/null

# For same-LAN testing, keep split route limited to VPN subnet to avoid routing conflicts.
sed -i 's/^AllowedIPs = .*/AllowedIPs = 10.8.0.0\/24/' "${TMP_CONF}"

echo "Bringing up ${CLIENT_ID} test tunnel..."
sudo -n wg-quick up "${TMP_CONF}"

echo "Client-side status:"
sudo -n wg show "${WG_IF}"

echo "Pinging VPN server 10.8.0.1..."
ping -c 3 10.8.0.1

echo "Server-side handshake for ${CLIENT_ID}:"
ssh -o BatchMode=yes "r4wm@${SERVER_HOST}" "sudo -n wg show wg0 latest-handshakes | grep '${PUB_KEY}'"

echo "Provisioned client test succeeded for ${CLIENT_ID}."
