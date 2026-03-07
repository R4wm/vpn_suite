#!/usr/bin/env bash

set -euo pipefail

MOUNTPOINT="${1:-/mnt/nas-share}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: $0 [mountpoint]"
  echo "Default mountpoint: /mnt/nas-share"
  exit 0
fi

if ! mountpoint -q "${MOUNTPOINT}"; then
  echo "Not mounted: ${MOUNTPOINT}"
  exit 0
fi

echo "Unmounting ${MOUNTPOINT}"
sudo umount "${MOUNTPOINT}"
echo "Unmounted."
