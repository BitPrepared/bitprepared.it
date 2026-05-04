const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

async function isPlaceholder(filepath) {
  try {
    const metadata = await sharp(filepath).metadata();

    // 1×1 pixel indicates placeholder
    if (metadata.width === 1 && metadata.height === 1) {
      return true;
    }

    return false;
  } catch (err) {
    console.error(`❌ Error checking ${filepath}:`, err.message);
    return false;
  }
}

async function checkDirectory(dir) {
  const placeholders = [];

  const walk = async (dirPath) => {
    const files = fs.readdirSync(dirPath);

    for (const file of files) {
      const filePath = path.join(dirPath, file);
      const stat = fs.statSync(filePath);

      if (stat.isDirectory()) {
        await walk(filePath);
      } else if (file.match(/\.(jpg|jpeg|png)$/i)) {
        if (filePath.includes('locandina_') || file.includes('-featured.')) {
          if (await isPlaceholder(filePath)) {
            placeholders.push(filePath);
          }
        }
      }
    }
  };

  await walk(dir);
  return placeholders;
}

async function main() {
  const imagesDir = path.join(__dirname, '../src/jekyll/assets/images');

  console.log('🔍 Checking for placeholder images...\n');

  const placeholders = await checkDirectory(imagesDir);

  if (placeholders.length > 0) {
    console.error(`❌ Found ${placeholders.length} placeholder images:\n`);
    placeholders.forEach(p => console.error(`   - ${p}`));
    console.error('\n⚠️  Replace placeholders with real images before deploying\n');
    console.error('📝 See docs/IMAGE_GUIDE.md for specifications\n');
    process.exit(1);
  }

  console.log('✅ No placeholder images found\n');
}

main().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
