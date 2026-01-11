# MTProxy Docker Setup

A Docker container for running Telegram's official MTProxy server on your VPS. MTProxy is a proxy server that uses the MTProto protocol to help users access Telegram in restricted regions.

## Features

- Official MTProxy implementation from Telegram
- Multi-stage Docker build for minimal image size
- Automatic secret generation
- Easy deployment with docker-compose
- Configurable ports and workers
- Persistent configuration storage
- Security hardened container

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+ (optional but recommended)
- A VPS with a public IP address
- Open ports (default: 443 for proxy, 8888 for stats)

## Quick Start

### Using Docker Compose (Recommended)

1. Clone or download this repository to your VPS:
```bash
cd /opt
git clone <your-repo-url> mtproxy
cd mtproxy
```

2. (Optional) Edit `docker-compose.yml` to customize settings:
```bash
nano docker-compose.yml
```

3. Start the proxy:
```bash
docker-compose up -d
```

4. View logs to get your connection link:
```bash
docker-compose logs -f
```

Look for output like:
```
Your MTProxy connection link:
tg://proxy?server=YOUR.VPS.IP&port=443&secret=YOUR_SECRET
```

### Using Docker Directly

1. Build the image:
```bash
docker build -t mtproxy .
```

2. Run the container:
```bash
docker run -d \
  --name mtproxy \
  -p 443:443 \
  -p 8888:8888 \
  -v $(pwd)/data:/mtproxy/config \
  --restart unless-stopped \
  mtproxy
```

3. View logs to get your connection link:
```bash
docker logs mtproxy
```

## Configuration

### Environment Variables

Configure the proxy by setting environment variables in `docker-compose.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `443` | Port for MTProxy connections |
| `STATS_PORT` | `8888` | Port for statistics (HTTP) |
| `WORKERS` | `2` | Number of worker threads |
| `SECRET` | (auto-generated) | 32-character hex secret for connections |
| `AD_TAG` | (none) | Telegram advertising tag from @MTProxybot |

### Custom Secret

To use a specific secret instead of auto-generated one:

1. Generate a 16-byte hex string (32 characters):
```bash
head -c 16 /dev/urandom | xxd -ps
```

2. Set it in `docker-compose.yml`:
```yaml
- SECRET=ee00000000000000000000000000000000
```

### Advertising Tag (Optional)

Get free advertising and promote your channels:

1. Message @MTProxybot on Telegram
2. Follow the instructions to get your AD_TAG
3. Set it in `docker-compose.yml`:
```yaml
- AD_TAG=your_tag_here
```

## Connecting to Your Proxy

### Method 1: Using the Connection Link

Share the connection link shown in the logs:
```
tg://proxy?server=YOUR.VPS.IP&port=443&secret=YOUR_SECRET
```

Users can click this link on their devices to automatically configure the proxy.

### Method 2: Manual Configuration

In Telegram app:
1. Go to Settings → Data and Storage → Proxy Settings
2. Add Proxy
3. Select MTProto
4. Enter:
   - Server: Your VPS IP
   - Port: 443 (or your custom port)
   - Secret: Your secret key

## Management

### View Logs
```bash
docker-compose logs -f
```

### Stop the Proxy
```bash
docker-compose down
```

### Restart the Proxy
```bash
docker-compose restart
```

### Update the Proxy
```bash
docker-compose down
docker-compose pull
docker-compose up -d --build
```

### View Statistics

Access statistics at: `http://YOUR.VPS.IP:8888/stats`

For security, you may want to disable the stats port in production by removing it from `docker-compose.yml`.

## Firewall Configuration

Ensure your VPS firewall allows traffic on the configured ports:

### UFW (Ubuntu/Debian)
```bash
sudo ufw allow 443/tcp
sudo ufw allow 8888/tcp  # Optional, for stats
```

### firewalld (CentOS/RHEL)
```bash
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --permanent --add-port=8888/tcp  # Optional
sudo firewall-cmd --reload
```

### iptables
```bash
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8888 -j ACCEPT  # Optional
```

## Security Considerations

1. **Secret Protection**: Keep your secret private. Anyone with the secret can use your proxy.

2. **Stats Port**: The stats port (8888) should be firewalled or removed in production environments.

3. **Updates**: Regularly update the proxy to get security patches:
   ```bash
   docker-compose down
   docker-compose up -d --build
   ```

4. **Monitoring**: Monitor your proxy usage through logs and stats to detect abuse.

5. **Rate Limiting**: Consider implementing rate limiting at the VPS level if needed.

## Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs

# Verify ports are not in use
sudo netstat -tulpn | grep -E ':(443|8888)'
```

### Can't connect to proxy
1. Verify firewall rules allow traffic on proxy port
2. Check container is running: `docker-compose ps`
3. Verify secret matches on client and server
4. Check VPS provider doesn't block Telegram traffic

### High CPU/Memory usage
Increase worker count in `docker-compose.yml`:
```yaml
- WORKERS=4  # Increase based on traffic
```

### View detailed logs
```bash
# All logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100

# Specific timestamp
docker-compose logs --since 2024-01-01T00:00:00
```

## File Structure

```
mtproxy/
├── Dockerfile              # Multi-stage build configuration
├── docker-compose.yml      # Deployment configuration
├── entrypoint.sh          # Container startup script
├── README.md              # This file
└── data/                  # Created automatically
    ├── proxy-secret       # Downloaded from Telegram
    └── proxy-multi.conf   # Downloaded from Telegram
```

## Performance Tuning

For high-traffic scenarios:

1. **Increase workers**:
   ```yaml
   - WORKERS=4  # Or more based on CPU cores
   ```

2. **Use production-grade VPS**:
   - 2+ CPU cores
   - 2+ GB RAM
   - SSD storage

3. **Enable TCP BBR** (Linux kernel optimization):
   ```bash
   echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
   echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
   sysctl -p
   ```

## License

This project uses Telegram's official MTProxy, which is licensed under the LGPL.

## Support

For issues with:
- **This Docker setup**: Open an issue in this repository
- **MTProxy itself**: See [official MTProxy repository](https://github.com/TelegramMessenger/MTProxy)
- **Telegram**: Contact Telegram support

## Resources

- [MTProxy Official Repository](https://github.com/TelegramMessenger/MTProxy)
- [MTProto Protocol Documentation](https://core.telegram.org/mtproto)
- [Telegram MTProxy Guide](https://core.telegram.org/mtproto/mtproto-transports)
