#!/bin/bash
set -e

SITE_URL="${SITE_URL:-http://host.docker.internal:4000}"
REPORTS_DIR="/app/reports"

echo "🔍 Full Accessibility Audit for BitPrepared.it"
echo "Target: $SITE_URL"
echo "Reports: $REPORTS_DIR"
echo ""

# Create directories
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
  echo "  Testing: $page_name"

  npx -y lighthouse "$page_url" \
    --only-categories=accessibility \
    --output=json \
    --output-path="$REPORTS_DIR/lighthouse/${page_name}" \
    --chrome-flags="--headless --no-sandbox --disable-gpu"

  # Rename file if created without extension
  if [ -f "$REPORTS_DIR/lighthouse/${page_name}" ] && [ ! -f "$REPORTS_DIR/lighthouse/${page_name}.json" ]; then
    mv "$REPORTS_DIR/lighthouse/${page_name}" "$REPORTS_DIR/lighthouse/${page_name}.json"
  fi
done
echo "✅ Lighthouse complete"
echo ""

echo "🪓 Running axe-core on all pages..."
for page_name in "${!pages[@]}"; do
  page_url="${pages[$page_name]}"
  echo "  Testing: $page_name"

  node /app/scripts/run-axe.js "$page_url" "$REPORTS_DIR/axe/${page_name}.json"
done
echo "✅ axe-core complete"
echo ""

# Generate summary
node -e "
const fs = require('fs');
const lighthouseDir = '${REPORTS_DIR}/lighthouse';
const axeDir = '${REPORTS_DIR}/axe';

const lighthouseFiles = fs.readdirSync(lighthouseDir).filter(f => f.endsWith('.json'));
const axeFiles = fs.readdirSync(axeDir).filter(f => f.endsWith('.json'));

console.log('\\n=== Lighthouse Results ===');
lighthouseFiles.forEach(file => {
  try {
    const data = JSON.parse(fs.readFileSync(\`\${lighthouseDir}/\${file}\`, 'utf8'));
    const score = data.categories.accessibility.score * 100;
    console.log(\`  \${file.replace('.report.json', '')}: \${score.toFixed(0)}%\`);
  } catch(e) {
    console.log(\`  \${file.replace('.json', '')}: Error\`);
  }
});

console.log('\\n=== axe-core Results ===');
axeFiles.forEach(file => {
  try {
    const data = JSON.parse(fs.readFileSync(\`\${axeDir}/\${file}\`, 'utf8'));
    const violations = data.violations ? data.violations.length : 0;
    console.log(\`  \${file.replace('.json', '')}: \${violations} violations\`);
  } catch(e) {
    console.log(\`  \${file.replace('.json', '')}: Error\`);
  }
});
"

echo ""
echo "✅ Full accessibility audit complete!"
echo "📋 Reports saved to: $REPORTS_DIR"
