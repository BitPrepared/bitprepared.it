#!/bin/bash
set -e

SITE_URL="${SITE_URL:-http://host.docker.internal:4000}"
REPORTS_DIR="/app/reports"

echo "🔍 Accessibility Audit for BitPrepared.it"
echo "Target: $SITE_URL"
echo "Reports: $app/reports"
echo ""

# Create subdirectories
mkdir -p "$REPORTS_DIR/lighthouse"
mkdir -p "$REPORTS_DIR/axe"

# Run Lighthouse
echo "📊 Running Lighthouse..."
lighthouse "$SITE_URL" \
  --only-categories=accessibility \
  --output=json --output=html \
  --output-path="$REPORTS_DIR/lighthouse/homepage" \
  --chrome-flags="--headless --no-sandbox --disable-gpu"

echo "✅ Lighthouse complete"
echo ""

# Run axe-core
echo "🪓 Running axe-core..."
axe "$SITE_URL" \
  --tags wcag2a,wcag2aa,best-practice \
  --format json \
  --file "$REPORTS_DIR/axe/homepage.json"

echo "✅ axe-core complete"
echo ""

echo "📋 Summary:"
echo "  Lighthouse report: $REPORTS_DIR/lighthouse/homepage.report.html"
echo "  Lighthouse data: $REPORTS_DIR/lighthouse/homepage.report.json"
echo "  axe-core data: $REPORTS_DIR/axe/homepage.json"
echo ""
echo "✅ Accessibility audit complete!"
