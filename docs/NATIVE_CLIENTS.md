# Native WireGuard Client Setup Guide

This guide provides detailed instructions for setting up WireGuard clients on various platforms using the pre-configured client files.

## Available Client Configurations

- **client2.conf** - VPN IP: 10.8.0.3/32
- **client3.conf** - VPN IP: 10.8.0.4/32
- **client4.conf** - VPN IP: 10.8.0.5/32

Each configuration includes:
- Unique VPN IP address
- Pre-generated private/public key pair
- DNS configuration (Cloudflare: 1.1.1.1, 1.0.0.1)
- Full tunnel routing (all traffic through VPN)
- Persistent keepalive (25 seconds)

## Before You Begin

### 1. Update Server Endpoint

All client configs have a placeholder for the server's public IP. You MUST update this before use:

Open your client config and find:
```ini
Endpoint = YOUR_SERVER_PUBLIC_IP:51820
```

Replace `YOUR_SERVER_PUBLIC_IP` with your actual server IP address:
```ini
Endpoint = 203.0.113.42:51820
```

### 2. Get Your Server's Public IP

If your server is deployed:
```bash
# On the server machine
curl ifconfig.me
```

Or check your cloud provider's dashboard.

## Platform-Specific Setup

### Windows

#### Installation

1. **Download WireGuard**:
   - Visit [https://www.wireguard.com/install/](https://www.wireguard.com/install/)
   - Download "WireGuard Installer"
   - Run the installer (requires Administrator)

2. **Import Configuration**:

   **Method A - Import File**:
   - Open WireGuard application
   - Click "Import tunnel(s) from file"
   - Select your client config (e.g., `client2.conf`)
   - Update the Endpoint with your server's IP
   - Click "Save"

   **Method B - Manual Entry**:
   - Open WireGuard application
   - Click "Add empty tunnel..."
   - Copy contents from your client config file
   - Paste into the editor
   - Update the Endpoint with your server's IP
   - Name the tunnel (e.g., "My VPN")
   - Click "Save"

3. **Connect**:
   - Select your tunnel from the list
   - Click "Activate"
   - Status should change to "Active"

#### Verification

```powershell
# Check VPN IP
ipconfig | findstr "10.8.0"

# Test connectivity
ping 10.8.0.1

# Check public IP
curl ifconfig.me
```

#### Troubleshooting

- **Installation fails**: Run as Administrator
- **Activate fails**: Check Windows Firewall isn't blocking
- **No internet**: Disable "Kill Switch" if enabled
- **DNS not working**: Check DNS settings in adapter properties

### macOS

#### Installation

1. **Install WireGuard**:
   - Open App Store
   - Search for "WireGuard"
   - Click "Get" / "Install"
   - Or direct link: [WireGuard on App Store](https://apps.apple.com/us/app/wireguard/id1451685025)

2. **Import Configuration**:

   **Method A - Drag and Drop**:
   - Open WireGuard app
   - Drag your `.conf` file into the app window
   - Edit the configuration
   - Update the Endpoint with your server's IP
   - Click "Save"

   **Method B - Import Button**:
   - Open WireGuard app
   - Click "Import tunnel(s) from file..."
   - Select your client config
   - Edit and update Endpoint
   - Click "Save"

   **Method C - Manual Entry**:
   - Open WireGuard app
   - Click "Add Empty Tunnel"
   - Copy contents from your client config
   - Paste into editor
   - Update Endpoint
   - Name the tunnel
   - Click "Save"

3. **Connect**:
   - Toggle the switch next to your tunnel name
   - Status should show "Active"

#### Verification

```bash
# Check VPN interface
ifconfig | grep -A 4 utun

# Test connectivity
ping 10.8.0.1

# Check public IP
curl ifconfig.me

# DNS test
nslookup google.com
```

#### Troubleshooting

- **Permission error**: Grant VPN permissions in System Preferences → Security & Privacy
- **No internet**: Check "Allow apps downloaded from App Store and identified developers"
- **Connection drops**: Disable "Energy Saver" for network interfaces

### Linux

#### Installation

**Debian/Ubuntu**:
```bash
sudo apt update
sudo apt install wireguard resolvconf
```

**Arch Linux**:
```bash
sudo pacman -S wireguard-tools openresolv
```

**Fedora**:
```bash
sudo dnf install wireguard-tools
```

**CentOS/RHEL 8+**:
```bash
sudo dnf install epel-release
sudo dnf install wireguard-tools
```

#### Configuration

1. **Copy configuration**:
   ```bash
   sudo cp client2.conf /etc/wireguard/wg0.conf
   ```

2. **Edit configuration**:
   ```bash
   sudo nano /etc/wireguard/wg0.conf
   ```
   Update the Endpoint with your server's public IP.

3. **Set permissions**:
   ```bash
   sudo chmod 600 /etc/wireguard/wg0.conf
   ```

4. **Start VPN**:
   ```bash
   sudo wg-quick up wg0
   ```

5. **Check status**:
   ```bash
   sudo wg show wg0
   ```

#### Enable at Boot

```bash
sudo systemctl enable wg-quick@wg0
```

#### Management Commands

```bash
# Start VPN
sudo wg-quick up wg0

# Stop VPN
sudo wg-quick down wg0

# Restart VPN
sudo wg-quick down wg0 && sudo wg-quick up wg0

# Check status
sudo wg show wg0

# View logs
sudo journalctl -u wg-quick@wg0 -f
```

#### Verification

```bash
# Check interface
ip addr show wg0

# Test connectivity
ping 10.8.0.1

# Check routes
ip route | grep wg0

# Check public IP
curl ifconfig.me

# DNS test
nslookup google.com
```

#### Troubleshooting

- **resolvconf not found**: Install `openresolv` or `resolvconf`
- **Permission denied**: Ensure config has 600 permissions
- **Module not found**: Load module with `sudo modprobe wireguard`
- **DNS not working**: Check if `systemd-resolved` is interfering

#### GUI Options (Linux)

**NetworkManager Applet**:
```bash
# Install NetworkManager WireGuard plugin
sudo apt install network-manager-wireguard  # Debian/Ubuntu
sudo pacman -S networkmanager-wireguard     # Arch
```

Then import config via NetworkManager GUI.

**WireGuard GUI** (unofficial):
```bash
# Available on some distributions
sudo apt install wireguard-ui
```

### iOS

#### Installation

1. **Install App**:
   - Open App Store
   - Search "WireGuard"
   - Install official WireGuard app

2. **Add Configuration**:

   **Method A - QR Code** (Recommended):

   On your computer:
   ```bash
   # Install qrencode
   sudo apt install qrencode  # Linux
   brew install qrencode      # macOS

   # Generate QR code
   qrencode -t ansiutf8 < native-clients/client2.conf
   ```

   On iOS:
   - Open WireGuard app
   - Tap "+" → "Create from QR code"
   - Scan the QR code
   - Name the tunnel
   - Tap "Save"

   **Method B - File Import**:
   - Email the config to yourself (encrypted!)
   - Or use AirDrop (macOS)
   - Open the `.conf` file on iOS
   - Choose "Import with WireGuard"

   **Method C - Manual Entry**:
   - Open WireGuard app
   - Tap "+" → "Create from scratch"
   - Enter configuration manually
   - Tap "Save"

3. **Update Endpoint**:
   - Tap the tunnel name
   - Tap "Edit"
   - Update Endpoint with server IP
   - Tap "Save"

4. **Connect**:
   - Toggle the switch next to tunnel name
   - Allow VPN configuration (first time)
   - Status shows "Active"

#### Verification

- Check VPN icon appears in status bar
- Visit [https://ifconfig.me](https://ifconfig.me) in Safari
- Should show server's public IP

#### Troubleshooting

- **VPN won't activate**: Check VPN permissions in Settings → General → VPN & Device Management
- **No internet**: Check AllowedIPs is 0.0.0.0/0
- **Battery drain**: Disable on-demand rules if not needed

### Android

#### Installation

1. **Install App**:
   - Open Google Play Store
   - Search "WireGuard"
   - Install official WireGuard app

2. **Add Configuration**:

   **Method A - QR Code** (Recommended):

   Generate QR code on computer (see iOS section), then:
   - Open WireGuard app
   - Tap "+" → "Scan from QR code"
   - Scan the code
   - Name the tunnel
   - Tap "Create Tunnel"

   **Method B - File Import**:
   - Transfer `.conf` file to phone
   - Open WireGuard app
   - Tap "+" → "Import from file or archive"
   - Select the config file

   **Method C - Manual Entry**:
   - Open WireGuard app
   - Tap "+" → "Create from scratch"
   - Enter configuration manually
   - Tap "Create Tunnel"

3. **Update Endpoint**:
   - Tap tunnel name
   - Tap "Edit" (pencil icon)
   - Update Endpoint field
   - Tap "Save" (checkmark)

4. **Connect**:
   - Toggle switch next to tunnel
   - Allow VPN connection (first time)
   - Key icon appears in status bar

#### Verification

- Check for VPN key icon in status bar
- Open browser and visit [https://ifconfig.me](https://ifconfig.me)
- Should show server's public IP

#### Troubleshooting

- **Battery drain**: Adjust PersistentKeepalive or disable when not needed
- **Connection drops on mobile data**: Some carriers block VPN; try different port
- **Split tunneling**: Edit AllowedIPs for specific routing

## Advanced Configuration

### Split Tunneling

To route only specific traffic through VPN, change `AllowedIPs`:

```ini
# Route only private networks through VPN
AllowedIPs = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16

# Route specific subnet
AllowedIPs = 10.8.0.0/24
```

### Custom DNS

Change DNS servers in `[Interface]` section:

```ini
# Google DNS
DNS = 8.8.8.8, 8.8.4.4

# Quad9
DNS = 9.9.9.9, 149.112.112.112

# Multiple DNS servers
DNS = 1.1.1.1, 8.8.8.8, 9.9.9.9
```

### MTU Adjustment

If experiencing connectivity issues:

```ini
[Interface]
MTU = 1420  # Default WireGuard MTU
# Try lower values if problems persist: 1400, 1380, 1280
```

### Disable Persistent Keepalive

To reduce data usage (will affect NAT traversal):

```ini
[Peer]
# Remove or comment out:
# PersistentKeepalive = 25
```

### On-Demand Connection (iOS/macOS)

In WireGuard app:
1. Edit tunnel
2. Tap "On-Demand Activation"
3. Configure rules:
   - Wi-Fi network exclusions
   - Mobile data connection
   - Ethernet connection

## Security Best Practices

1. **Protect Configuration Files**:
   - Never share your `.conf` files
   - They contain your private key
   - Store securely (encrypted storage)

2. **Use Strong Device Security**:
   - Enable device encryption
   - Use strong unlock password/PIN
   - Enable device location/remote wipe

3. **Verify Server Identity**:
   - Confirm server public key matches
   - Use secure channel to receive configs

4. **Regular Updates**:
   - Keep WireGuard app updated
   - Update OS for security patches

5. **Monitor Connections**:
   - Check connected peers on server
   - Revoke compromised keys immediately

## Common Issues and Solutions

### "Could not determine current MTU"
**Solution**: Manually set MTU in config:
```ini
MTU = 1420
```

### DNS Leaks
**Solution**:
- Verify DNS is set in config
- Test at [https://dnsleaktest.com](https://dnsleaktest.com)
- Use DNS over HTTPS in browser for extra protection

### Can't Access Local Network
**Solution**: Use split tunneling:
```ini
AllowedIPs = 0.0.0.0/5, 8.0.0.0/7, 11.0.0.0/8, ...
# Excludes 10.0.0.0/8 (common home networks)
```

### High Battery Usage (Mobile)
**Solution**:
- Increase PersistentKeepalive: 60 or 120
- Or remove it entirely if NAT is not an issue
- Use on-demand activation

### IPv6 Not Working
**Solution**: Add IPv6 configuration:
```ini
[Interface]
Address = 10.8.0.3/32, fd42:42:42::3/128

[Peer]
AllowedIPs = 0.0.0.0/0, ::/0
```

## Testing Your Connection

After connecting, verify everything works:

```bash
# Test VPN connectivity
ping 10.8.0.1

# Test internet
ping 1.1.1.1

# Check public IP (should be server's IP)
curl ifconfig.me
# Or visit https://ifconfig.me in browser

# Test DNS
nslookup google.com

# Speed test
# Visit https://speedtest.net

# Check for leaks
# Visit https://ipleak.net
```

## Getting Help

If you encounter issues:

1. **Check logs**:
   - Windows: WireGuard app shows logs
   - macOS: WireGuard app → View Logs
   - Linux: `sudo journalctl -u wg-quick@wg0`
   - Mobile: Check app logs

2. **Verify configuration**:
   - Endpoint has correct server IP
   - Keys are correct (match server config)
   - Firewall allows UDP 51820

3. **Test server**:
   ```bash
   # Check if server is reachable
   nc -vzu YOUR_SERVER_IP 51820
   ```

4. **Check server logs**:
   ```bash
   docker exec wireguard-server wg show
   docker-compose logs wireguard-server
   ```

## Additional Resources

- [WireGuard Official Documentation](https://www.wireguard.com/)
- [WireGuard Quick Start](https://www.wireguard.com/quickstart/)
- [Troubleshooting Guide](https://wiki.archlinux.org/title/WireGuard)
- [WireGuard Subreddit](https://www.reddit.com/r/WireGuard/)

## QR Code Generation Reference

For easy mobile device setup:

```bash
# Linux/macOS with qrencode
qrencode -t ansiutf8 < client2.conf

# Generate image file
qrencode -t png -o client2.png < client2.conf

# Display in terminal
qrencode -t utf8 < client2.conf

# For Windows (PowerShell with qrencode)
Get-Content client2.conf | qrencode -t ansiutf8
```
