const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const viewports = {
  desktop: { width: 1920, height: 1080 },
  tablet: { width: 768, height: 1024 },
  mobile: { width: 375, height: 667 }
};

const pages = [
  '/',
  '/about/',
  '/blog/',
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

async function captureScreenshots(serverType, baseUrl) {
  console.log(`\n📸 Capturing screenshots from ${serverType}...`);

  const browser = await chromium.launch({
    headless: true
  });

  const context = await browser.newContext({
    viewport: null
  });

  for (const [viewportName, viewport] of Object.entries(viewports)) {
    console.log(`  📱 Viewport: ${viewportName} (${viewport.width}x${viewport.height})`);

    await context.setViewportSize(viewport);

    for (const pageUrl of pages) {
      try {
        const page = await context.newPage();
        const fullUrl = `${baseUrl}${pageUrl}`;

        console.log(`    🔗 ${pageUrl}`);

        await page.goto(fullUrl, {
          waitUntil: 'networkidle',
          timeout: 30000
        });

        const filename = pageUrl.replace(/\//g, '_').replace(/^_/, '') || 'index';
        const screenshotPath = path.join(__dirname, `../../screenshots/${serverType}/${viewportName}/${filename}.png`);

        const dir = path.dirname(screenshotPath);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }

        await page.screenshot({
          path: screenshotPath,
          fullPage: true
        });

        await page.close();
      } catch (error) {
        console.error(`    ❌ Error capturing ${pageUrl}: ${error.message}`);
      }
    }
  }

  await browser.close();
  console.log(`✅ Screenshots captured for ${serverType}`);
}

async function main() {
  console.log('=== Visual Regression Capture ===\n');

  const hostIp = process.env.HOST_IP || 'localhost';
  console.log(`Using host: ${hostIp}\n`);

  try {
    // Servers gia avviati sul host
    await captureScreenshots('serve', `http://${hostIp}:4000`);
    await captureScreenshots('static', `http://${hostIp}:8000`);

    console.log('\n✅ All screenshots captured successfully!');
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

main();
