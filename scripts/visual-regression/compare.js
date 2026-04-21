const pixelmatch = require('pixelmatch');
const { PNG } = require('pngjs');
const fs = require('fs');
const path = require('path');

const THRESHOLD_PERCENT = 1;
const PIXEL_THRESHOLD = 0.1;

const viewports = ['desktop', 'mobile', 'tablet'];

const pages = [
  '',
  'about',
  'blog',
  'eventi_epppi',
  'eventi_campo-eg',
  'eventi_stage',
  'software',
  'software_libreoffice',
  'software_gimp',
  'software_qgis',
  'software_mayalinux',
  'software_vlc',
  'software_wordpress',
  'software_flora',
  'software_code',
  'software_prbm',
  'articles',
  'project_github'
];

function compareImages(img1Path, img2Path, diffPath) {
  if (!fs.existsSync(img1Path) || !fs.existsSync(img2Path)) {
    return {
      error: 'File not found',
      missing: !fs.existsSync(img1Path) ? img1Path : img2Path
    };
  }

  const img1 = PNG.sync.read(fs.readFileSync(img1Path));
  const img2 = PNG.sync.read(fs.readFileSync(img2Path));
  const diff = new PNG({ width: img1.width, height: img1.height });

  const numDiffPixels = pixelmatch(
    img1.data,
    img2.data,
    diff.data,
    img1.width,
    img1.height,
    { threshold: PIXEL_THRESHOLD }
  );

  const totalPixels = img1.width * img1.height;
  const diffPercent = (numDiffPixels / totalPixels) * 100;

  const dir = path.dirname(diffPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(diffPath, PNG.sync.write(diff));

  return {
    numDiffPixels,
    totalPixels,
    diffPercent: diffPercent.toFixed(2),
    passed: diffPercent <= THRESHOLD_PERCENT
  };
}

function generateReport(results) {
  const reportDir = path.join(__dirname, '../../screenshots/report');
  if (!fs.existsSync(reportDir)) {
    fs.mkdirSync(reportDir, { recursive: true });
  }

  const timestamp = new Date().toISOString();
  const totalTests = results.length;
  const passedTests = results.filter(r => r.passed).length;
  const failedTests = totalTests - passedTests;

  const html = `<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Visual Regression Report - BitPrepared</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f5f5f5;
      padding: 20px;
    }
    .header {
      background: white;
      padding: 30px;
      border-radius: 8px;
      margin-bottom: 20px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .header h1 {
      color: #333;
      margin-bottom: 10px;
    }
    .summary {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
      margin-top: 20px;
    }
    .summary-card {
      background: #f8f9fa;
      padding: 20px;
      border-radius: 8px;
      text-align: center;
    }
    .summary-card .number {
      font-size: 2em;
      font-weight: bold;
      margin-bottom: 5px;
    }
    .summary-card.pass .number { color: #28a745; }
    .summary-card.fail .number { color: #dc3545; }
    .summary-card.total .number { color: #007bff; }
    .summary-card .label {
      color: #666;
      font-size: 0.9em;
    }
    .controls {
      background: white;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 20px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .filter-btn {
      padding: 10px 20px;
      margin-right: 10px;
      border: 1px solid #ddd;
      background: white;
      border-radius: 4px;
      cursor: pointer;
      transition: all 0.2s;
    }
    .filter-btn:hover, .filter-btn.active {
      background: #007bff;
      color: white;
      border-color: #007bff;
    }
    .results-table {
      background: white;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    table {
      width: 100%;
      border-collapse: collapse;
    }
    th {
      background: #f8f9fa;
      padding: 15px;
      text-align: left;
      font-weight: 600;
      color: #333;
      border-bottom: 2px solid #dee2e6;
    }
    td {
      padding: 15px;
      border-bottom: 1px solid #dee2e6;
    }
    tr:hover {
      background: #f8f9fa;
    }
    .badge {
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 0.85em;
      font-weight: 600;
    }
    .badge.pass {
      background: #d4edda;
      color: #155724;
    }
    .badge.fail {
      background: #f8d7da;
      color: #721c24;
    }
    .diff-link {
      color: #007bff;
      text-decoration: none;
      cursor: pointer;
    }
    .diff-link:hover {
      text-decoration: underline;
    }
    .viewport {
      display: inline-block;
      padding: 4px 8px;
      background: #e9ecef;
      border-radius: 4px;
      font-size: 0.85em;
      margin-right: 5px;
    }
    .hidden {
      display: none;
    }
    .timestamp {
      color: #666;
      font-size: 0.9em;
      margin-top: 10px;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>🎨 Visual Regression Report</h1>
    <div class="summary">
      <div class="summary-card total">
        <div class="number">${totalTests}</div>
        <div class="label">Total Tests</div>
      </div>
      <div class="summary-card pass">
        <div class="number">${passedTests}</div>
        <div class="label">Passed</div>
      </div>
      <div class="summary-card fail">
        <div class="number">${failedTests}</div>
        <div class="label">Failed</div>
      </div>
      <div class="summary-card">
        <div class="number">${THRESHOLD_PERCENT}%</div>
        <div class="label">Threshold</div>
      </div>
    </div>
    <div class="timestamp">Generated: ${timestamp}</div>
  </div>

  <div class="controls">
    <button class="filter-btn active" onclick="filterResults('all')">All</button>
    <button class="filter-btn" onclick="filterResults('failures')">Failures Only</button>
    <button class="filter-btn" onclick="filterResults('viewport')">By Viewport</button>
  </div>

  <div class="results-table">
    <table>
      <thead>
        <tr>
          <th>Page</th>
          <th>Viewport</th>
          <th>Server</th>
          <th>Diff %</th>
          <th>Status</th>
          <th>Diff Image</th>
        </tr>
      </thead>
      <tbody id="results">
        ${results.map(r => `
          <tr class="${r.passed ? 'pass' : 'fail'}">
            <td><code>${r.page}</code></td>
            <td><span class="viewport">${r.viewport}</span></td>
            <td>${r.server}</td>
            <td>${r.diffPercent}%</td>
            <td><span class="badge ${r.passed ? 'pass' : 'fail'}">${r.passed ? 'PASS' : 'FAIL'}</span></td>
            <td>${r.numDiffPixels > 0 ? `<a class="diff-link" href="../diff/${r.viewport}/${r.page}.png" target="_blank">View Diff</a>` : '-'}</td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  </div>

  <script>
    const results = ${JSON.stringify(results)};

    function filterResults(type) {
      const rows = document.querySelectorAll('#results tr');
      const buttons = document.querySelectorAll('.filter-btn');

      buttons.forEach(btn => btn.classList.remove('active'));
      event.target.classList.add('active');

      rows.forEach(row => {
        if (type === 'all') {
          row.classList.remove('hidden');
        } else if (type === 'failures') {
          row.classList.toggle('hidden', !row.classList.contains('fail'));
        }
      });
    }
  </script>
</body>
</html>`;

  fs.writeFileSync(path.join(reportDir, 'index.html'), html);
  fs.writeFileSync(path.join(reportDir, 'results.json'), JSON.stringify(results, null, 2));

  console.log(`\n📊 Report generated: screenshots/report/index.html`);
  console.log(`   Passed: ${passedTests}/${totalTests}`);
  console.log(`   Failed: ${failedTests}/${totalTests}`);
}

function main() {
  console.log('=== Visual Regression Compare ===\n');

  const results = [];

  for (const viewport of viewports) {
    for (const page of pages) {
      const baselinePath = path.join(__dirname, `../../tests/visual-baseline/${viewport}/${page}.png`);
      const servePath = path.join(__dirname, `../../screenshots/serve/${viewport}/${page}.png`);
      const staticPath = path.join(__dirname, `../../screenshots/static/${viewport}/${page}.png`);
      const serveDiffPath = path.join(__dirname, `../../screenshots/diff/${viewport}/${page}_serve.png`);
      const staticDiffPath = path.join(__dirname, `../../screenshots/diff/${viewport}/${page}_static.png`);

      if (!fs.existsSync(baselinePath)) {
        console.log(`⚠️  No baseline for ${viewport}/${page}.png - skipping`);
        continue;
      }

      const serveResult = compareImages(baselinePath, servePath, serveDiffPath);
      const staticResult = compareImages(baselinePath, staticPath, staticDiffPath);

      if (!serveResult.error) {
        results.push({
          page,
          viewport,
          server: 'serve',
          ...serveResult
        });
      }

      if (!staticResult.error) {
        results.push({
          page,
          viewport,
          server: 'static',
          ...staticResult
        });
      }

      const status = serveResult.passed && staticResult.passed ? '✅' : '❌';
      console.log(`${status} ${viewport}/${page}: serve=${serveResult.diffPercent}%, static=${staticResult.diffPercent}%`);
    }
  }

  generateReport(results);

  const hasFailures = results.some(r => !r.passed);
  if (hasFailures) {
    console.error('\n❌ Validation FAILED: Differences exceed threshold');
    process.exit(1);
  } else {
    console.log('\n✅ All tests PASSED');
  }
}

main();
