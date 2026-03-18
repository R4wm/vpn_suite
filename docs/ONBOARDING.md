# Fresh Client Onboarding (Linux, Windows, macOS)

For platform-specific connect/test steps, see:
- `docs/CLIENT_QUICKSTART.md`
- `docs/WINDOWS_END_USER_CONNECT.md`
- `docs/MAC_END_USER_CONNECT.md`
- `docs/setup-notes/windows-client-test-runbook.md`

## Preconditions
- `state/server.env` has the correct server endpoint and public key.
- Local passphrase file exists (default `~/.config/vpn_suite/openssl_passphrase`).
- `wg`, `openssl`, and bash are installed on the machine running scripts.

## 1) Create a new client bundle
```bash
./scripts/new-client.sh --name <client_id> --platform <linux|windows|mac>
```

Optional full-tunnel profile:
```bash
./scripts/new-client.sh --name <client_id> --platform <linux|windows|mac> --tunnel full
```

Outputs:
- Encrypted config: `native-clients/encrypted/<client_id>.conf.enc`
- Plaintext local config (gitignored): `native-clients/plaintext/<client_id>.conf`
- Peer block: `state/<client_id>.peer`
- Registry update: `state/clients.csv`

## 2) Apply new peer to server
From your workstation:
```bash
ssh r4wm@192.168.0.116 "sudo tee -a /etc/wireguard/wg0.conf" < state/<client_id>.peer
ssh r4wm@192.168.0.116 "sudo systemctl restart wg-quick@wg0"
```

## 3) Decrypt for import
```bash
./scripts/decrypt-client-config.sh <client_id>
```

Result:
- `native-clients/plaintext/<client_id>.conf`

## 4) Import and connect
- Linux: copy to `/etc/wireguard/wg0.conf`, run `sudo wg-quick up wg0`
- Windows/macOS: import the `.conf` file in WireGuard app.

## 5) Verify
- Client: ping `10.8.0.1`
- Server: `ssh r4wm@192.168.0.116 "sudo wg show wg0 latest-handshakes"`

## Revoke
```bash
./scripts/revoke-client.sh --name <client_id>
```
Then remove peer from `/etc/wireguard/wg0.conf` on server and restart `wg-quick@wg0`.
