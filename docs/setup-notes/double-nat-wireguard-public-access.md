# WireGuard Public Access Behind Double NAT

Date: 2026-03-07

## Observed Topology
- WireGuard server host: `192.168.0.116`
- ER605 router LAN gateway: `192.168.0.1`
- ER605 WAN IP: `10.1.10.25`
- ER605 WAN gateway (upstream router): `10.1.10.1`

This is a double-NAT setup:
- Internet -> Upstream Router -> ER605 -> WireGuard Server

## Required Port-Forward Chain (UDP 51820)
1. On ER605:
- Forward `UDP 51820` to `192.168.0.116:51820`

2. On upstream router (`10.1.10.1`):
- Forward `UDP 51820` to `10.1.10.25:51820`

Without both forwards, inbound WireGuard from the public internet will fail.

## WireGuard Client Endpoint
For remote internet clients, set:
- `Endpoint = <public-ip-or-ddns>:51820`

Notes:
- Do not use `192.168.0.116` for remote/public clients.
- Do not use `10.1.10.25` for remote/public clients.
- `192.168.0.116` is only for same-LAN testing.

## Firewall Requirements
- WireGuard server host must allow inbound `UDP 51820`.
- ER605 firewall must allow corresponding inbound/NATed traffic.

## CGNAT / Upstream Check
Because ER605 WAN is private (`10.1.10.25`), verify whether upstream router is truly public-facing:
1. On a LAN host (or server):
   - `curl ifconfig.me`
2. Compare with upstream router WAN IP shown in its admin UI.

If they do not match (or upstream WAN is private/CGNAT), direct inbound may not work from internet.

## Validation Plan
1. Local LAN test first:
- Client endpoint `192.168.0.116:51820`
- Confirm handshake + ping `10.8.0.1`

2. Public test (after both forwards):
- Client endpoint `<public-ip-or-ddns>:51820`
- Test from external network (mobile hotspot or offsite device)
- Verify handshake on server: `sudo wg show wg0 latest-handshakes`

## Live Monitoring During Test
On server `192.168.0.116`:
- `sudo journalctl -u wg-quick@wg0 -f`
- `watch -n 1 'sudo wg show wg0'`
- `sudo tcpdump -n -i any udp port 51820`
