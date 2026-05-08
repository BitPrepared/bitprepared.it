const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const SVG_SOURCE = 'src/matrici/images/source-icons/site-icon.svg';
const OUTPUT_DIR = 'src/jekyll/assets/images';

async function generateIcons() {
  if (!fs.existsSync(SVG_SOURCE)) {
    console.error('❌ ERRORE: site-icon.svg non trovato');
    console.log('   Crea: src/matrici/images/source-icons/site-icon.svg');
    process.exit(1);
  }

  console.log('🎨 Generazione icone da SVG...');

  // Apple touch icons
  const sizes = [72, 114, 144];
  for (const size of sizes) {
    const filename = `apple-touch-icon-${size}x${size}-precomposed.png`;
    await sharp(SVG_SOURCE)
      .resize(size, size)
      .png()
      .toFile(path.join(OUTPUT_DIR, filename));
    console.log(`   ✓ ${filename}`);
  }

  // Fallback PNG
  await sharp(SVG_SOURCE)
    .resize(192, 192)
    .png()
    .toFile(path.join(OUTPUT_DIR, 'apple-touch-icon-precomposed.png'));
  console.log('   ✓ apple-touch-icon-precomposed.png (fallback)');

  // Manifest.json for PWA
  const manifest = {
    name: "Bit Prepared",
    icons: [
      { src: "/assets/images/apple-touch-icon-72x72-precomposed.png", sizes: "72x72", type: "image/png" },
      { src: "/assets/images/apple-touch-icon-114x114-precomposed.png", sizes: "114x114", type: "image/png" },
      { src: "/assets/images/apple-touch-icon-144x144-precomposed.png", sizes: "144x144", type: "image/png" }
    ]
  };

  fs.writeFileSync(
    path.join(OUTPUT_DIR, 'manifest.json'),
    JSON.stringify(manifest, null, 2)
  );
  console.log('   ✓ manifest.json');

  console.log('✅ Icone generate');
}

generateIcons().catch(err => {
  console.error('❌ Errore:', err);
  process.exit(1);
});
