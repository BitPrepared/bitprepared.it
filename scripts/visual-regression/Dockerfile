FROM mcr.microsoft.com/playwright:v1.40.0-jammy

# Install Ruby e Jekyll
RUN apt-get update && \
    apt-get install -y ruby ruby-dev build-essential python3 && \
    gem install jekyll bundler && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile e install Jekyll deps
COPY Gemfile* ./
RUN bundle install

# Copy package files
COPY scripts/visual-regression/package*.json ./scripts/visual-regression/
RUN cd scripts/visual-regression && npm ci

# Copy entire project
COPY . .

# Setup script
COPY scripts/visual-regression/docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 4000 8000

ENTRYPOINT ["/entrypoint.sh"]
