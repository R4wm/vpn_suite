#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE_DIR="${REPO_ROOT}/state"
PLAINTEXT_DIR="${REPO_ROOT}/native-clients/plaintext"
ENCRYPTED_DIR="${REPO_ROOT}/native-clients/encrypted"
CLIENT_REGISTRY="${STATE_DIR}/clients.csv"
SERVER_ENV="${STATE_DIR}/server.env"
SERVER_PEERS_MODEL="${STATE_DIR}/server-peers.conf"

DEFAULT_PASSPHRASE_FILE="${HOME}/.config/vpn_suite/openssl_passphrase"
PASSPHRASE_FILE="${VPN_SUITE_PASSPHRASE_FILE:-${DEFAULT_PASSPHRASE_FILE}}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: required command not found: $1" >&2
    exit 1
  }
}

ensure_dirs() {
  mkdir -p "${PLAINTEXT_DIR}" "${ENCRYPTED_DIR}" "${STATE_DIR}"
}

load_server_env() {
  if [[ ! -f "${SERVER_ENV}" ]]; then
    echo "ERROR: missing ${SERVER_ENV}" >&2
    exit 1
  fi
  # shellcheck disable=SC1090
  source "${SERVER_ENV}"
}

ensure_passphrase_file() {
  if [[ ! -f "${PASSPHRASE_FILE}" ]]; then
    echo "ERROR: passphrase file not found at ${PASSPHRASE_FILE}" >&2
    echo "Create it with: mkdir -p \"$(dirname "${PASSPHRASE_FILE}")\" && chmod 700 \"$(dirname "${PASSPHRASE_FILE}")\" && printf '<strong-passphrase>' > \"${PASSPHRASE_FILE}\" && chmod 600 \"${PASSPHRASE_FILE}\"" >&2
    exit 1
  fi
}

next_vpn_ip() {
  awk -F',' '
    NR==1 {next}
    $5=="active" {
      split($3, a, ".")
      used[a[4]] = 1
    }
    END {
      for (i=2; i<=254; i++) {
        if (!used[i]) {
          print "10.8.0." i
          exit
        }
      }
      exit 1
    }
  ' "${CLIENT_REGISTRY}"
}

iso_date() {
  date +%F
}
