const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const OPTIMIZE_DIR = 'src/jekyll/assets/images';

function validateImageSpecs(filePath) {
  try {
    const info = execSync(`identify "${filePath}"`, { encoding: 'utf-8' });
    const stats = fs.statSync(filePath);

    const match = info.match(/(\d+)x(\d+)\s+(\w+)/);
    if (!match) return { valid: false, error: 'Cannot parse image info' };

    const [, width, height, format] = match;
    const sizeKB = stats.size / 1024;

    if (filePath.includes('locandina_')) {
      if (width !== '3508' || height !== '4961') {
        return { valid: false, error: `Wrong dimensions: ${width}x${height} (expected 3508x4961)` };
      }
      if (sizeKB > 500) {
        return { valid: false, error: `Too large: ${Math.round(sizeKB)}KB (max 500KB)` };
      }
      if (format !== 'JPEG') {
        return { valid: false, error: `Wrong format: ${format} (expected JPG)` };
      }
    } else if (filePath.includes('-featured.')) {
      if (width !== '1200' || height !== '630') {
        return { valid: false, error: `Wrong dimensions: ${width}x${height} (expected 1200x630)` };
      }
      if (sizeKB > 200) {
        return { valid: false, error: `Too large: ${Math.round(sizeKB)}KB (max 200KB)` };
      }
      if (format !== 'JPEG') {
        return { valid: false, error: `Wrong format: ${format} (expected JPG)` };
      }
    } else if (filePath.includes('generic-featured.jpg')) {
      if (width !== '1200' || height !== '630') {
        return { valid: false, error: `Wrong dimensions: ${width}x${height} (expected 1200x630)` };
      }
      if (sizeKB > 300) {
        return { valid: false, error: `Too large: ${Math.round(sizeKB)}KB (max 300KB)` };
      }
    }

    return { valid: true };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

function validateAllImages() {
  let errors = 0;
  let checked = 0;

  const walkDir = (dir) => {
    const files = fs.readdirSync(dir);
    files.forEach(file => {
      const filePath = path.join(dir, file);
      const stat = fs.statSync(filePath);
      if (stat.isDirectory()) {
        walkDir(filePath);
      } else if (file.match(/\.(jpg|jpeg)$/i)) {
        checked++;
        const result = validateImageSpecs(filePath);
        if (!result.valid) {
          console.error(`❌ ${filePath}: ${result.error}`);
          errors++;
        }
      }
    });
  };

  console.log('🔍 Validating optimized images...');
  walkDir(OPTIMIZE_DIR);

  console.log(`\n✅ Checked ${checked} images`);
  if (errors > 0) {
    console.error(`\n❌ Found ${errors} errors`);
    process.exit(1);
  } else {
    console.log('✅ All images meet specifications');
  }
}

validateAllImages();
