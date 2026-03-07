# WireGuard Client Quickstart (Linux, Windows, macOS)

This is the fastest reference for onboarding a new client device.
Android is intentionally deferred for now.

## Shared Inputs
- Public endpoint: `73.103.201.232:51820`
- Server VPN IP: `10.8.0.1`
- Config source: `native-clients/plaintext/<client_id>.conf` (generated via decrypt)

## 0) Prepare Client Config (from repo host)
```bash
cd /home/r4wm/github/vpn_suite
./scripts/decrypt-client-config.sh <client_id>
```

Edit endpoint in `native-clients/plaintext/<client_id>.conf`:
```ini
Endpoint = 73.103.201.232:51820
```

Recommended first test route:
```ini
AllowedIPs = 10.8.0.0/24
```

## Linux
1. Copy config to target Linux machine as `/etc/wireguard/wg0.conf`.
2. Set permissions:
```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```
3. Bring tunnel up:
```bash
sudo wg-quick up wg0
```
4. Verify:
```bash
sudo wg show wg0
ping -c 3 10.8.0.1
```
5. Teardown:
```bash
sudo wg-quick down wg0
```

## Windows
1. Install WireGuard client from official installer.
2. Open WireGuard app -> `Import tunnel(s) from file`.
3. Select `<client_id>.conf`.
4. Click `Activate`.
5. Verify in PowerShell:
```powershell
ping 10.8.0.1
```
6. Deactivate tunnel in UI when done.

## macOS
1. Install WireGuard from App Store.
2. Import `<client_id>.conf`.
3. Toggle tunnel `On`.
4. Verify in terminal:
```bash
ping -c 3 10.8.0.1
```
5. Toggle tunnel `Off` when done.

## Server-Side Verification
On `192.168.0.116`:
```bash
sudo wg show wg0 latest-handshakes
sudo wg show wg0 transfer
```

## Troubleshooting Fast Checks
- Endpoint must be `73.103.201.232:51820` for external clients.
- Upstream forward: `UDP 51820 -> 10.1.10.25`.
- ER605 forward: `UDP 51820 -> 192.168.0.116`.
- Client peer must exist in server `/etc/wireguard/wg0.conf`.

## Deferred
- Android onboarding will be documented in a follow-up runbook.
