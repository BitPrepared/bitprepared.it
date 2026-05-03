const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const IMAGE_SIZES = [
  { name: 'mobile', width: 640, suffix: '-m' },
  { name: 'tablet', width: 1024, suffix: '-t' },
  { name: 'desktop', width: 1920, suffix: '-d' }
];

function optimizeImage(inputPath, outputPath, width) {
  const tmpPath = outputPath + '.tmp';

  try {
    // Check if convert is available
    execSync('which convert', { stdio: 'ignore' });
    execSync(`convert "${inputPath}" -resize ${width}x -quality 85 "${tmpPath}"`, { stdio: 'inherit' });
    fs.renameSync(tmpPath, outputPath);
    console.log(`✅ Optimized: ${path.basename(outputPath)} (${width}px)`);
  } catch (error) {
    // If ImageMagick not available, just copy the file
    if (error.status === 1) {
      fs.copyFileSync(inputPath, outputPath);
      console.log(`⚠️  ImageMagick not available, copied: ${path.basename(outputPath)}`);
    } else {
      console.error(`❌ Error optimizing ${inputPath}:`, error.message);
    }
  }
}

function processImages() {
  const imagesDir = 'output/_site/assets/images';

  if (!fs.existsSync(imagesDir)) {
    console.log('❌ Images directory not found');
    return;
  }

  fs.readdirSync(imagesDir).forEach(file => {
    if (!/\.(jpg|jpeg|png|webp)$/i.test(file)) return;

    const inputPath = path.join(imagesDir, file);
    const ext = path.extname(file);
    const basename = path.basename(file, ext);

    IMAGE_SIZES.forEach(size => {
      const outputPath = path.join(imagesDir, `${basename}${size.suffix}${ext}`);
      optimizeImage(inputPath, outputPath, size.width);
    });
  });
}

processImages();
console.log('🎉 Image optimization complete');
