FROM mcr.microsoft.com/playwright:v1.59.1-jammy

WORKDIR /app

# Install utility tools
RUN apt-get update && \
    apt-get install -y iproute2 curl && \
    rm -rf /var/lib/apt/lists/*

# Copy package files
COPY scripts/visual-regression/package*.json ./scripts/visual-regression/
RUN cd scripts/visual-regression && npm ci

# Copy entire project
COPY . .

# Setup script
COPY scripts/visual-regression/docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
