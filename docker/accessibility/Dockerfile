FROM node:18-bullseye

# Install system dependencies for Chrome/Chromium
RUN apt-get update && apt-get install -y \
    chromium \
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
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install accessibility tools
RUN npm install -g \
    lighthouse \
    @axe-core/cli \
    pa11y \
    playwright

# Install Python tools for additional analysis
RUN pip3 install --no-cache-dir \
    pyyaml \
    beautifulsoup4 \
    lxml

# Create reports directory
RUN mkdir -p /app/reports

# Set environment variables for Chromium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROME_PATH=/usr/bin/chromium

# Copy scripts
COPY scripts/*.sh /app/scripts/
RUN chmod +x /app/scripts/*.sh

WORKDIR /app
