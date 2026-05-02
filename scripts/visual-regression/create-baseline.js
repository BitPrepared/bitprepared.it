const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { extractPagesFromSitemap } = require('./extract-pages-from-sitemap');
const { captureScreenshot, generateFilename } = require('./screenshot-utils');

// Handle interrupt signals
let browser = null;
process.on('SIGINT', async () => {
  console.log('\n\n⚠️  Interrupted, cleaning up...');
  if (browser) await browser.close();
  process.exit(130); // 128 + SIGINT(2)
});

process.on('SIGTERM', async () => {
  if (browser) await browser.close();
  process.exit(143); // 128 + SIGTERM(15)
});

const viewports = {
  desktop: { width: 1920, height: 1080 },
  tablet: { width: 768, height: 1024 },
  mobile: { width: 375, height: 667 }
};

const pages = [
  '/',
  '/about/',
  '/blog/',
  '/tags/',
  '/tags/#maestro delle tecnologie',
  '/eventi/',
  '/eventi/epppi/',
  '/eventi/campo-eg/',
  '/eventi/stage/',
  '/software/',
  '/software/libreoffice/',
  '/software/gimp/',
  '/software/qgis/',
  '/software/mayalinux/',
  '/software/vlc/',
  '/software/wordpress/',
  '/software/flora/',
  '/software/code/',
  '/software/prbm/',
  '/articles/',
  '/project/github/'
];

// Generate YYYY.MM folder for baseline versioning
const now = new Date();
const year = now.getFullYear();
const month = String(now.getMonth() + 1).padStart(2, '0');
const baselineVersion = `${year}.${month}`;
const baselineBaseFolder = path.join(__dirname, '../../tests/visual-baseline', baselineVersion);

console.log(`📅 Baseline version: ${baselineVersion}`);

// Create baseline folder if it doesn't exist
if (!fs.existsSync(baselineBaseFolder)) {
  fs.mkdirSync(baselineBaseFolder, { recursive: true });
  console.log(`📁 Created folder: ${baselineBaseFolder}`);
}

async function createBaseline() {
  console.log('=== Creating Visual Baseline ===\n');

  const hostIp = process.env.HOST_IP || 'localhost';
  console.log(`Using http://${hostIp}:4000 as baseline source\n`);
  console.log('⚠️  Make sure "make serve" is running on port 4000\n');

  try {
    // Carica pagine dalla sitemap
    let pages = await extractPagesFromSitemap();

    // Aggiungi pagine speciali non in sitemap (hash pages, etc.)
    const specialPages = [
      '/tags/#maestro delle tecnologie'
    ];

    pages = [...pages, ...specialPages];

    console.log(`📸 Testing ${pages.length} pages from sitemap`);
    console.log('');

    browser = await chromium.launch({
      headless: true
    });

    for (const [viewportName, viewport] of Object.entries(viewports)) {
      console.log(`\n  📱 Viewport: ${viewportName} (${viewport.width}x${viewport.height})`);

      // Create context with viewport
      const context = await browser.newContext({
        viewport: viewport
      });

      for (const pageUrl of pages) {
        try {
          const page = await context.newPage();
          const fullUrl = `http://${hostIp}:4000${pageUrl}`;

          console.log(`    🔗 ${pageUrl}`);

          const filename = generateFilename(pageUrl);
          const baselinePath = path.join(baselineBaseFolder, viewportName, `${filename}.png`);

          const dir = path.dirname(baselinePath);
          if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
          }

          await captureScreenshot(page, fullUrl, baselinePath);

          await page.close();
        } catch (error) {
          console.error(`    ❌ Error capturing ${pageUrl}: ${error.message}`);
        }
      }

      await context.close();
    }

    await browser.close();

    console.log(`\n✅ Baseline created successfully in tests/visual-baseline/${baselineVersion}/`);
    console.log(`📝 Commit now: git add tests/visual-baseline/ && git commit -m 'Add baseline ${baselineVersion}'`);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

createBaseline();
