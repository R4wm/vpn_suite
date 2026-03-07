#!/usr/bin/env bash

set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

if [[ ! -x /usr/local/bin/wireguard-ui ]]; then
  echo "ERROR: /usr/local/bin/wireguard-ui not found. Install wireguard-ui binary first." >&2
  exit 1
fi

if [[ ! -f /etc/wireguard-ui/wireguard-ui.env ]]; then
  echo "ERROR: /etc/wireguard-ui/wireguard-ui.env not found." >&2
  echo "Use monitoring/wg-ui/wireguard-ui.env.example as template." >&2
  exit 1
fi

install -m 0644 "$(dirname "$0")/wg-ui.service" /etc/systemd/system/wg-ui.service
systemctl daemon-reload
systemctl enable --now wg-ui.service
systemctl status --no-pager wg-ui.service
