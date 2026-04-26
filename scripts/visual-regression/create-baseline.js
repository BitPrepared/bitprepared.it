const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

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

          await page.goto(fullUrl, {
            waitUntil: 'networkidle',
            timeout: 30000
          });

          // Homepage: wait for images to load (lazy loading issue)
          if (pageUrl === '/' || pageUrl === '') {
            await page.evaluate(() => {
              const images = Array.from(document.querySelectorAll('img[loading="lazy"]'));
              images.forEach(img => img.loading = 'eager');
            });
            await page.waitForTimeout(500); // Small wait for images
          } else {
            // Other pages: wait for marker with short timeout
            await page.waitForSelector('[data-visual-regression-marker="ready"]', {
              timeout: 2000
            }).catch(() => {}); // Silent fail
          }

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
