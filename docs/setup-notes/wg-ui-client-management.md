# wg-ui Client Management Runbook

Yes, you can create and manage WireGuard clients from the web UI.

Dashboard URL:
- `http://192.168.0.116:51821/login`

## Recommended Workflow
1. Log in to wg-ui.
2. Go to `Clients`.
3. Click `New` / `Add Client`.
4. Fill client details:
   - Name: unique client id (example: `windows-laptop-01`)
   - Email/Description: optional label
   - Client IP: next free `/32` in `10.8.0.0/24`
5. Save client.
6. Download generated config (`.conf`) or use QR code (if shown).
7. Import config into WireGuard app on target device.
8. Activate tunnel and test (`ping 10.8.0.1`).

## Verify Connection
On VPN server (`192.168.0.116`):
```bash
sudo wg show wg0 latest-handshakes
sudo wg show wg0 transfer
```

You should see a recent handshake and non-zero transfer for the new client peer.

## Keep Repo in Sync (Important)
If you add clients in UI, update repo state so docs/scripts stay accurate.

Update these files:
- `state/clients.csv` (new client row)
- `state/server-peers.conf` (new peer block)
- `native-clients/encrypted/<client_id>.conf.enc` (if storing encrypted artifact)

Suggested sync process:
1. Export/download client `.conf` from wg-ui.
2. Save temporarily in `native-clients/plaintext/<client_id>.conf`.
3. Encrypt it:
   ```bash
   ./scripts/encrypt-client-configs.sh
   ```
4. Add row to `state/clients.csv` with status `active`.
5. Add peer block to `state/server-peers.conf`.

## Operational Note
Choose one primary management path for each client:
- Script-driven (`new-client.sh`) OR
- UI-driven (`wg-ui`)

Mixing both is fine, but always reconcile repo state after UI changes.

## Does the UI Itself Have Directions?
- wg-ui provides basic fields and workflow in-app.
- It does not replace your project-specific conventions (naming, IP allocation, encryption-in-repo policy), so keep using this runbook.
