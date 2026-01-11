FROM ubuntu:22.04 AS builder

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies for MTProxy
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libssl-dev \
    zlib1g-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone and build MTProxy
WORKDIR /tmp
RUN git clone https://github.com/TelegramMessenger/MTProxy.git && \
    cd MTProxy && \
    make

# Final stage - runtime image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libssl3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /mtproxy

# Copy built binary from builder
COPY --from=builder /tmp/MTProxy/objs/bin/mtproto-proxy /mtproxy/

# Copy configuration script
COPY entrypoint.sh /mtproxy/
RUN chmod +x /mtproxy/entrypoint.sh

# Create directory for secrets and config
RUN mkdir -p /mtproxy/config

# Expose MTProxy ports
# Default: 443 for proxy, 8888 for stats (optional)
EXPOSE 443 8888

# Environment variables (can be overridden)
ENV PORT=443
ENV STATS_PORT=8888
ENV WORKERS=2
ENV SECRET=""

ENTRYPOINT ["/mtproxy/entrypoint.sh"]
