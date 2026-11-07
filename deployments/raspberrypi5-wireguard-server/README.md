# Raspberry Pi 5 — WireGuard server + DMZ firewall

**Host:** `raspberrypi5` · `10.0.0.240` · WireGuard `wg0` UDP **51820**

When the home router **DMZ** targets this Pi, treat **`secure-dmz-firewall.sh`** as the public exposure policy.

## Policy

| Source | Allowed inbound |
|--------|-----------------|
| Internet | **TCP 22** (SSH), **UDP 51820** (WireGuard) |
| `10.0.0.0/24` (and site ULA v6) | All services (Samba, NFS, Plex, nginx, OpenSearch, etc.) |

Docker maps ports outside UFW’s normal INPUT path; the script installs **`DMZ_ONLY_PUBLIC`** on **`DOCKER-USER`** with the same WAN rules.

## Install / refresh

On the Pi, from a `vpn_suite` checkout:

```bash
cd ~/github/vpn_suite
sudo deployments/raspberrypi5-wireguard-server/secure-dmz-firewall.sh
```

Re-apply only the Docker chain after `docker` restarts:

```bash
sudo /usr/local/sbin/secure-dmz-firewall --docker-only
```

(`docker-user-firewall.service` runs that at boot.)

## Versioned rule snapshots

- [`firewall/ufw-user.rules.v4`](firewall/ufw-user.rules.v4) — UFW user INPUT policy (reference)
- [`firewall/docker-dmz-chain.rules.v4`](firewall/docker-dmz-chain.rules.v4) — `iptables` DOCKER-USER reference

## Verify before enabling router DMZ

From **LAN** (should still see Samba/nginx/etc.):

```bash
nmap -Pn -p 22,80,443,445,2049,9200 10.0.0.240
```

From **outside** the home network (e.g. VPS), against the published WAN IP — only **22/tcp** (and **51820/udp** once the router forwards it):

```bash
nmap -Pn -p 22,80,443,445,2049,9200,32400 <WAN_IP>
```

## Related

- [`../../scripts/publish-home-wan-ip.sh`](../../scripts/publish-home-wan-ip.sh) — updates `https://base.prsmusa.com/ip`
- `infra-docs` runbook `vpn-home-ip-publish.md`
