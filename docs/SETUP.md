# WireGuard VPN Suite - Detailed Setup Guide

This guide provides comprehensive instructions for deploying and configuring the WireGuard VPN suite in various environments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Deployment Scenarios](#deployment-scenarios)
5. [Testing](#testing)
6. [Maintenance](#maintenance)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Server Requirements

- **Operating System**: Linux with kernel 3.10+ (4.x+ recommended)
- **Docker**: Version 20.10+
- **Docker Compose**: Version 1.29+ or Docker Compose V2
- **Memory**: Minimum 512MB RAM
- **Network**: Public IP address with UDP port 51820 accessible
- **Kernel Module**: WireGuard kernel module or wireguard-dkms

### Client Requirements

- **Docker clients**: Same as server
- **Native clients**: WireGuard application for your platform

### Software Installation

#### Ubuntu/Debian
```bash
# Update package list
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose (if not included)
sudo apt install docker-compose-plugin

# Install WireGuard tools (for key generation)
sudo apt install wireguard-tools

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Arch Linux
```bash
# Install Docker and WireGuard
sudo pacman -S docker docker-compose wireguard-tools

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### macOS
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop

# Install WireGuard tools via Homebrew
brew install wireguard-tools
```

## Installation

### 1. Clone or Download the Project

```bash
git clone <repository-url>
cd vpn_suite
```

### 2. Verify Directory Structure

```bash
tree -L 2
```

You should see:
```
vpn_suite/
├── server/
│   ├── Dockerfile
│   ├── wg0.conf
│   ├── entrypoint.sh
│   └── keys/
├── client/
│   ├── Dockerfile
│   ├── docker-client.conf
│   ├── entrypoint.sh
│   └── keys/
├── native-clients/
├── scripts/
└── docs/
```

### 3. Generate Keys (If Not Already Done)

```bash
./scripts/generate-keys.sh
```

This generates:
- Server key pair
- Docker client (client1) key pair
- Three native client key pairs (client2-4)

### 4. Review Configuration Files

#### Server Configuration
```bash
cat server/wg0.conf
```

Verify:
- Server address is 10.8.0.1/24
- ListenPort is 51820
- All expected peers are listed

#### Docker Client Configuration
```bash
cat client/docker-client.conf
```

Verify:
- Client address is 10.8.0.2/32
- Endpoint points to wireguard-server:51820
- AllowedIPs is 0.0.0.0/0 (full tunnel)

## Configuration

### Network Configuration

The default configuration uses:
- **VPN subnet**: 10.8.0.0/24
- **Docker bridge**: 172.20.0.0/16

To change these, edit:

#### VPN Subnet
Edit all config files and replace 10.8.0.x with your desired subnet.

#### Docker Bridge
Edit `docker-compose.yml`:
```yaml
networks:
  wireguard-net:
    driver: bridge
    ipam:
      config:
        - subnet: YOUR_SUBNET
          gateway: YOUR_GATEWAY
```

### Firewall Configuration

#### On the Server Host

Allow UDP port 51820:

**UFW (Ubuntu/Debian)**
```bash
sudo ufw allow 51820/udp
sudo ufw reload
```

**firewalld (RHEL/CentOS)**
```bash
sudo firewall-cmd --add-port=51820/udp --permanent
sudo firewall-cmd --reload
```

**iptables**
```bash
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```

#### Cloud Providers

If running on AWS, GCP, Azure, etc.:
1. Navigate to security groups/firewall rules
2. Add inbound rule: UDP port 51820 from 0.0.0.0/0
3. Ensure outbound traffic is allowed

### DNS Configuration

Default DNS servers are Cloudflare (1.1.1.1, 1.0.0.1).

To change, edit all client config files:
```ini
[Interface]
DNS = 8.8.8.8, 8.8.4.4  # Google DNS
```

## Deployment Scenarios

### Scenario 1: Local Testing (Docker Only)

Perfect for testing and development.

```bash
# Start containers
docker-compose up -d

# Check status
docker-compose ps

# Run tests
./scripts/test-connectivity.sh

# View logs
docker-compose logs -f
```

### Scenario 2: Server on VPS, Clients Remote

Deploy server on VPS, connect with native clients.

#### On VPS:

```bash
# Deploy server only
docker-compose up -d wireguard-server

# Verify server is running
docker exec wireguard-server wg show

# Note your public IP
curl ifconfig.me
```

#### On Client Machines:

1. Copy a native client config (e.g., client2.conf)
2. Edit the config:
   ```ini
   Endpoint = YOUR_VPS_PUBLIC_IP:51820
   ```
3. Import into WireGuard application
4. Connect

### Scenario 3: Multiple Servers

Run separate servers for different purposes (dev, staging, prod).

1. Copy the entire `vpn_suite` directory:
   ```bash
   cp -r vpn_suite vpn_suite_staging
   cd vpn_suite_staging
   ```

2. Regenerate keys:
   ```bash
   rm -rf */keys/*.key
   ./scripts/generate-keys.sh
   ```

3. Change the port in `docker-compose.yml`:
   ```yaml
   ports:
     - "51821:51820/udp"  # Different external port
   ```

4. Deploy:
   ```bash
   docker-compose up -d
   ```

### Scenario 4: Behind NAT Router

If server is behind NAT:

1. Configure port forwarding on router:
   - External: UDP 51820 → Internal: UDP 51820
   - Forward to server's local IP

2. Use router's public IP in client configs:
   ```ini
   Endpoint = ROUTER_PUBLIC_IP:51820
   ```

## Testing

### Phase 1: Container Testing

```bash
# Start containers
docker-compose up -d

# Wait for startup
sleep 10

# Run comprehensive tests
./scripts/test-connectivity.sh
```

Expected results:
- All tests pass
- Client can ping server (10.8.0.1)
- Client can access internet
- DNS resolution works
- Public IP shows server's IP

### Phase 2: Native Client Testing

```bash
# On client machine after connecting
ping 10.8.0.1        # VPN server
ping 1.1.1.1         # Internet
curl ifconfig.me     # Should show VPN server's IP
nslookup google.com  # DNS test
```

### Phase 3: Performance Testing

```bash
# Throughput test (requires iperf3)
# On server
docker exec wireguard-server apk add iperf3
docker exec wireguard-server iperf3 -s

# From client
iperf3 -c 10.8.0.1
```

### Phase 4: Stress Testing

```bash
# Multiple simultaneous connections
# Connect multiple clients and test all at once

# Monitor server
docker exec wireguard-server wg show wg0 transfer
```

## Maintenance

### Key Rotation

```bash
# Generate new server keys
cd server/keys
wg genkey > server_private_new.key
wg pubkey < server_private_new.key > server_public_new.key

# Update server config with new private key
# Update all client configs with new public key

# Restart server
docker-compose restart wireguard-server
```

### Adding Clients

```bash
# Add new client (next available IP)
./scripts/add-client.sh 6

# Add peer block to server/wg0.conf
# (The script will show you what to add)

# Restart server
docker-compose restart wireguard-server
```

### Removing Clients

```bash
# Edit server/wg0.conf and remove the [Peer] block
# Restart server
docker-compose restart wireguard-server

# Optionally delete client files
rm native-clients/clientX.conf
rm native-clients/keys/clientX_*
```

### Log Management

```bash
# View logs
docker-compose logs wireguard-server
docker-compose logs wireguard-client

# Follow logs
docker-compose logs -f wireguard-server

# Limit log size in docker-compose.yml
services:
  wireguard-server:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Backup

```bash
# Backup keys and configs
tar -czf wireguard-backup-$(date +%Y%m%d).tar.gz \
  server/wg0.conf \
  server/keys/ \
  client/docker-client.conf \
  client/keys/ \
  native-clients/*.conf \
  native-clients/keys/

# Store securely (encrypted, off-site)
```

### Updates

```bash
# Pull latest images
docker-compose pull

# Rebuild containers
docker-compose build --no-cache

# Restart with new images
docker-compose up -d
```

## Troubleshooting

### Container Won't Start

```bash
# Check if WireGuard kernel module is loaded
lsmod | grep wireguard

# If not loaded, load it
sudo modprobe wireguard

# Check for errors
docker-compose logs wireguard-server

# Check Docker capabilities
docker info | grep -i security
```

### Client Can't Connect

1. **Check server is running**:
   ```bash
   docker ps | grep wireguard
   ```

2. **Verify firewall**:
   ```bash
   sudo netstat -ulnp | grep 51820
   ```

3. **Check client config**:
   - Ensure Endpoint has correct IP
   - Ensure keys match
   - Check AllowedIPs is correct

4. **Test from server**:
   ```bash
   docker exec wireguard-client ping 10.8.0.1
   ```

### No Internet Through VPN

```bash
# Check NAT rules on server
docker exec wireguard-server iptables -t nat -L

# Verify IP forwarding
docker exec wireguard-server sysctl net.ipv4.ip_forward

# Check routes on client
docker exec wireguard-client ip route
```

### DNS Not Working

```bash
# Check DNS in client config
grep DNS client/docker-client.conf

# Test DNS directly
docker exec wireguard-client nslookup google.com 1.1.1.1

# Check resolv.conf
docker exec wireguard-client cat /etc/resolv.conf
```

### Performance Issues

```bash
# Check MTU settings
docker exec wireguard-client ip link show wg0

# Adjust MTU in config if needed
# Add to [Interface] section:
MTU = 1420

# Monitor bandwidth
docker exec wireguard-server wg show wg0 transfer
```

### Peer Not Connecting

```bash
# Check handshake status
docker exec wireguard-server wg show wg0 latest-handshakes

# If no handshake:
# - Verify keys match between server and client
# - Check firewall allows UDP 51820
# - Ensure client Endpoint is correct
# - Check both sides have correct AllowedIPs
```

## Security Best Practices

1. **Keep keys secure**: Never commit to git, use 600 permissions
2. **Regular key rotation**: Rotate keys periodically (every 6-12 months)
3. **Limit peer access**: Use specific AllowedIPs where possible
4. **Monitor connections**: Regularly check `wg show` for unexpected peers
5. **Update regularly**: Keep WireGuard and Docker updated
6. **Use strong host security**: Firewall, SSH keys, disable password auth
7. **Backup encrypted**: Encrypt backups of keys and configs
8. **Audit logs**: Review Docker and system logs regularly

## Production Checklist

- [ ] Firewall configured (UDP 51820 open)
- [ ] Keys generated and secured
- [ ] Backups configured
- [ ] Monitoring/alerting set up
- [ ] Log rotation configured
- [ ] Restart policy set (unless-stopped)
- [ ] DNS properly configured
- [ ] Client configs distributed securely
- [ ] Documentation updated with server IP
- [ ] Initial testing completed
- [ ] Performance baseline established

## Additional Resources

- [WireGuard Official Documentation](https://www.wireguard.com/)
- [Docker Documentation](https://docs.docker.com/)
- [WireGuard Subreddit](https://www.reddit.com/r/WireGuard/)

## Support

For issues with this setup:
1. Check troubleshooting section
2. Review Docker and WireGuard logs
3. Verify configuration files
4. Test with connectivity script
