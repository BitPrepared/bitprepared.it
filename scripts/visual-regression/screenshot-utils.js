const waitForImages = async (page, timeout = 3000) => {
  await page.evaluate((imageTimeout) => {
    const images = Array.from(document.querySelectorAll('img'));
    return Promise.all(images.map(img => {
      if (img.complete && img.naturalHeight > 0) return;
      return new Promise(resolve => {
        img.addEventListener('load', resolve);
        img.addEventListener('error', resolve);
        setTimeout(resolve, imageTimeout);
      });
    }));
  }, timeout);
};

const generateFilename = (url) => {
  return url
    .replace(/^\//, '')
    .replace(/\/$/, '')
    .replace(/\//g, '_')
    .replace(/#/g, '_hash_')
    || 'index';
};

const captureScreenshot = async (page, url, path) => {
  try {
    await page.goto(url, {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    await waitForImages(page);
    await page.waitForTimeout(500); // Extra delay for stable rendering

    await page.screenshot({
      path: path,
      fullPage: true
    });
  } catch (error) {
    throw new Error(`Failed to capture screenshot for ${url} at ${path}: ${error.message}`);
  }
};

module.exports = { waitForImages, generateFilename, captureScreenshot };
