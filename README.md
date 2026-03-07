# WireGuard VPN Suite

This repository now prioritizes a native WireGuard server and repeatable client onboarding.
Current live server source of truth: `r4wm@192.168.0.116` (`wg-quick@wg0`).

## Current Focus
- Validate native Linux client connectivity to server first.
- Provision new clients with a repeatable script workflow.
- Store client configs encrypted in git (`native-clients/encrypted/*.conf.enc`).
- Add a web dashboard for VPN status (wg-ui systemd deployment).

## Security Model
- No plaintext private keys are committed.
- Plaintext client configs are local-only in `native-clients/plaintext/` (gitignored).
- Encrypted artifacts are tracked under `native-clients/encrypted/`.
- OpenSSL encryption settings:
  - AES-256-CBC
  - PBKDF2 + salt
  - 200000 iterations

Passphrase file:
- default: `~/.config/vpn_suite/openssl_passphrase`
- override: `VPN_SUITE_PASSPHRASE_FILE`

## Native Workflow

### Test current native connectivity
```bash
./scripts/test-native-connection.sh
```

### Provision a fresh client (repeatable)
```bash
./scripts/new-client.sh --name <client_id> --platform <linux|windows|mac>
```

### List clients and next available IP
```bash
./scripts/list-clients.sh
```

### Decrypt a client profile for import
```bash
./scripts/decrypt-client-config.sh <client_id>
```

### Revoke a client
```bash
./scripts/revoke-client.sh --name <client_id>
```

## Step-by-Step: Add and Test a Fresh Client

Run from repo root: `/home/r4wm/github/vpn_suite`

1. Create passphrase file (one-time):
```bash
mkdir -p ~/.config/vpn_suite
chmod 700 ~/.config/vpn_suite
printf 'CHOOSE_A_STRONG_PASSPHRASE' > ~/.config/vpn_suite/openssl_passphrase
chmod 600 ~/.config/vpn_suite/openssl_passphrase
```

2. Generate a new client bundle:
```bash
./scripts/new-client.sh --name <client_id> --platform <linux|windows|mac>
```

3. Add new peer to server and restart WireGuard:
```bash
ssh r4wm@192.168.0.116 "sudo tee -a /etc/wireguard/wg0.conf" < state/<client_id>.peer
ssh r4wm@192.168.0.116 "sudo systemctl restart wg-quick@wg0"
```

4. Decrypt client config for import:
```bash
./scripts/decrypt-client-config.sh <client_id>
```
This writes `native-clients/plaintext/<client_id>.conf` locally (gitignored).

5. Import on target machine:
- Linux: copy to `/etc/wireguard/wg0.conf`, then `sudo wg-quick up wg0`
- Windows/macOS: import `.conf` in WireGuard app and activate tunnel

6. Verify connection:
```bash
ping -c 3 10.8.0.1
ssh r4wm@192.168.0.116 "sudo wg show wg0 latest-handshakes"
```

7. Optional cleanup on this workstation (keeps encrypted artifact only):
```bash
rm -f native-clients/plaintext/<client_id>.conf
```

## Dashboard
See `docs/DASHBOARD.md` and `monitoring/wg-ui/` for non-Docker wg-ui deployment.

## Public Exposure Notes
- You do **not** set public IP in server `wg0.conf` for WireGuard itself.
- You **do** set public endpoint in each client profile:
  - `Endpoint = <public-ip-or-dns>:51820`
- When testing on the same LAN as the server, use the LAN endpoint instead:
  - `Endpoint = 192.168.0.116:51820`
- If you switch to public endpoint from inside your LAN, your router must support NAT loopback/hairpin NAT.
- Keep UDP `51820` open/forwarded to the WireGuard server host.

## Docs
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/ONBOARDING.md`
- `docs/CLIENT_QUICKSTART.md`
- `docs/SERVER_PREREQUISITES.md`
- `docs/DASHBOARD.md`
- `docs/setup-notes/windows-client-test-runbook.md`
- `docs/setup-notes/2026-03-07-public-remote-validation.md`
- `docs/setup-notes/wg-ui-client-management.md`
- `state/server-wg0.sanitized.conf`
- `state/clients.csv`

## Notes
- Docker files are still present but currently deferred.
- Router port-forwarding/public endpoint work is intentionally after LAN-native validation.
