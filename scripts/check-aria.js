const fs = require('fs');
const glob = require('glob');

const ariaTags = ['aria-label', 'aria-describedby', 'aria-hidden', 'role', 'aria-live', 'aria-labelledby'];
const report = {};

glob.sync('_site/**/*.html').forEach(file => {
  const html = fs.readFileSync(file, 'utf8');
  const lines = html.split('\n');
  const fileReport = [];

  ariaTags.forEach(tag => {
    const regex = new RegExp(`\\s${tag}=(["'])([^"']*?)\\1`, 'gi');
    let match;

    while ((match = regex.exec(html)) !== null) {
      const position = match.index;
      const lineNumber = html.substring(0, position).split('\n').length;
      const lineContent = lines[lineNumber - 1] || '';

      fileReport.push({
        tag: tag,
        value: match[2],
        line: lineNumber,
        context: lineContent.trim().substring(0, 100)
      });
    }
  });

  if (fileReport.length > 0) {
    report[file] = fileReport;
  }
});

fs.writeFileSync('aria-report.json', JSON.stringify(report, null, 2));
console.log(`✅ ARIA report generated: ${Object.keys(report).length} files with ARIA tags`);
console.log(`📄 Total ARIA attributes found: ${Object.values(report).flat().length}`);
