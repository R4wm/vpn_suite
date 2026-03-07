# 2026-03-07 wg-ui Deployment

## Server
- Host: `192.168.0.116`
- Service: `wg-ui.service`
- Binary: `/usr/local/bin/wireguard-ui`
- Env file: `/etc/wireguard-ui/wireguard-ui.env`

## Runtime
- Bind: `0.0.0.0:51821`
- Status: active
- URL (LAN): `http://192.168.0.116:51821/login`

## Commands
```bash
sudo systemctl status wg-ui
sudo journalctl -u wg-ui -f
sudo ss -ltnp | grep 51821
```

## Secret Handling
- Do not store dashboard password/session secret in git.
- Rotate credentials by editing `/etc/wireguard-ui/wireguard-ui.env` and restarting service:
  - `sudo systemctl restart wg-ui`
