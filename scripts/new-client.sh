#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

NAME=""
PLATFORM=""
ENDPOINT_OVERRIDE=""
TUNNEL_MODE="split"

usage() {
  cat <<USAGE
Usage: $0 --name <id> --platform <linux|windows|mac> [--endpoint <ip:port>] [--tunnel <split|full>]

Example:
  $0 --name thinkpad_t14 --platform linux
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="${2:-}"
      shift 2
      ;;
    --platform)
      PLATFORM="${2:-}"
      shift 2
      ;;
    --endpoint)
      ENDPOINT_OVERRIDE="${2:-}"
      shift 2
      ;;
    --tunnel)
      TUNNEL_MODE="${2:-}"
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

if [[ -z "${NAME}" || -z "${PLATFORM}" ]]; then
  echo "ERROR: --name and --platform are required" >&2
  usage
  exit 1
fi

if [[ ! "${PLATFORM}" =~ ^(linux|windows|mac)$ ]]; then
  echo "ERROR: --platform must be one of linux, windows, mac" >&2
  exit 1
fi

if [[ ! "${TUNNEL_MODE}" =~ ^(split|full)$ ]]; then
  echo "ERROR: --tunnel must be split or full" >&2
  exit 1
fi

if [[ ! "${NAME}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "ERROR: invalid name '${NAME}'" >&2
  exit 1
fi

require_cmd wg
require_cmd openssl
ensure_dirs
load_server_env
ensure_passphrase_file

if [[ ! -f "${CLIENT_REGISTRY}" ]]; then
  echo "ERROR: missing client registry: ${CLIENT_REGISTRY}" >&2
  exit 1
fi

if awk -F',' -v n="${NAME}" 'NR>1 && $1==n {found=1} END{exit !found}' "${CLIENT_REGISTRY}"; then
  echo "ERROR: client name already exists in registry: ${NAME}" >&2
  exit 1
fi

VPN_IP="$(next_vpn_ip)"
if [[ -z "${VPN_IP}" ]]; then
  echo "ERROR: unable to allocate VPN IP" >&2
  exit 1
fi

PRIVATE_KEY="$(wg genkey)"
PUBLIC_KEY="$(printf '%s' "${PRIVATE_KEY}" | wg pubkey)"

if [[ -n "${ENDPOINT_OVERRIDE}" ]]; then
  ENDPOINT="${ENDPOINT_OVERRIDE}"
else
  ENDPOINT="${SERVER_ENDPOINT}"
fi

if [[ "${TUNNEL_MODE}" == "full" ]]; then
  ALLOWED_IPS="0.0.0.0/0"
else
  ALLOWED_IPS="${SERVER_VPN_CIDR}, ${SERVER_LAN_CIDR}"
fi

PLAINTEXT_CONF="${PLAINTEXT_DIR}/${NAME}.conf"
ENCRYPTED_CONF="${ENCRYPTED_DIR}/${NAME}.conf.enc"
PEER_BLOCK="${STATE_DIR}/${NAME}.peer"

cat > "${PLAINTEXT_CONF}" <<CONF
[Interface]
Address = ${VPN_IP}/32
PrivateKey = ${PRIVATE_KEY}
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = ${ENDPOINT}
AllowedIPs = ${ALLOWED_IPS}
PersistentKeepalive = 25
CONF
chmod 600 "${PLAINTEXT_CONF}"

openssl enc -aes-256-cbc -pbkdf2 -salt -iter 200000 \
  -in "${PLAINTEXT_CONF}" \
  -out "${ENCRYPTED_CONF}" \
  -pass "file:${PASSPHRASE_FILE}"
chmod 600 "${ENCRYPTED_CONF}"

cat > "${PEER_BLOCK}" <<PEER
# ${NAME}
[Peer]
PublicKey = ${PUBLIC_KEY}
AllowedIPs = ${VPN_IP}/32
PEER

{
  echo ""
  cat "${PEER_BLOCK}"
} >> "${SERVER_PEERS_MODEL}"

printf '%s,%s,%s,%s,%s,%s,%s\n' \
  "${NAME}" "${PLATFORM}" "${VPN_IP}" "${PUBLIC_KEY}" "active" "$(iso_date)" "generated-by-new-client.sh" \
  >> "${CLIENT_REGISTRY}"

cat <<OUT
Created client '${NAME}'
  Platform: ${PLATFORM}
  VPN IP: ${VPN_IP}/32
  Tunnel mode: ${TUNNEL_MODE}
  Plaintext config: ${PLAINTEXT_CONF} (local only, gitignored)
  Encrypted config: ${ENCRYPTED_CONF}
  Peer block: ${PEER_BLOCK}

Next steps:
1. Add peer block to server wg0.conf on 192.168.0.116:
   sudo tee -a /etc/wireguard/wg0.conf < ${PEER_BLOCK}
2. Restart WireGuard on server:
   sudo systemctl restart wg-quick@wg0
3. Distribute encrypted config and decrypt on target machine:
   ./scripts/decrypt-client-config.sh ${NAME}
OUT
