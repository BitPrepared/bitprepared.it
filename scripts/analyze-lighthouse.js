const fs = require('fs');

const reportPath = process.argv[2];
const data = JSON.parse(fs.readFileSync(reportPath, 'utf8'));

console.log('## Lighthouse Score');
console.log('');

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

  // Show affected nodes/elements
  if (audit.details && audit.details.items && audit.details.items.length > 0) {
    console.log('  **Affected elements:**');
    audit.details.items.slice(0, 5).forEach((item, idx) => {
      if (item.node) {
        const selector = item.node.selector || item.node.snippet || '';
        const excerpt = selector.length > 100 ? selector.substring(0, 100) + '...' : selector;
        console.log('  ' + (idx + 1) + '. `' + excerpt + '`');

        // Extract color info from explanation if present
        if (item.node.explanation) {
          const explanation = item.node.explanation;

          // Extract foreground color
          const fgMatch = explanation.match(/foreground color:\s*#([0-9a-fA-F]{6})/);
          const bgMatch = explanation.match(/background color:\s*#([0-9a-fA-F]{6})/);
          const ratioMatch = explanation.match(/contrast ratio of ([\d.]+)/);
          const expectedMatch = explanation.match(/Expected contrast ratio of ([\d.]+)/);

          if (fgMatch || bgMatch) {
            console.log('     Colors:');
            if (fgMatch) console.log('     - Foreground: #' + fgMatch[1]);
            if (bgMatch) console.log('     - Background: #' + bgMatch[1]);
            if (ratioMatch && expectedMatch) {
              console.log('     - Ratio: ' + ratioMatch[1] + ' (expected: ' + expectedMatch[1] + ')');
            }
          }
        }

        // Show path if available
        if (item.node.path) {
          if (Array.isArray(item.node.path)) {
            const path = item.node.path.join(' > ');
            console.log('     Path: `' + path + '`');
          } else {
            console.log('     Path: `' + item.node.path + '`');
          }
        }
      } else if (item.value) {
        console.log('  ' + (idx + 1) + '. Value: ' + item.value);
      }
    });
    if (audit.details.items.length > 5) {
      console.log('  ... and ' + (audit.details.items.length - 5) + ' more');
    }
  }
});

console.log('');
console.log('### Passed Audits (sample):');
const passed = audits.filter(([key, audit]) => audit.score === 1).length;
console.log('- Total passed: ' + passed);
