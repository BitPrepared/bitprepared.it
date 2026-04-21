#!/bin/bash
set -e

echo "=== Visual Regression Docker Container ==="

# Detect host IP
if [ -z "$HOST_IP" ]; then
    # Try host.docker.internal (Docker Desktop)
    if ping -c 1 host.docker.internal &> /dev/null; then
        HOST_IP="host.docker.internal"
    else
        # Linux Docker: use gateway IP
        HOST_IP=$(ip route | awk '/default/ {print $3}')
    fi
fi

echo "🌐 Using host IP: $HOST_IP"
echo "⚠️  Make sure servers are running on HOST:"
echo "   Terminal 1: make serve"
echo "   Terminal 2: make serve-static"
echo ""
echo "Waiting for servers..."

# Wait for Jekyll server on host
timeout 60 bash -c "until curl -s http://$HOST_IP:4000 > /dev/null; do sleep 1; done" || {
    echo "❌ Cannot connect to Jekyll server on $HOST_IP:4000"
    echo "❌ Make sure 'make serve' is running on HOST"
    exit 1
}
echo "✅ Jekyll ready on $HOST_IP:4000"

# Wait for static server on host
timeout 60 bash -c "until curl -s http://$HOST_IP:8000 > /dev/null; do sleep 1; done" || {
    echo "❌ Cannot connect to static server on $HOST_IP:8000"
    echo "❌ Make sure 'make serve-static' is running on HOST"
    exit 1
}
echo "✅ Static server ready on $HOST_IP:8000"

# Export host IP for Node scripts
export HOST_IP

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
