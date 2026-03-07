#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/_common.sh
source "${SCRIPT_DIR}/_common.sh"

require_cmd openssl
ensure_dirs
ensure_passphrase_file

shopt -s nullglob
count=0
for conf in "${PLAINTEXT_DIR}"/*.conf; do
  base="$(basename "${conf}")"
  out="${ENCRYPTED_DIR}/${base}.enc"
  openssl enc -aes-256-cbc -pbkdf2 -salt -iter 200000 \
    -in "${conf}" \
    -out "${out}" \
    -pass "file:${PASSPHRASE_FILE}"
  chmod 600 "${out}"
  echo "Encrypted: ${out}"
  count=$((count + 1))
done

if [[ "${count}" -eq 0 ]]; then
  echo "No plaintext configs found in ${PLAINTEXT_DIR}"
else
  echo "Encrypted ${count} config(s)."
fi
