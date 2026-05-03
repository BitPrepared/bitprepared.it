const fs = require('fs');
const path = require('path');

const ariaTags = ['aria-label', 'aria-describedby', 'aria-hidden', 'role', 'aria-live', 'aria-labelledby'];
const report = {};

function walkDir(dir, callback) {
  const files = fs.readdirSync(dir);
  files.forEach((file) => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      walkDir(filePath, callback);
    } else if (file.endsWith('.html')) {
      callback(filePath);
    }
  });
}

walkDir('_site', (file) => {
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

fs.writeFileSync('output/accessibility/reports/aria-report.json', JSON.stringify(report, null, 2));
const fileCount = Object.keys(report).length;
const tagCount = Object.values(report).flat().length;
console.log(`✅ ARIA report generated: output/accessibility/reports/aria-report.json`);
console.log(`📄 ${fileCount} files with ARIA tags, ${tagCount} total attributes`);
