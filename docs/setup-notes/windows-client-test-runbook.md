# Windows Client Test Runbook (WireGuard)

Use this checklist to test from a Windows laptop against the public VPN endpoint.

## Target Values
- Public endpoint: `73.103.201.232:51820`
- VPN server IP: `10.8.0.1`
- Expected protocol: UDP

## 1) Prepare Client Profile on Workstation
From `/home/r4wm/github/vpn_suite`:

```bash
./scripts/decrypt-client-config.sh <client_id>
```

Edit the decrypted file `native-clients/plaintext/<client_id>.conf` and set:
- `Endpoint = 73.103.201.232:51820`

Recommended first test route (split tunnel):
- `AllowedIPs = 10.8.0.0/24`

Optional full tunnel after baseline success:
- `AllowedIPs = 0.0.0.0/0`

## 2) Import on Windows
1. Open WireGuard for Windows.
2. Click `Import tunnel(s) from file`.
3. Select `<client_id>.conf`.
4. Confirm tunnel details and click `Activate`.

## 3) Validate from Windows
PowerShell checks:

```powershell
ping 10.8.0.1
curl ifconfig.me
```

Expected:
- Ping to `10.8.0.1` succeeds.
- If split tunnel: public IP may remain your local ISP.
- If full tunnel: public IP should appear as home WAN/public IP path.

## 4) Validate on VPN Server
On `192.168.0.116`:

```bash
sudo wg show wg0 latest-handshakes
sudo wg show wg0 transfer
```

Expected:
- Target client public key has recent handshake timestamp.
- Transfer counters increase while traffic flows.

## 5) Live Troubleshooting (Server)
```bash
sudo journalctl -u wg-quick@wg0 -f
watch -n 1 'sudo wg show wg0'
sudo tcpdump -n -i any udp port 51820
```

## Common Failure Checks
- Endpoint typo: must be `73.103.201.232:51820`.
- Wrong client file/private key.
- Peer block missing on server `wg0.conf`.
- Upstream router forward missing to `10.1.10.25`.
- ER605 forward missing to `192.168.0.116`.
- Windows local firewall/VPN adapter interference.
