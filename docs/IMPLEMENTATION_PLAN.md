# Native WireGuard Validation + Repeatable Onboarding Plan

## Summary
Primary objective is:
1. prove native client connectivity from this Linux machine to `r4wm@192.168.0.116`
2. define a repeatable, script-driven onboarding flow for any fresh Linux/Windows/macOS client
3. store client secrets in repo as OpenSSL-encrypted artifacts only.

## Locked Decisions
- Ignore Docker for now.
- Use existing Linux peer first for initial bring-up.
- Use split tunnel first.
- Store secrets with OpenSSL encryption.
- Passphrase comes from local passphrase file.
- New machine onboarding model: server-generated bundle.
- Add a WireGuard web dashboard service for status visibility.

## Implementation Plan

1. Baseline and source-of-truth capture
- Treat live server (`192.168.0.116`, native `wg-quick`) as source of truth.
- Save non-secret server state snapshot in repo docs (`state/`), including peer IP mapping and interface settings.

2. Initial native validation from current Linux machine
- Build local test config for existing Linux peer (`10.8.0.3`) against `192.168.0.116:51820`.
- Use split tunnel (`AllowedIPs = 10.8.0.0/24, 192.168.0.0/24`).
- Validate handshake, ping `10.8.0.1`, and route correctness.

3. Repo secret hygiene refactor
- Convert tracked client/server configs to templates (no private keys).
- Add and enforce ignore rules for plaintext keys/configs.
- Keep encrypted artifacts only in tracked paths.

4. Add deterministic onboarding scripts
- Add `scripts/new-client.sh` (single entrypoint) to:
  - allocate next free VPN IP
  - generate keypair for new client
  - append peer block to server config model
  - produce ready-to-import client config
  - encrypt config into `native-clients/encrypted/<client>.conf.enc`
  - emit exact OS import instructions
- Add `scripts/list-clients.sh` to show assigned clients and next available IP.
- Add `scripts/revoke-client.sh` to remove peer and mark allocation as retired.

5. Encryption/decryption tooling
- `scripts/encrypt-client-configs.sh` for batch encryption.
- `scripts/decrypt-client-config.sh <client>` for one-client decrypt.
- Use OpenSSL: `aes-256-cbc + pbkdf2 + salt + iter 200000`.
- Passphrase file:
  - default `~/.config/vpn_suite/openssl_passphrase`
  - override `VPN_SUITE_PASSPHRASE_FILE`.

6. Client registry for repeatability
- Track non-secret inventory in `state/clients.csv` with:
  - client name
  - vpn IP
  - platform
  - public key
  - status (active/revoked)
  - created date
- Scripts use this registry to prevent collisions and preserve deterministic allocation.

7. Documentation updates
- Add Fresh Client Onboarding runbook with one-command flow.
- Add OS-specific import steps for Linux/Windows/macOS from decrypted config.
- Add rotate/revoke/reissue procedures.
- Add troubleshooting path for handshake failures.

8. Dashboard deployment
- Add WireGuard web dashboard runbook and systemd service template.
- Default deployment mode is local bind on server LAN only.

9. Git initialization with clean history
- Create initial commits only after verifying no plaintext secrets are staged.
- Commit structure:
  - docs and state model
  - onboarding/encryption scripts
  - encrypted client artifacts.

## Public Interfaces and Contracts
- `scripts/new-client.sh --name <id> --platform <linux|windows|mac> [--endpoint <ip:port>] [--tunnel split|full]`
- `scripts/decrypt-client-config.sh <id> [--output <path>]`
- `scripts/revoke-client.sh --name <id>`
- `scripts/list-clients.sh`

## Test Requirements

1. Existing Linux client validation
- Connect succeeds, handshake present, ping server VPN IP succeeds.

2. Fresh client onboarding test (hard requirement)
- Run `new-client.sh` for a brand-new test client ID.
- Decrypt generated artifact.
- Import on a fresh client (or clean local test profile).
- Connect and verify:
  - handshake appears on server for new peer
  - ping `10.8.0.1` succeeds
  - assigned IP matches registry
  - no existing peers regress.

3. Repeatability test
- Run onboarding twice for two distinct new IDs.
- Confirm deterministic next-IP allocation and no collisions.
- Confirm both clients can connect independently.

4. Secret handling test
- `.enc` files decrypt correctly with passphrase file.
- wrong passphrase fails.
- no plaintext key/config files tracked by git.

5. Dashboard test
- Web UI reachable on configured host and port.
- Displays current peer status.
- Service restarts on reboot.

## Assumptions and Defaults
- Current live server config remains authoritative until explicit key rotation phase.
- First test endpoint is LAN `192.168.0.116:51820`; public router port-forwarding comes later.
- Onboarding defaults to split tunnel for first connect; full tunnel can be enabled per client via flag.
