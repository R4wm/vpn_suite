#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

NAME="${1:-}"
OUT_PATH=""

if [[ -z "${NAME}" ]]; then
  echo "Usage: $0 <client-name> [--output <path>]" >&2
  exit 1
fi
shift || true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUT_PATH="${2:-}"
      shift 2
      ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
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

mkdir -p "$(dirname "${OUT_PATH}")"
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
  -in "${IN_PATH}" \
  -out "${OUT_PATH}" \
  -pass "file:${PASSPHRASE_FILE}"
chmod 600 "${OUT_PATH}"

echo "Decrypted to: ${OUT_PATH}"
