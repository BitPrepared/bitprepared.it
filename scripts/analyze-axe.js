const fs = require('fs');

const axePath = process.argv[2];
const data = JSON.parse(fs.readFileSync(axePath, 'utf8'));

console.log('## axe-core Violations');
console.log('');

console.log('**Total Violations:** ' + data.violations.length);
console.log('');

if (data.violations.length > 0) {
  console.log('### Critical Issues:');
  const critical = data.violations.filter(v => v.impact === 'critical');
  if (critical.length > 0) {
    critical.forEach(v => {
      console.log('- **' + v.id + '** (impact: ' + v.impact + ')');
      console.log('  ' + v.description);
      console.log('  Nodes affected: ' + v.nodes.length);
      if (v.nodes.length > 0 && v.nodes[0].target) {
        console.log('  Sample targets: ' + v.nodes.slice(0, 3).map(n =>
          n.target ? n.target.join(', ') : 'unknown'
        ).join('; '));
      }
      console.log('');
    });
  } else {
    console.log('None');
  }

  console.log('### Serious Issues:');
  const serious = data.violations.filter(v => v.impact === 'serious');
  if (serious.length > 0) {
    serious.forEach(v => {
      console.log('- **' + v.id + '**');
      console.log('  ' + v.description);
      console.log('  Nodes: ' + v.nodes.length);
      console.log('');
    });
  } else {
    console.log('None');
  }
}
