const { chromium } = require('@playwright/test');
const { spawn } = require('child_process');
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

let serverProcess = null;

async function startServer(command, port) {
  return new Promise((resolve, reject) => {
    console.log(`🚀 Avvio server: ${command} (porta ${port})`);

    serverProcess = spawn('sh', ['-c', command], {
      cwd: path.join(__dirname, '../..'),
      stdio: 'pipe'
    });

    serverProcess.stdout.on('data', (data) => {
      const output = data.toString();
      if (output.includes('Server address') || output.includes('Serving')) {
        console.log(`✅ Server ready on port ${port}`);
        setTimeout(resolve, 2000);
      }
    });

    serverProcess.stderr.on('data', (data) => {
      console.error(` stderr: ${data}`);
    });

    serverProcess.on('error', (error) => {
      reject(error);
    });

    setTimeout(resolve, 5000);
  });
}

async function stopServer() {
  if (serverProcess) {
    console.log('🛑 Terminazione server...');
    serverProcess.kill('SIGTERM');
    setTimeout(() => {
      if (serverProcess) serverProcess.kill('SIGKILL');
      serverProcess = null;
    }, 2000);
  }
}

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

  try {
    await startServer('make serve', 4000);
    await captureScreenshots('serve', 'http://localhost:4000');
    await stopServer();

    await startServer('make serve-static', 8000);
    await captureScreenshots('static', 'http://localhost:8000');
    await stopServer();

    console.log('\n✅ All screenshots captured successfully!');
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    await stopServer();
    process.exit(1);
  }
}

main();
