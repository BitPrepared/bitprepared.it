const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');
const { captureScreenshot, generateFilename } = require('./screenshot-utils');

// Handle interrupt signals
let browsers = [];
process.on('SIGINT', async () => {
  console.log('\n\n⚠️  Interrupted, cleaning up...');
  for (const b of browsers) await b.close();
  process.exit(130);
});

process.on('SIGTERM', async () => {
  for (const b of browsers) await b.close();
  process.exit(143);
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

async function captureScreenshots(serverType, baseUrl, viewportsToUse) {
  console.log(`\n📸 Capturing screenshots from ${serverType}...`);

  const browser = await chromium.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--disable-software-rasterizer',
      '--disable-extensions',
      '--disable-background-networking',
      '--disable-default-apps',
      '--disable-sync',
      '--metrics-recording-only',
      '--mute-audio',
      '--no-first-run',
      '--safebrowsing-disable-auto-update',
      '--disable-popup-blocking'
    ]
  });
  browsers.push(browser); // Track for cleanup

  for (const [viewportName, viewport] of Object.entries(viewportsToUse)) {
    console.log(`  📱 Viewport: ${viewportName} (${viewport.width}x${viewport.height})`);

    // Create context with viewport
    const context = await browser.newContext({
      viewport: viewport
    });

    for (const pageUrl of pages) {
      try {
        const page = await context.newPage();
        const fullUrl = `${baseUrl}${pageUrl}`;

        console.log(`    🔗 ${pageUrl}`);

        const filename = generateFilename(pageUrl);
        const screenshotPath = path.join(__dirname, `../../output/screenshots/${serverType}/${viewportName}/${filename}.png`);

        const dir = path.dirname(screenshotPath);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }

        await captureScreenshot(page, fullUrl, screenshotPath);

        await page.close();
      } catch (error) {
        console.error(`    ❌ Error capturing ${pageUrl}: ${error.message}`);
      }
    }

    await context.close();
  }

  await browser.close();
  browsers = browsers.filter(b => b !== browser); // Remove from tracking
  console.log(`✅ Screenshots captured for ${serverType}`);
}

async function main() {
  console.log('=== Visual Regression Capture ===\n');

  // Debug user info
  console.log(`Running as UID: ${process.getuid()}`);
  console.log(`Running as GID: ${process.getgid()}`);

  const hostIp = process.env.HOST_IP || 'localhost';
  console.log(`Using host: ${hostIp}\n`);

  // Filter viewports if specified
  const viewportFilter = process.env.VIEWPORTS ? process.env.VIEWPORTS.split(',') : [];
  const filteredViewports = viewportFilter.length > 0
    ? Object.fromEntries(Object.entries(viewports).filter(([key]) => viewportFilter.includes(key)))
    : viewports;

  if (viewportFilter.length > 0) {
    console.log(`🎯 Filtering viewports: ${viewportFilter.join(', ')}\n`);
  }

  try {
    // Servers gia avviati sul host
    await captureScreenshots('serve', `http://${hostIp}:4000`, filteredViewports);
    await captureScreenshots('static', `http://${hostIp}:8000`, filteredViewports);

    console.log('\n✅ All screenshots captured successfully!');
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

main();
