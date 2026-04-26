#!/bin/bash
# Analizza report accessibilità e genera summary

REPORTS_DIR="${1:-docs/accessibility/reports}"
SCRIPT_DIR="$(dirname "$0")"

echo "# Accessibility Audit Summary"
echo ""
echo "Generated: $(date)"
echo ""

if [ -f "$REPORTS_DIR/lighthouse/homepage" ]; then
  LIGHTHOUSE="$REPORTS_DIR/lighthouse/homepage"
else
  LIGHTHOUSE="$REPORTS_DIR/lighthouse/homepage.json"
fi

if [ -f "$REPORTS_DIR/axe/homepage.json" ]; then
  AXE="$REPORTS_DIR/axe/homepage.json"
else
  AXE="$REPORTS_DIR/axe/homepage"
fi

# Run analysis using separate Node.js scripts
node "$SCRIPT_DIR/analyze-lighthouse.js" "$LIGHTHOUSE"

echo ""
echo "## axe-core Violations"
echo ""

node "$SCRIPT_DIR/analyze-axe.js" "$AXE"

echo ""
node "$SCRIPT_DIR/analyze-fixes.js" "$AXE"

echo ""
echo "## Files Analyzed"
echo "- Lighthouse: \`$LIGHTHOUSE\`"
echo "- axe-core: \`$AXE\`"
