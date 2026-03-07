#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

if [[ ! -f "${CLIENT_REGISTRY}" ]]; then
  echo "ERROR: missing ${CLIENT_REGISTRY}" >&2
  exit 1
fi

printf '%-22s %-8s %-12s %-8s %-12s %s\n' "NAME" "PLATFORM" "VPN_IP" "STATUS" "CREATED" "PUBLIC_KEY"
awk -F',' 'NR>1 {printf "%-22s %-8s %-12s %-8s %-12s %s\n", $1, $2, $3, $5, $6, $4}' "${CLIENT_REGISTRY}"

echo
NEXT_IP="$(next_vpn_ip || true)"
if [[ -n "${NEXT_IP}" ]]; then
  echo "Next available VPN IP: ${NEXT_IP}"
else
  echo "Next available VPN IP: none"
fi
