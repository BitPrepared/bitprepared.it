FROM mcr.microsoft.com/playwright:v1.59.1-jammy

WORKDIR /app

# Copy package files
COPY scripts/visual-regression/package*.json ./scripts/visual-regression/
RUN cd scripts/visual-regression && npm ci

# Copy entire project
COPY . .

# Setup script
COPY scripts/visual-regression/docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to node user to avoid permission issues with mounted volumes
USER node

ENTRYPOINT ["/entrypoint.sh"]
