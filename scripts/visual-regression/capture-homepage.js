const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

async function captureHomepage() {
  console.log('📸 Capturing homepage with Puppeteer...');

  const browser = await puppeteer.launch({
    headless: true,
    executablePath: '/usr/bin/chromium',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  // Set viewport desktop
  await page.setViewport({ width: 1920, height: 1080 });

  console.log('🔗 Loading http://localhost:4000/');

  await page.goto('http://localhost:4000/', {
    waitUntil: 'load',
    timeout: 30000
  });

  // Cards are now immediately visible - no animations to wait for
  console.log('✅ Page loaded, capturing full page screenshot...');

  // Take full page screenshot
  const baselinePath = path.join(__dirname, '../../tests/visual-baseline/desktop/index.png');
  const dir = path.dirname(baselinePath);

  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  await page.screenshot({
    path: baselinePath,
    fullPage: true
  });

  await browser.close();

  console.log('✅ Homepage screenshot saved to:', baselinePath);
}

captureHomepage().catch(console.error);
