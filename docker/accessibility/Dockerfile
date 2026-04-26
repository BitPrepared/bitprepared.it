FROM node:20-bullseye

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

# Install Playwright browsers
RUN npx playwright install chromium
RUN npx playwright install-deps chromium

# Install Playwright locally for scripts
WORKDIR /app
RUN npm install playwright

# Set Chrome path for Lighthouse
ENV CHROME_PATH=/usr/bin/chromium

# Create reports directory
RUN mkdir -p /app/reports

# Copy scripts from accessibility directory
COPY docker/accessibility/scripts/ /app/scripts/

WORKDIR /app
