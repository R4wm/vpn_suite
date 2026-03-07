# WireGuard Status Dashboard

## Selected Stack
`wg-ui` running as a systemd service on `r4wm@192.168.0.116`.

## Why
- Works with native WireGuard (`wg-quick`) setup.
- Provides peer/handshake/transfer visibility in browser.
- Can be installed without Docker.

## Deployment Files
- `monitoring/wg-ui/wg-ui.service`
- `monitoring/wg-ui/wireguard-ui.env.example`
- `monitoring/wg-ui/install.sh`
- `monitoring/wg-ui/README.md`

## Install Steps (server)
1. Download a `wg-ui` release binary and place it at `/usr/local/bin/wg-ui`.
2. Place it at `/usr/local/bin/wireguard-ui` and set executable mode.
3. Copy `monitoring/wg-ui/wireguard-ui.env.example` to `/etc/wireguard-ui/wireguard-ui.env` and set real secrets.
4. Copy this repo folder to server or pull repo there.
5. Run:
   ```bash
   sudo ./monitoring/wg-ui/install.sh
   ```

## Security Defaults
- Bind UI to `127.0.0.1:51821` by default.
- Do not expose dashboard directly to WAN.
- If remote access is required, use SSH tunnel or reverse proxy with TLS and auth.
