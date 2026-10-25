#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

NAME="${1:-}"
OUT_PATH=""
ENDPOINT_OVERRIDE=""

usage() {
  cat <<USAGE
Usage: $0 <client-name> [--endpoint <host:port>] [--output <path>]

Examples:
  $0 gabf_windows
  $0 gabf_windows --endpoint 73.103.201.232:51820 --output native-clients/plaintext/gabf_windows-remote.conf
USAGE
}

if [[ -z "${NAME}" ]]; then
  usage >&2
  exit 1
fi
shift || true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --endpoint)
      ENDPOINT_OVERRIDE="${2:-}"
      shift 2
      ;;
    --output)
      OUT_PATH="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_cmd openssl
ensure_dirs
ensure_passphrase_file

IN_PATH="${ENCRYPTED_DIR}/${NAME}.conf.enc"
if [[ ! -f "${IN_PATH}" ]]; then
  echo "ERROR: encrypted config not found: ${IN_PATH}" >&2
  exit 1
fi

if [[ -z "${OUT_PATH}" ]]; then
  OUT_PATH="${PLAINTEXT_DIR}/${NAME}.conf"
fi

TMP_CONF="$(mktemp)"
trap 'rm -f "${TMP_CONF}"' EXIT

openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
  -in "${IN_PATH}" \
  -out "${TMP_CONF}" \
  -pass "file:${PASSPHRASE_FILE}"

mkdir -p "$(dirname "${OUT_PATH}")"

if [[ -n "${ENDPOINT_OVERRIDE}" ]]; then
  awk -v endpoint="${ENDPOINT_OVERRIDE}" '
    /^Endpoint = / {$0 = "Endpoint = " endpoint}
    {print}
  ' "${TMP_CONF}" > "${OUT_PATH}"
else
  cp "${TMP_CONF}" "${OUT_PATH}"
fi

chmod 600 "${OUT_PATH}"
echo "Rendered to: ${OUT_PATH}"
