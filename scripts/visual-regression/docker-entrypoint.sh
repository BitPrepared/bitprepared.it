#!/bin/bash
set -e

echo "=== Visual Regression Docker Container ==="

# Function cleanup
cleanup() {
  echo "Cleaning up..."
  if [ -n "$SERVE_PID" ]; then
    kill $SERVE_PID 2>/dev/null || true
  fi
  if [ -n "$STATIC_PID" ]; then
    kill $STATIC_PID 2>/dev/null || true
  fi
}

trap cleanup EXIT

cd /app

# Avvia Jekyll serve in background
echo "🚀 Starting Jekyll serve (port 4000)..."
bundle exec jekyll serve --host 0.0.0.0 --port 4000 --config _config.yml,_config_dev.yml &
SERVE_PID=$!

# Wait for server ready
echo "⏳ Waiting for Jekyll server..."
timeout 120 bash -c 'until curl -s http://localhost:4000 > /dev/null; do sleep 1; done' || {
  echo "❌ Jekyll server failed to start"
  exit 1
}
echo "✅ Jekyll ready on port 4000"

# Build e avvia static server
echo "🔨 Building static site..."
bundle exec jekyll build --config _config.yml

echo "🚀 Starting Python static server (port 8000)..."
cd _site && python3 -m http.server 8000 &
STATIC_PID=$!
cd ..

# Wait for static server ready
echo "⏳ Waiting for static server..."
timeout 30 bash -c 'until curl -s http://localhost:8000 > /dev/null; do sleep 1; done' || {
  echo "❌ Static server failed to start"
  exit 1
}
echo "✅ Static server ready on port 8000"

# Esegue test visual regression
echo ""
echo "🔍 Running visual regression tests..."
cd /app/scripts/visual-regression

npm test

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ Visual regression PASSED"
else
  echo "❌ Visual regression FAILED"
fi

exit $EXIT_CODE
