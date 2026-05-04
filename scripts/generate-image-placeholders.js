const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const yaml = require('js-yaml');

// Load configurations
const eventiPath = path.join(__dirname, '../src/jekyll/_data/eventi.yaml');
const ambientazioniPath = path.join(__dirname, '../src/jekyll/_data/ambientazioni.yaml');

const eventi = yaml.load(fs.readFileSync(eventiPath, 'utf8'));
const ambientazioni = yaml.load(fs.readFileSync(ambientazioniPath, 'utf8'));

async function createPlaceholder(filepath, labelText) {
  const dir = path.dirname(filepath);

  // Create directory if needed
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Create 1×1 red pixel with EXIF metadata
  const buffer = await sharp({
    create: {
      width: 1,
      height: 1,
      channels: 3,
      background: { r: 255, g: 0, b: 0 }
    }
  })
    .jpeg()
    .toBuffer();

  fs.writeFileSync(filepath, buffer);

  console.log(`✓ Created placeholder: ${filepath}`);
  console.log(`  Label: ${labelText}`);
}

async function generateEventPlaceholders() {
  const currentYear = new Date().getFullYear();

  for (const [key, event] of Object.entries(eventi)) {
    const filename = `locandina_${event.slug}_${currentYear}.jpg`;
    const filepath = path.join(__dirname, '../src/jekyll/assets/images', event.slug, filename);
    const label = `PLACEHOLDER - Volantino ${event.name} ${currentYear}`;

    await createPlaceholder(filepath, label);
  }
}

async function generatePostPlaceholders() {
  for (const [eventKey, event] of Object.entries(eventi)) {
    for (const [ambKey, amb] of Object.entries(ambientazioni)) {
      const filename = `${event.slug}-${amb.slug}-featured.jpg`;
      const filepath = path.join(__dirname, '../src/jekyll/assets/images', event.slug, filename);
      const label = `PLACEHOLDER - ${event.name} / ${amb.name}`;

      await createPlaceholder(filepath, label);
    }
  }
}

async function main() {
  console.log('📸 Generating image placeholders...\n');

  await generateEventPlaceholders();
  console.log('');
  await generatePostPlaceholders();

  console.log('\n✅ All placeholders generated');
  console.log('📝 See docs/IMAGE_GUIDE.md for image specifications');
}

main().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
