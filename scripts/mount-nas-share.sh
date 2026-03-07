#!/usr/bin/env bash

set -euo pipefail

SERVER="${1:-192.168.0.116}"
SHARE="${2:-NAS}"
MOUNTPOINT="${3:-/mnt/nas-share}"

usage() {
  cat <<USAGE
Usage: $0 [server_ip] [share_name] [mountpoint]

Defaults:
  server_ip  : 192.168.0.116
  share_name : NAS
  mountpoint : /mnt/nas-share

Examples:
  $0
  $0 192.168.0.116 NAS /mnt/nas-share
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if mountpoint -q "${MOUNTPOINT}"; then
  echo "Already mounted: ${MOUNTPOINT}"
  exit 0
fi

sudo mkdir -p "${MOUNTPOINT}"

echo "Mounting //${SERVER}/${SHARE} -> ${MOUNTPOINT}"
sudo mount -t cifs "//${SERVER}/${SHARE}" "${MOUNTPOINT}" \
  -o guest,uid="$(id -u)",gid="$(id -g)",file_mode=0664,dir_mode=0775

echo "Mounted successfully."
echo "List files with: ls -la ${MOUNTPOINT}"
