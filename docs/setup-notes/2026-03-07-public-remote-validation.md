# 2026-03-07 Public WireGuard Validation (Remote Client)

## Goal
Prove that remote internet clients can reach and connect to the WireGuard server through the double-NAT forwarding chain.

## Environment
- WireGuard server: `192.168.0.116` (`wg-quick@wg0`)
- Public endpoint used by client: `73.103.201.232:51820`
- Validated client profile: `onboarding_test1` (`10.8.0.5/32`)
- Remote test host: `prsmusa.com`

## Preconditions Met
- ER605 forwarding rule enabled:
  - `UDP 51820 -> 192.168.0.116:51820`
- Upstream router forwarding/DMZ path enabled toward ER605 WAN (`10.1.10.25`).
- WireGuard service active on server.

## Test Procedure
1. Decrypt client profile and set endpoint to public IP.
2. On remote host, bring up tunnel with short interface name (`wgprsm`).
3. Verify handshake and peer status with `wg show`.
4. Ping `10.8.0.1` from remote host.
5. Verify server-side handshake timestamp for same peer.
6. Bring down tunnel.

## Observed Result (PASS)
- Remote client `wg-quick up /tmp/wgprsm.conf` succeeded.
- Remote `wg show` displayed:
  - peer endpoint `73.103.201.232:51820`
  - `latest handshake: Now`
  - transfer counters incrementing.
- `ping -c 3 10.8.0.1` succeeded (3/3 replies).
- Server-side check confirmed handshake row for peer key `xqduxCGPPY2mkYzJOahEXN7rBeKZjRsT4HGoIZJ52ws=`.
- Tunnel teardown succeeded.

## Notes
- `wg-quick` config filename must map to a valid interface name. Avoid long dotted names.
  - Example working filename: `/tmp/wgprsm.conf`
- For same-LAN tests, LAN endpoint is fine.
- For remote tests, use public endpoint (`73.103.201.232:51820`).
