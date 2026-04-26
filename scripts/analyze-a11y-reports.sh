#!/bin/bash
# Analizza report accessibilità e genera summary

REPORTS_DIR="${1:-docs/accessibility/reports}"

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

echo "## Lighthouse Score"
echo ""

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$LIGHTHOUSE', 'utf8'));
const score = data.categories.accessibility.score * 100;
console.log('**Overall:** ' + score.toFixed(0) + '%');
console.log('');

const audits = Object.entries(data.audits)
  .filter(([key, audit]) => audit.score !== null && audit.score !== undefined)
  .sort(([,a], [,b]) => a.score - b.score);

console.log('### Failed Audits:');
audits.filter(([key, audit]) => audit.score === 0).slice(0, 10).forEach(([key, audit]) => {
  console.log('- **' + audit.title + '**');
  if (audit.description) console.log('  ' + audit.description);
});

console.log('');
console.log('### Passed Audits (sample):');
const passed = audits.filter(([key, audit]) => audit.score === 1).length;
console.log('- Total passed: ' + passed);
"

echo ""
echo "## axe-core Violations"
echo ""

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$AXE', 'utf8'));

console.log('**Total Violations:** ' + data.violations.length);
console.log('');

if (data.violations.length > 0) {
  console.log('### Critical Issues:');
  data.violations
    .filter(v => v.impact === 'critical')
    .forEach(v => {
      console.log('- **' + v.id + '** (impact: ' + v.impact + ')');
      console.log('  ' + v.description);
      console.log('  Nodes affected: ' + v.nodes.length);
      console.log('');
    });

  console.log('### Serious Issues:');
  data.violations
    .filter(v => v.impact === 'serious')
    .forEach(v => {
      console.log('- **' + v.id + '**');
      console.log('  ' + v.description);
      console.log('  Nodes: ' + v.nodes.length);
    });
}
"

echo ""
echo "## Quick Fixes"
echo ""
echo "### Top Priority Actions"
echo ""

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$AXE', 'utf8'));

data.violations
  .filter(v => v.impact === 'critical' || v.impact === 'serious')
  .slice(0, 5)
  .forEach(v => {
    console.log('1. **' + v.description + '**');
    console.log('   - Violation: ' + v.id);
    console.log('   - Help: ' + v.helpUrl);
    console.log('');
  });
"

echo "## Files Analyzed"
echo "- Lighthouse: \`$LIGHTHOUSE\`"
echo "- axe-core: \`$AXE\`"
