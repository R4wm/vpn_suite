#!/usr/bin/env bash
# Publish this host's public IPv4 to https://base.prsmusa.com/ip (VPS nginx serves the file).
# Intended for cron on the WireGuard server NAS (10.0.0.240).
#
# Prerequisites:
#   - Outbound SSH to prsmusa.com as r4wm with key allowed to run prsm-vpn-ip-publish only
#   - See infra-docs runbooks/vpn-home-ip-publish.md
#
# Env:
#   VPN_IP_PUBLISH_SSH     default r4wm@prsmusa.com
#   VPN_IP_PUBLISH_KEY     default ~/.ssh/prsmusa_vpn_ip_publish
#   VPN_IP_PUBLISH_STATE   default ~/.cache/vpn_suite/last-published-ipv4
#   VPN_IP_FETCH_URL       default https://ifconfig.me/ip (IPv4)
set -euo pipefail

SSH_TARGET="${VPN_IP_PUBLISH_SSH:-r4wm@prsmusa.com}"
KEY="${VPN_IP_PUBLISH_KEY:-$HOME/.ssh/prsmusa_vpn_ip_publish}"
STATE="${VPN_IP_PUBLISH_STATE:-$HOME/.cache/vpn_suite/last-published-ipv4}"
FETCH_URL="${VPN_IP_FETCH_URL:-https://ifconfig.me/ip}"

mkdir -p "$(dirname "$STATE")"

IP="$(curl -4 -fsS -m15 "$FETCH_URL" | tr -d '[:space:]')"
if [[ ! "$IP" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
  echo "publish-home-wan-ip: could not resolve public IPv4 from ${FETCH_URL}" >&2
  exit 1
fi

if [[ -f "$STATE" ]] && [[ "$(tr -d '[:space:]' <"$STATE")" == "$IP" ]]; then
  exit 0
fi

SSH=(ssh -o BatchMode=yes -o ConnectTimeout=15)
[[ -f "$KEY" ]] && SSH+=(-i "$KEY" -o IdentitiesOnly=yes)

if ! "${SSH[@]}" "$SSH_TARGET" "$IP" | grep -q "^ok "; then
  echo "publish-home-wan-ip: VPS publish failed for ${IP}" >&2
  exit 1
fi

printf '%s\n' "$IP" >"$STATE"
echo "published ${IP} -> https://base.prsmusa.com/ip"
