#!/bin/bash
set -e

CONFIG_DIR="/mtproxy/config"
PROXY_SECRET="${CONFIG_DIR}/proxy-secret"
PROXY_MULTI_CONF="${CONFIG_DIR}/proxy-multi.conf"

echo "=== MTProxy Docker Container ==="
echo "Initializing MTProto Proxy..."

# Download proxy secret if not exists
if [ ! -f "${PROXY_SECRET}" ]; then
    echo "Downloading proxy secret..."
    curl -s https://core.telegram.org/getProxySecret -o "${PROXY_SECRET}"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to download proxy secret"
        exit 1
    fi
    echo "Proxy secret downloaded successfully"
else
    echo "Using existing proxy secret"
fi

# Download proxy configuration if not exists
if [ ! -f "${PROXY_MULTI_CONF}" ]; then
    echo "Downloading proxy configuration..."
    curl -s https://core.telegram.org/getProxyConfig -o "${PROXY_MULTI_CONF}"
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to download proxy configuration"
        exit 1
    fi
    echo "Proxy configuration downloaded successfully"
else
    echo "Using existing proxy configuration"
fi

# Generate secret if not provided
if [ -z "${SECRET}" ]; then
    echo "Generating random secret..."
    SECRET=$(head -c 16 /dev/urandom | xxd -ps)
    echo "Generated secret: ${SECRET}"
    echo ""
    echo "IMPORTANT: Save this secret to connect to your proxy!"
    echo "You can also set it via the SECRET environment variable"
else
    echo "Using provided secret"
fi

# Build command line arguments
CMD_ARGS="-u nobody"
CMD_ARGS="${CMD_ARGS} -p ${STATS_PORT}"
CMD_ARGS="${CMD_ARGS} -H ${PORT}"
CMD_ARGS="${CMD_ARGS} -S ${SECRET}"
CMD_ARGS="${CMD_ARGS} --aes-pwd ${PROXY_SECRET} ${PROXY_MULTI_CONF}"
CMD_ARGS="${CMD_ARGS} -M ${WORKERS}"

# Add advertising tag if provided
if [ -n "${AD_TAG}" ]; then
    echo "Using advertising tag: ${AD_TAG}"
    CMD_ARGS="${CMD_ARGS} -P ${AD_TAG}"
fi

# Display connection info
echo ""
echo "======================================"
echo "MTProxy is starting with:"
echo "  Proxy Port: ${PORT}"
echo "  Stats Port: ${STATS_PORT}"
echo "  Workers: ${WORKERS}"
echo "  Secret: ${SECRET}"
if [ -n "${AD_TAG}" ]; then
    echo "  Ad Tag: ${AD_TAG}"
fi
echo "======================================"
echo ""

# Get server IP for connection URL
if [ -n "${SERVER_IP}" ]; then
    echo "Your MTProxy connection link:"
    echo "tg://proxy?server=${SERVER_IP}&port=${PORT}&secret=${SECRET}"
    echo ""
fi

echo "Starting MTProxy..."
exec /mtproxy/mtproto-proxy ${CMD_ARGS}
