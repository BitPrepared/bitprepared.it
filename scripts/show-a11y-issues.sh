#!/bin/bash
# Mostra i dettagli degli elementi con problemi accessibilità

REPORT="${1:-docs/accessibility/reports/lighthouse/homepage}"

# Trova il file
if [ ! -f "$REPORT" ]; then
  if [ -f "$REPORT.json" ]; then
    REPORT="$REPORT.json"
  fi
fi

echo "# Accessibility Issues - Element Locations"
echo ""

node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$REPORT', 'utf8'));

const failedAudits = Object.entries(data.audits)
  .filter(([key, audit]) => audit.score === 0 && audit.details && audit.details.items);

if (failedAudits.length === 0) {
  console.log('✅ No accessibility issues found!');
  process.exit(0);
}

failedAudits.forEach(([key, audit]) => {
  console.log('## ' + audit.title);
  console.log('');

  if (audit.details.items.length > 0) {
    audit.details.items.forEach((item, idx) => {
      let selector = '';
      if (item.node) {
        selector = item.node.selector || item.node.snippet || '';
      }

      if (selector) {
        const excerpt = selector.length > 150 ? selector.substring(0, 150) + '...' : selector;
        console.log((idx + 1) + '. \`' + excerpt + '\`');

        if (item.node && item.node.path) {
          console.log('   Path: \`' + item.node.path.join(' > ') + '\`');
        }
      }
    });
    console.log('');
  }
});
"
