# Server Prerequisites (Must Exist Outside Git)

This project intentionally does not store live private secrets in git.
Before clients can connect successfully, these must exist on the VPN server (`192.168.0.116`).

## Required Runtime State
1. WireGuard service
- `wg-quick@wg0` installed and running.
- Check:
  ```bash
  sudo systemctl status wg-quick@wg0
  sudo wg show wg0
  ```

2. Live WireGuard config
- `/etc/wireguard/wg0.conf` exists and includes:
  - server interface config (`Address`, `ListenPort`, `PrivateKey`)
  - peer blocks for clients

3. Key material on server
- `/etc/wireguard/server_private.key`
- `/etc/wireguard/server_public.key`
- Client key files if you are using server-hosted key inventory.

4. Host firewall/network
- UDP `51820` allowed inbound to server host.

## Network Prerequisites (Current Topology)
Current topology is double NAT:
- Upstream router -> ER605 -> server (`192.168.0.116`)

Required forwarding chain:
1. Upstream router forwards `UDP 51820` to ER605 WAN (`10.1.10.25`).
2. ER605 forwards `UDP 51820` to `192.168.0.116:51820`.

## Client Endpoint Rules
- Remote/public clients use:
  - `Endpoint = 73.103.201.232:51820`
- Same-LAN tests may use:
  - `Endpoint = 192.168.0.116:51820`

## Optional Dashboard Prerequisites
If using wg-ui dashboard:
- `/usr/local/bin/wireguard-ui`
- `/etc/wireguard-ui/wireguard-ui.env`
- `wg-ui.service` active
- URL: `http://192.168.0.116:51821/login`

## Repo vs Server Separation
Tracked in git:
- Scripts, docs, templates, sanitized state, encrypted client artifacts.

Not tracked in git:
- Live server private keys
- Live `/etc/wireguard/wg0.conf` with real private key
- Dashboard credentials/session secret
- Raw router backups unless explicitly reviewed and approved
