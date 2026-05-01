#!/bin/bash
set -e

SITE_URL="${SITE_URL:-http://host.docker.internal:4000}"
REPORTS_DIR="/app/reports"

echo "🔍 Accessibility Audit for BitPrepared.it"
echo "Target: $SITE_URL"
echo "Reports: $REPORTS_DIR"
echo ""

# Create directories
mkdir -p "$REPORTS_DIR/lighthouse"
mkdir -p "$REPORTS_DIR/axe"

# Run Lighthouse
echo "📊 Running Lighthouse..."
npx -y lighthouse "$SITE_URL" \
  --only-categories=accessibility \
  --output=json \
  --output-path="$REPORTS_DIR/lighthouse/homepage" \
  --chrome-flags="--headless --no-sandbox --disable-gpu"

LIGHTHOUSE_EXIT=$?
if [ $LIGHTHOUSE_EXIT -eq 0 ]; then
  echo "✅ Lighthouse complete"
else
  echo "❌ Lighthouse failed with exit code $LIGHTHOUSE_EXIT"
  echo "Contents of $REPORTS_DIR/lighthouse/:"
  ls -la "$REPORTS_DIR/lighthouse/" || echo "Directory not found"
  exit 1
fi

# Check if report file was created
echo "📁 Checking for report file..."
ls -la "$REPORTS_DIR/lighthouse/" || echo "Directory not found"

# Try all possible filenames
REPORT_FILE=""
if [ -f "$REPORTS_DIR/lighthouse/homepage.report.json" ]; then
  REPORT_FILE="$REPORTS_DIR/lighthouse/homepage.report.json"
elif [ -f "$REPORTS_DIR/lighthouse/homepage.json" ]; then
  REPORT_FILE="$REPORTS_DIR/lighthouse/homepage.json"
elif [ -f "$REPORTS_DIR/lighthouse/homepage" ]; then
  REPORT_FILE="$REPORTS_DIR/lighthouse/homepage"
else
  echo "❌ Lighthouse report not found"
  echo "Expected one of:"
  echo "  $REPORTS_DIR/lighthouse/homepage.report.json"
  echo "  $REPORTS_DIR/lighthouse/homepage.json"
  echo "  $REPORTS_DIR/lighthouse/homepage"
  exit 1
fi

echo "✅ Found report: $REPORT_FILE"

# Extract score
SCORE=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$REPORT_FILE', 'utf8'));
console.log((data.categories.accessibility.score * 100).toFixed(0));
")

echo "   Score: $SCORE%"
echo ""

# Run axe-core with Playwright
echo "🪓 Running axe-core..."
if node /app/scripts/run-axe.js "$SITE_URL" "$REPORTS_DIR/axe/homepage.json"; then
  echo "✅ axe-core complete"
else
  echo "❌ axe-core failed"
  exit 1
fi

echo ""
echo "📋 Summary:"
echo "  Lighthouse score: $SCORE%"
echo "  Lighthouse report: $REPORT_FILE"
echo "  axe-core report: $REPORTS_DIR/axe/homepage.json"
echo ""
echo "✅ Accessibility audit complete!"
