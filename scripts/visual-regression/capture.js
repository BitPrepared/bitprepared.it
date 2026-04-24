const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

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
  browsers.push(browser); // Track for cleanup

  for (const [viewportName, viewport] of Object.entries(viewports)) {
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

        await page.goto(fullUrl, {
          waitUntil: 'networkidle',
          timeout: 30000
        });

        // Homepage: wait for images to load (lazy loading issue)
        if (pageUrl === '/' || pageUrl === '') {
          await page.evaluate(() => {
            const images = Array.from(document.querySelectorAll('img'));
            return Promise.all(images.map(img => {
              if (img.complete) return;
              return new Promise(resolve => {
                img.addEventListener('load', resolve);
                img.addEventListener('error', resolve); // Also handle load errors
                setTimeout(resolve, 1000); // Timeout 1s per image
              });
            }));
          });
        } else {
          // Other pages: wait for marker with short timeout
          await page.waitForSelector('[data-visual-regression-marker="ready"]', {
            timeout: 2000
          }).catch(() => {}); // Silent fail
        }

        const filename = pageUrl.replace(/^\//, '').replace(/\/$/, '').replace(/\//g, '_') || 'index';
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

    await context.close();
  }

  await browser.close();
  browsers = browsers.filter(b => b !== browser); // Remove from tracking
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
