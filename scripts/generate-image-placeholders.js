const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const yaml = require('js-yaml');

// Directory constants
const MATRICE_DIR = 'src/matrici/images';
const OPTIMIZE_DIR = 'src/jekyll/assets/images';

// Load configurations
const eventiPath = path.join(__dirname, '../src/jekyll/_data/eventi.yaml');
const ambientazioniPath = path.join(__dirname, '../src/jekyll/_data/ambientazioni.yaml');

const eventi = yaml.load(fs.readFileSync(eventiPath, 'utf8'));
const ambientazioni = yaml.load(fs.readFileSync(ambientazioniPath, 'utf8'));

async function createPlaceholder(filepath, labelText, force = false) {
  const dir = path.dirname(filepath);

  // Create directory if needed
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Check if file exists and is not a placeholder
  if (fs.existsSync(filepath) && !force) {
    const stats = fs.statSync(filepath);
    // If file is larger than 1KB, it's probably a real image
    if (stats.size > 1024) {
      console.log(`⊘ Skipped existing image: ${filepath} (${stats.size} bytes)`);
      console.log(`  Use --force to overwrite`);
      return;
    }
  }

  // Create 1×1 red pixel with EXIF metadata
  const buffer = await sharp({
    create: {
      width: 1,
      height: 1,
      channels: 4,
      background: { r: 255, g: 0, b: 0, alpha: 1 }
    }
  })
    .png()
    .toBuffer();

  fs.writeFileSync(filepath, buffer);

  const action = force ? '✓ Overwrote' : '✓ Created';
  console.log(`${action} placeholder: ${filepath}`);
  console.log(`  Label: ${labelText}`);
}

async function generateEventPlaceholders(force) {
  const currentYear = new Date().getFullYear();

  for (const [key, event] of Object.entries(eventi)) {
    const filename = `locandina_${event.slug}_${currentYear}.png`;
    const filepath = path.join(__dirname, '../', MATRICE_DIR, 'production/eventi', event.slug, filename);
    const label = `PLACEHOLDER - Volantino ${event.name} ${currentYear}`;

    await createPlaceholder(filepath, label, force);
  }
}

async function generatePostPlaceholders(force) {
  for (const [eventKey, event] of Object.entries(eventi)) {
    for (const [ambKey, amb] of Object.entries(ambientazioni)) {
      const filename = `${event.slug}-${amb.slug}-featured.png`;
      const filepath = path.join(__dirname, '../', MATRICE_DIR, 'production/eventi', event.slug, filename);
      const label = `PLACEHOLDER - ${event.name} / ${amb.name}`;

      await createPlaceholder(filepath, label, force);
    }
  }
}

async function main() {
  const args = process.argv.slice(2);
  const force = args.includes('--force');

  if (force) {
    console.log('⚠️  Force mode enabled - will overwrite existing images\n');
  }

  console.log('📸 Generating image placeholders...\n');

  await generateEventPlaceholders(force);
  console.log('');
  await generatePostPlaceholders(force);

  // Also handle generic-featured.png (not in eventi.yaml)
  const genericPath = path.join(__dirname, '../', MATRICE_DIR, 'generic-featured.png');
  await createPlaceholder(genericPath, 'PLACEHOLDER - Generic Featured', force);

  console.log('\n✅ All placeholders generated');
  console.log('📝 See docs/IMAGE_GUIDE.md for image specifications');
  console.log('💡 Use --force to overwrite existing images');
}

main().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
