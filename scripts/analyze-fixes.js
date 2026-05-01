const fs = require('fs');

const axePath = process.argv[2];
const data = JSON.parse(fs.readFileSync(axePath, 'utf8'));

console.log('## Quick Fixes');
console.log('');
console.log('### Top Priority Actions');
console.log('');

data.violations
  .filter(v => v.impact === 'critical' || v.impact === 'serious')
  .slice(0, 5)
  .forEach(v => {
    console.log('1. **' + v.description + '**');
    console.log('   - Violation: ' + v.id);
    console.log('   - Impact: ' + v.impact);
    console.log('   - Help: ' + v.helpUrl);
    if (v.nodes.length > 0) {
      console.log('   - Sample target: ' + (v.nodes[0].target || v.nodes[0].html || 'N/A'));
    }
    console.log('');
  });
