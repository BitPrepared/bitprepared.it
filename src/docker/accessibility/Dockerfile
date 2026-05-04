FROM node:20-bullseye

# Force IPv4 for downloads (fixes Playwright installation in Docker)
ENV PLAYWRIGHT_DOWNLOAD_HOST=https://playwright.azureedge.net
ENV NODE_OPTIONS=--dns-result-order=ipv4first

# Install system dependencies and Chromium
RUN apt-get update && apt-get install -y \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libwayland-client0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    chromium \
    && rm -rf /var/lib/apt/lists/*

# Install accessibility tools globally
RUN npm install -g \
    lighthouse

# Install Puppeteer (uses system Chromium)
WORKDIR /app
RUN npm install puppeteer

# Set Chrome path for Lighthouse
ENV CHROME_PATH=/usr/bin/chromium

# Create reports directory
RUN mkdir -p /app/reports

# Copy scripts from accessibility directory
COPY src/docker/accessibility/scripts/ /app/scripts/

WORKDIR /app
