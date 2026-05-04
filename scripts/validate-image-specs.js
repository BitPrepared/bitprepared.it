const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const SPECS = {
  volantino: {
    width: 3508,
    height: 4961,
    maxSizeBytes: 500 * 1024, // 500 KB
    pattern: /locandina_.*\.jpg$/
  },
  featured: {
    width: 1200,
    height: 630,
    maxSizeBytes: 200 * 1024, // 200 KB
    pattern: /-featured\.(jpg|jpeg|webp)$/
  },
  generic: {
    width: 1200,
    height: 630,
    maxSizeBytes: 300 * 1024, // 300 KB
    pattern: /generic-featured\.png$/
  }
};

async function validateImage(filepath, type) {
  const spec = SPECS[type];

  try {
    const metadata = await sharp(filepath).metadata();
    const stats = fs.statSync(filepath);

    const errors = [];

    // Check dimensions
    if (metadata.width !== spec.width || metadata.height !== spec.height) {
      errors.push(`Wrong dimensions: ${metadata.width}×${metadata.height}, expected ${spec.width}×${spec.height}`);
    }

    // Check file size
    if (stats.size > spec.maxSizeBytes) {
      const sizeKB = Math.round(stats.size / 1024);
      const maxKB = Math.round(spec.maxSizeBytes / 1024);
      errors.push(`Too large: ${sizeKB}KB, max ${maxKB}KB`);
    }

    return { valid: errors.length === 0, errors };
  } catch (err) {
    return { valid: false, errors: [`Cannot read image: ${err.message}`] };
  }
}

async function checkDirectory(dir) {
  let failed = 0;

  const walk = async (dirPath) => {
    const files = fs.readdirSync(dirPath);

    for (const file of files) {
      const filePath = path.join(dirPath, file);
      const stat = fs.statSync(filePath);

      if (stat.isDirectory()) {
        await walk(filePath);
      } else {
        // Determine type from filename
        let type = null;
        if (file.match(SPECS.volantino.pattern)) type = 'volantino';
        else if (file.match(SPECS.featured.pattern)) type = 'featured';
        else if (file.match(SPECS.generic.pattern)) type = 'generic';

        if (type) {
          const result = await validateImage(filePath, type);

          if (!result.valid) {
            console.error(`❌ ${filePath}`);
            result.errors.forEach(e => console.error(`   ${e}`));
            console.error('');
            failed++;
          }
        }
      }
    }
  };

  await walk(dir);
  return failed;
}

async function main() {
  const imagesDir = path.join(__dirname, '../src/jekyll/assets/images');

  console.log('🔍 Validating image specifications...\n');

  const failed = await checkDirectory(imagesDir);

  if (failed > 0) {
    console.error(`❌ ${failed} image(s) failed validation\n`);
    console.error('📝 See docs/IMAGE_GUIDE.md for specifications\n');
    process.exit(1);
  }

  console.log('✅ All images meet specifications\n');
}

main().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
