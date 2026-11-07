#!/usr/bin/env bash
# Firewall policy for Raspberry Pi 5 WireGuard server (10.0.0.240) when router DMZ points here.
#
# Internet (WAN): TCP 22 (SSH) and UDP 51820 (WireGuard) only.
# Trusted LAN: full access to NAS services (Samba, NFS, Plex, nginx, etc.).
# Docker-published ports bypass UFW INPUT; DOCKER-USER gets the same WAN policy.
#
# Run as root. Override if the host network changes:
#   LAN_V4_CIDR=10.0.0.0/24 LAN_V6_CIDR=fdac:3746:2b2e:a8e9::/64 \
#   WAN_IF=eth0 WG_PORT=51820 sudo ./secure-dmz-firewall.sh
#
# Idempotent docker hook only (after docker restarts):
#   sudo ./secure-dmz-firewall.sh --docker-only

set -euo pipefail

LAN_V4_CIDR="${LAN_V4_CIDR:-10.0.0.0/24}"
LAN_V6_CIDR="${LAN_V6_CIDR:-fdac:3746:2b2e:a8e9::/64}"
WAN_IF="${WAN_IF:-eth0}"
WG_PORT="${WG_PORT:-51820}"
INSTALL_PATH=/usr/local/sbin/secure-dmz-firewall
UNIT_PATH=/etc/systemd/system/docker-user-firewall.service
CHAIN=DMZ_ONLY_PUBLIC

apply_docker_user_chain() {
  for ipt in iptables ip6tables; do
    command -v "$ipt" >/dev/null || continue
    "$ipt" -N "$CHAIN" 2>/dev/null || true
    "$ipt" -F "$CHAIN"
    if ! "$ipt" -C DOCKER-USER -j "$CHAIN" 2>/dev/null; then
      "$ipt" -I DOCKER-USER 1 -j "$CHAIN"
    fi
    "$ipt" -A "$CHAIN" -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
    if [[ $ipt == iptables ]]; then
      "$ipt" -A "$CHAIN" -i "$WAN_IF" -s "$LAN_V4_CIDR" -j RETURN
      "$ipt" -A "$CHAIN" -i "$WAN_IF" -p tcp -m tcp --dport 22 -j RETURN
      "$ipt" -A "$CHAIN" -i "$WAN_IF" -p udp -m udp --dport "$WG_PORT" -j RETURN
    else
      "$ipt" -A "$CHAIN" -i "$WAN_IF" -s "$LAN_V6_CIDR" -j RETURN
      "$ipt" -A "$CHAIN" -i "$WAN_IF" -p tcp -m tcp --dport 22 -j RETURN
      "$ipt" -A "$CHAIN" -i "$WAN_IF" -p udp -m udp --dport "$WG_PORT" -j RETURN
    fi
    "$ipt" -A "$CHAIN" -i "$WAN_IF" -j DROP
    "$ipt" -A "$CHAIN" -j RETURN
  done
}

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo." >&2
  exit 1
fi

if [[ ${1:-} == --docker-only ]]; then
  apply_docker_user_chain
  exit 0
fi

if [[ $# -ne 0 ]]; then
  echo "Usage: $0 [--docker-only]" >&2
  exit 2
fi

command -v ufw >/dev/null || { echo "ufw is required." >&2; exit 1; }
ip link show "$WAN_IF" >/dev/null || { echo "Interface $WAN_IF does not exist." >&2; exit 1; }

# Reset UFW to a known policy (existing SSH sessions usually survive).
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed
ufw logging low

ufw allow from "$LAN_V4_CIDR" comment 'trusted IPv4 LAN'
ufw allow from "$LAN_V6_CIDR" comment 'trusted IPv6 LAN'
ufw allow 22/tcp comment 'SSH from Internet'
ufw allow "${WG_PORT}"/udp comment 'WireGuard'
ufw --force enable

SCRIPT_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
install -m 0755 "$SCRIPT_SOURCE" "$INSTALL_PATH"
cat >"$UNIT_PATH" <<UNIT
[Unit]
Description=Restrict Docker-published ports on the DMZ host
After=docker.service network-online.target
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
ExecStart=$INSTALL_PATH --docker-only
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now docker-user-firewall.service
"$INSTALL_PATH" --docker-only

echo "Firewall active: public TCP 22 and UDP ${WG_PORT} only."
echo "Trusted networks: $LAN_V4_CIDR and $LAN_V6_CIDR."
ufw status verbose
