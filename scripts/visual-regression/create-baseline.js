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
  '/tags/',
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

async function createBaseline() {
  console.log('=== Creating Visual Baseline ===\n');

  const hostIp = process.env.HOST_IP || 'localhost';
  console.log(`Using http://${hostIp}:4000 as baseline source\n`);
  console.log('⚠️  Make sure "make serve" is running on port 4000\n');

  try {
    console.log('📸 Capturing baseline images...');

    const browser = await chromium.launch({
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

          await page.goto(fullUrl, {
            waitUntil: 'networkidle',
            timeout: 30000
          });

          const filename = pageUrl.replace(/^\//, '').replace(/\/$/, '').replace(/\//g, '_') || 'index';
          const baselinePath = path.join(__dirname, `../../tests/visual-baseline/${viewportName}/${filename}.png`);

          const dir = path.dirname(baselinePath);
          if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
          }

          await page.screenshot({
            path: baselinePath,
            fullPage: true
          });

          await page.close();
        } catch (error) {
          console.error(`    ❌ Error capturing ${pageUrl}: ${error.message}`);
        }
      }

      await context.close();
    }

    await browser.close();

    console.log('\n✅ Baseline created successfully in tests/visual-baseline/');
    console.log('📝 Commit these files to git to save the baseline');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

createBaseline();
