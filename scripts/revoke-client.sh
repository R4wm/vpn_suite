#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

NAME=""

usage() {
  echo "Usage: $0 --name <client-id>"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="${2:-}"
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

if [[ -z "${NAME}" ]]; then
  echo "ERROR: --name is required" >&2
  usage
  exit 1
fi

if [[ ! -f "${CLIENT_REGISTRY}" ]]; then
  echo "ERROR: missing ${CLIENT_REGISTRY}" >&2
  exit 1
fi

TMP_FILE="$(mktemp)"
UPDATED=0
awk -F',' -v n="${NAME}" -v d="$(iso_date)" 'BEGIN{OFS=FS}
  NR==1{print;next}
  $1==n && $5=="active" {$5="revoked";$7="revoked-" d; updated=1}
  {print}
  END{if(updated==0) exit 2}
' "${CLIENT_REGISTRY}" > "${TMP_FILE}" || {
  rm -f "${TMP_FILE}"
  echo "ERROR: active client not found: ${NAME}" >&2
  exit 1
}

mv "${TMP_FILE}" "${CLIENT_REGISTRY}"

echo "Client '${NAME}' marked as revoked in ${CLIENT_REGISTRY}."
echo "Manual server action required: remove peer from /etc/wireguard/wg0.conf and restart wg-quick@wg0"
