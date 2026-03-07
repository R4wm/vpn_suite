# 2026-03-07 Network and VPN Change Log

## Scope
Bring WireGuard server online for LAN testing first, then prepare path for public internet access through double NAT.

## VPN Server State
- WireGuard server host: `192.168.0.116`
- Service mode: native `wg-quick@wg0` (not Docker)
- WireGuard listen port: UDP `51820`
- Confirmed working LAN tunnel and handshake from test client.

## Client Provisioning and Validation
- Added repeatable onboarding scripts and encrypted client artifact workflow.
- Created and validated fresh client `onboarding_test1` (`10.8.0.5`).
- Revoked and cleaned up failed test client `thinkpad_win` to avoid confusion.

## Router Topology (Double NAT)
- ER605 LAN gateway: `192.168.0.1`
- ER605 WAN: `10.1.10.25`
- Upstream router gateway: `10.1.10.1` (CBR2-T)
- Public IP observed from LAN: `73.103.201.232`

## Port Forwarding Chain Required
1. Upstream router (CBR2-T):
   - Forward `UDP 51820` to `10.1.10.25` (ER605 WAN)
2. ER605:
   - Forward `UDP 51820` to `192.168.0.116:51820` (WireGuard server)

Without both hops, public inbound WireGuard will fail.

## Endpoint Guidance
- Remote/public clients should use:
  - `Endpoint = 73.103.201.232:51820` (or DDNS hostname)
- Same-LAN testing should use:
  - `Endpoint = 192.168.0.116:51820`

## Router Backup
- Backed up ER605 config and copied into repo:
  - `backups/router/er605/backup-ER605-2026-03-07.bin`

## Monitoring Commands
On server `192.168.0.116` during connection tests:
```bash
sudo journalctl -u wg-quick@wg0 -f
watch -n 1 'sudo wg show wg0'
sudo tcpdump -n -i any udp port 51820
```
