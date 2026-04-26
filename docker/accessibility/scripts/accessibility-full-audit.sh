#!/bin/bash
set -e

SITE_URL="${SITE_URL:-http://host.docker.internal:4000}"
REPORTS_DIR="/app/reports"

echo "🔍 Full Accessibility Audit for BitPrepared.it"
echo "Target: $SITE_URL"
echo "Reports: $REPORTS_DIR"
echo ""

# Create subdirectories
mkdir -p "$REPORTS_DIR/lighthouse"
mkdir -p "$REPORTS_DIR/axe"

# Define pages to audit
declare -A pages=(
  ["homepage"]="${SITE_URL}/"
  ["eventi-listing"]="${SITE_URL}/eventi/"
  ["evento-detail"]="${SITE_URL}/eventi/epppi/"
  ["software-listing"]="${SITE_URL}/software/"
  ["software-detail"]="${SITE_URL}/software/vlc/"
  ["about"]="${SITE_URL}/about/"
  ["blog-post"]="${SITE_URL}/blog/2025/esploratori-nella-rete/"
  ["tags"]="${SITE_URL}/tags/"
)

echo "📊 Running Lighthouse on all pages..."
for page_name in "${!pages[@]}"; do
  page_url="${pages[$page_name]}"
  echo "  Testing: $page_name ($page_url)"

  lighthouse "$page_url" \
    --only-categories=accessibility \
    --output=json \
    --output-path="$REPORTS_DIR/lighthouse/${page_name}.json" \
    --chrome-flags="--headless --no-sandbox --disable-gpu" \
    --quiet
done
echo "✅ Lighthouse complete"
echo ""

echo "🪓 Running axe-core on all pages..."
for page_name in "${!pages[@]}"; do
  page_url="${pages[$page_name]}"
  echo "  Testing: $page_name ($page_url)"

  axe "$page_url" \
    --tags wcag2a,wcag2aa,best-practice \
    --format json \
    --file "$REPORTS_DIR/axe/${page_name}.json" \
    --disable "color-contrast"  # Skip color contrast in axe (handled separately)
done
echo "✅ axe-core complete"
echo ""

# Generate summary
echo "📋 Generating summary..."
node -e "
const fs = require('fs');
const lighthouseDir = '${REPORTS_DIR}/lighthouse';
const axeDir = '${REPORTS_DIR}/axe';

const lighthouseFiles = fs.readdirSync(lighthouseDir).filter(f => f.endsWith('.json'));
const axeFiles = fs.readdirSync(axeDir).filter(f => f.endsWith('.json'));

console.log('\\n=== Lighthouse Results ===');
lighthouseFiles.forEach(file => {
  const data = JSON.parse(fs.readFileSync(\`\${lighthouseDir}/\${file}\`, 'utf8'));
  const score = data.categories.accessibility.score * 100;
  console.log(\`  \${file.replace('.json', '')}: \${score.toFixed(0)}%\`);
});

console.log('\\n=== axe-core Results ===');
axeFiles.forEach(file => {
  const data = JSON.parse(fs.readFileSync(\`\${axeDir}/\${file}\`, 'utf8'));
  const violations = data.violations.length;
  console.log(\`  \${file.replace('.json', '')}: \${violations} violations\`);
});
"

echo ""
echo "📋 Reports saved to: $REPORTS_DIR"
echo "  - Lighthouse: lighthouse/*.json"
echo "  - axe-core: axe/*.json"
echo ""
echo "✅ Full accessibility audit complete!"
