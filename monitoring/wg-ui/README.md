# WireGuard Web Dashboard (wg-ui)

This folder documents a non-Docker deployment of a WireGuard web dashboard for
`r4wm@192.168.0.116`.

## Goal
Expose VPN status (peers, handshake age, transfer) through a web UI while keeping
`wg-quick@wg0` as the active server model.

## Install Approach
1. Download `wireguard-ui` release binary on the server.
2. Install binary at `/usr/local/bin/wireguard-ui`.
3. Create `/etc/wireguard-ui/wireguard-ui.env` from `wireguard-ui.env.example`.
4. Install systemd service from `wg-ui.service`.
5. Bind UI to LAN or localhost only.
6. Protect with a strong admin password.

## Recommended Runtime Config
- Bind address: `127.0.0.1`
- Port: `51821`
- Reverse proxy (optional): nginx/Caddy with auth + TLS
- WireGuard config path: `/etc/wireguard/wg0.conf`

## Quick Verification
- `sudo systemctl status wg-ui`
- `ss -ltnp | grep 51821`
- Open `http://<server-ip>:51821/login` only from trusted LAN if LAN-bound.

## Security Notes
- Do not expose dashboard port to WAN directly.
- Keep dashboard credentials separate from SSH credentials.
- Back up `/etc/wireguard/wg0.conf` before any peer edits from UI.
