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

async function createBaseline() {
  console.log('=== Creating Visual Baseline ===\n');
  console.log('Using make serve (Jekyll dev server) as baseline source\n');

  try {
    await startServer('make serve', 4000);

    console.log('\n📸 Capturing baseline images...');

    const browser = await chromium.launch({
      headless: true
    });

    const context = await browser.newContext({
      viewport: null
    });

    for (const [viewportName, viewport] of Object.entries(viewports)) {
      console.log(`\n  📱 Viewport: ${viewportName} (${viewport.width}x${viewport.height})`);

      await context.setViewportSize(viewport);

      for (const pageUrl of pages) {
        try {
          const page = await context.newPage();
          const fullUrl = `http://localhost:4000${pageUrl}`;

          console.log(`    🔗 ${pageUrl}`);

          await page.goto(fullUrl, {
            waitUntil: 'networkidle',
            timeout: 30000
          });

          const filename = pageUrl.replace(/\//g, '_').replace(/^_/, '') || 'index';
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
    }

    await browser.close();
    await stopServer();

    console.log('\n✅ Baseline created successfully in tests/visual-baseline/');
    console.log('📝 Commit these files to git to save the baseline');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    await stopServer();
    process.exit(1);
  }
}

createBaseline();
