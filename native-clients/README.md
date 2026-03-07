# Native WireGuard Client Configurations

This directory contains pre-configured WireGuard profiles for native clients (Windows, macOS, Linux, mobile devices).

## Available Clients

- **client2.conf** - VPN IP: 10.8.0.3/32
- **client3.conf** - VPN IP: 10.8.0.4/32
- **client4.conf** - VPN IP: 10.8.0.5/32

## Setup Instructions

### 1. Update the Endpoint

Before using any client configuration, you MUST update the `Endpoint` line with your server's public IP address:

```ini
Endpoint = YOUR_SERVER_PUBLIC_IP:51820
```

Replace `YOUR_SERVER_PUBLIC_IP` with the actual public IP address where your WireGuard server is running.

### 2. Platform-Specific Setup

#### Windows
1. Download and install [WireGuard for Windows](https://www.wireguard.com/install/)
2. Click "Add Tunnel" → "Add empty tunnel..." or "Import tunnel(s) from file"
3. If importing, select one of the `.conf` files
4. If creating empty, copy the contents of a `.conf` file into the editor
5. Update the `Endpoint` with your server's public IP
6. Click "Activate"

#### macOS
1. Download and install [WireGuard from the App Store](https://apps.apple.com/us/app/wireguard/id1451685025)
2. Click "Import tunnel(s) from file..." or "Add Empty Tunnel"
3. Select one of the `.conf` files
4. Update the `Endpoint` with your server's public IP
5. Toggle the connection on

#### Linux
1. Install WireGuard: `sudo apt install wireguard` (Debian/Ubuntu) or equivalent
2. Copy a client config to `/etc/wireguard/`:
   ```bash
   sudo cp client2.conf /etc/wireguard/wg0.conf
   ```
3. Update the `Endpoint` in `/etc/wireguard/wg0.conf`
4. Set proper permissions:
   ```bash
   sudo chmod 600 /etc/wireguard/wg0.conf
   ```
5. Start the VPN:
   ```bash
   sudo wg-quick up wg0
   ```
6. To stop:
   ```bash
   sudo wg-quick down wg0
   ```
7. To enable at boot:
   ```bash
   sudo systemctl enable wg-quick@wg0
   ```

#### Mobile (iOS/Android)
1. Install the WireGuard app from App Store or Google Play
2. Option A - Manual entry:
   - Tap "+" → "Create from scratch"
   - Copy the configuration from one of the `.conf` files
   - Update the `Endpoint` with your server's public IP
3. Option B - QR Code:
   - Generate a QR code from the config file:
     ```bash
     qrencode -t ansiutf8 < client2.conf
     ```
   - Scan the QR code with the WireGuard app

## Testing Your Connection

After connecting, verify the VPN is working:

### Check VPN Connectivity
```bash
# Ping the VPN server
ping 10.8.0.1

# Should receive replies from the server
```

### Verify Your Public IP
```bash
# Check your public IP (should show server's IP, not your real IP)
curl ifconfig.me
```

### Test DNS Resolution
```bash
# Should resolve through VPN DNS (1.1.1.1)
nslookup google.com
```

## Security Notes

1. **Keep Private Keys Secure**: Never share your `.conf` files or private keys
2. **File Permissions**: On Unix systems, always set config files to `600` permissions
3. **Backup Configs**: Save a secure backup of your configuration file
4. **Unique Configs**: Each device should use a different client configuration

## Troubleshooting

### Cannot Connect
- Verify the `Endpoint` has the correct server IP address
- Ensure UDP port 51820 is open on the server firewall
- Check that the server container is running: `docker ps`

### Connected But No Internet
- Verify server is routing traffic: `docker exec wireguard-server wg show`
- Check server's NAT rules are active
- Ensure AllowedIPs is set to `0.0.0.0/0` for full tunnel

### DNS Not Working
- Verify DNS servers are set in the `[Interface]` section
- Try manual DNS: `1.1.1.1, 1.0.0.1`
- On Linux, you may need to install `resolvconf` or `openresolv`

## Adding More Clients

To add additional clients beyond client2-4, use the provided script:

```bash
cd /path/to/vpn_suite
./scripts/add-client.sh 6  # For 10.8.0.6
```

See the main project README for detailed instructions.
