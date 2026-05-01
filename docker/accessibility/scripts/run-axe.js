#!/usr/bin/env node
const puppeteer = require('puppeteer');
const fs = require('fs');

const SITE_URL = process.argv[2];
const OUTPUT_FILE = process.argv[3];

async function runAxe() {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-gpu'],
    executablePath: '/usr/bin/chromium'
  });

  try {
    const page = await browser.newPage();
    await page.goto(SITE_URL, { waitUntil: 'networkidle0' });

    // Inject and run axe-core
    const results = await page.evaluate(async () => {
      // Load axe-core from CDN
      await new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.8.2/axe.min.js';
        script.onload = resolve;
        script.onerror = reject;
        document.head.appendChild(script);
      });

      // Run axe
      return await axe.run({
        runOnly: {
          type: 'tag',
          values: ['wcag2a', 'wcag2aa', 'best-practice']
        }
      });
    });

    // Save results
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));

    const violations = results.violations.length;
    console.log(`✅ axe-core complete - ${violations} violations found`);

  } finally {
    await browser.close();
  }
}

runAxe().catch(console.error);
