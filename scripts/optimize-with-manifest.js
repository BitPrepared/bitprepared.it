const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const MATRICE_DIR = 'src/matrici/images';
const ASSETS_DIR = 'src/jekyll/assets/images';

// Load manifesti
function loadManifests() {
  let lockedFiles = [];

  if (fs.existsSync(`${MATRICE_DIR}/.locked`)) {
    lockedFiles = fs.readFileSync(`${MATRICE_DIR}/.locked`, 'utf8')
      .split('\n')
      .filter(line => line && !line.startsWith('#'))
      .map(line => line.trim());
  }

  return { lockedFiles };
}

// Parse .rules file
function parseRules(rulesPath) {
  const rules = {};

  // Check if rules file exists
  if (!fs.existsSync(rulesPath)) {
    console.warn(`⚠️  Rules file not found: ${rulesPath}`);
    return rules;
  }

  const content = fs.readFileSync(rulesPath, 'utf8');

  // Match [category] sections and their content
  const sectionRegex = /\[([^\]]+)\]\s*([^[]*)/g;
  let match;

  while ((match = sectionRegex.exec(content)) !== null) {
    const category = match[1].trim();
    const sectionContent = match[2].trim();

    if (category && sectionContent) {
      rules[category] = {};

      // Parse key-value pairs in section content
      const lines = sectionContent.split('\n');
      lines.forEach(line => {
        line = line.trim();
        if (line && !line.startsWith('#')) {
          const parts = line.split(':').map(s => s.trim());
          if (parts.length >= 2 && parts[0] && parts[1]) {
            const [key, value] = parts;
            rules[category][key] = value;
          }
        }
      });
    }
  }

  return rules;
}

// Get category from file path
function getCategory(relativePath) {
  if (relativePath.startsWith('eventi/')) return 'production/eventi';
  if (relativePath.startsWith('software/')) return 'production/software';
  if (relativePath.startsWith('loghi-branche/')) return 'production/loghi-branche';
  if (relativePath.startsWith('root/')) return 'production/root';
  if (relativePath.startsWith('pages/')) return 'production/pages';
  return null;
}

// Find all PNG files recursively
function findFiles(dir, ext) {
  const files = [];

  if (!fs.existsSync(dir)) {
    console.log(`⚠️  Directory not found: ${dir}`);
    return files;
  }

  function traverse(currentPath) {
    const entries = fs.readdirSync(currentPath, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(currentPath, entry.name);

      if (entry.isDirectory()) {
        traverse(fullPath);
      } else if (entry.isFile() && entry.name.endsWith(ext)) {
        files.push(fullPath);
      }
    }
  }

  traverse(dir);
  return files;
}

// Copy file without modification
async function copyFile(src, dest) {
  const destDir = path.dirname(dest);

  // Create destination directory if it doesn't exist
  if (!fs.existsSync(destDir)) {
    fs.mkdirSync(destDir, { recursive: true });
  }

  fs.copyFileSync(src, dest);
  console.log(`📋 Copied: ${path.relative(MATRICE_DIR, src)} → ${path.relative(ASSETS_DIR, dest)}`);
}

// Convert image according to rules
async function convertImage(src, dest, rule) {
  const destDir = path.dirname(dest);

  // Create destination directory if it doesn't exist
  if (!fs.existsSync(destDir)) {
    fs.mkdirSync(destDir, { recursive: true });
  }

  try {
    let pipeline = sharp(src);

    // Parse dimensions if specified
    if (rule.dimensions) {
      const [width, height] = rule.dimensions.split('x').map(Number);

      // Validate dimensions are valid numbers
      if (isNaN(width) || isNaN(height)) {
        throw new Error(`Invalid dimensions: ${rule.dimensions} (must be numbers)`);
      }

      pipeline = pipeline.resize(width, height, {
        fit: 'inside',
        withoutEnlargement: true
      });
    }

    // Determine output format with null safety check
    if (!rule.convert_to) {
      throw new Error('convert_to rule is missing or null');
    }

    const format = rule.convert_to.toLowerCase();
    let outputPath = dest;

    if (format === 'jpg' || format === 'jpeg') {
      // Change extension to .jpg
      outputPath = dest.replace(/\.png$/i, '.jpg');

      // Validate quality is a valid number
      const quality = parseInt(rule.quality);
      if (rule.quality && isNaN(quality)) {
        throw new Error(`Invalid quality value: ${rule.quality} (must be a number)`);
      }

      pipeline = pipeline.jpeg({ quality: quality || 85 });
    } else if (format === 'webp') {
      outputPath = dest.replace(/\.png$/i, '.webp');

      // Validate quality is a valid number
      const quality = parseInt(rule.quality);
      if (rule.quality && isNaN(quality)) {
        throw new Error(`Invalid quality value: ${rule.quality} (must be a number)`);
      }

      pipeline = pipeline.webp({ quality: quality || 85 });
    } else if (format === 'png') {
      pipeline = pipeline.png();
    }

    await pipeline.toFile(outputPath);
    console.log(`📸 Converted: ${path.relative(MATRICE_DIR, src)} → ${path.relative(ASSETS_DIR, outputPath)}`);
  } catch (error) {
    console.error(`❌ Error converting ${src}:`, error.message);
    throw error;
  }
}

// Main optimization function
async function optimizeImages() {
  const { lockedFiles } = loadManifests();
  const rules = parseRules(`${MATRICE_DIR}/.rules`);
  const productionDir = path.join(MATRICE_DIR, 'production');

  console.log('🔍 Finding PNG files in production/...');
  const files = findFiles(productionDir, '.png');

  console.log(`📁 Found ${files.length} PNG files to process`);

  let processed = 0;
  let skipped = 0;
  let errors = 0;

  for (const file of files) {
    const relativePath = path.relative(productionDir, file);
    const targetPath = path.join(ASSETS_DIR, relativePath);
    const category = getCategory(relativePath);
    const fileName = path.basename(file);

    try {
      // Skip locked files - check both full path and filename
      const isLocked = lockedFiles.includes(relativePath) || lockedFiles.includes(fileName);
      if (isLocked) {
        console.log(`🔒 Locked: ${relativePath}`);
        await copyFile(file, targetPath);
        processed++;
        continue;
      }

      // Apply rules
      if (category && rules[category]) {
        const rule = rules[category];

        if (rule.copy_only === 'true') {
          await copyFile(file, targetPath);
          processed++;
        } else if (rule.convert_to) {
          await convertImage(file, targetPath, rule);
          processed++;
        } else {
          console.log(`⚠️  No rule for ${relativePath} in category ${category}`);
          skipped++;
        }
      } else {
        console.log(`⚠️  No category found for: ${relativePath}`);
        skipped++;
      }
    } catch (error) {
      console.error(`❌ Failed to process ${relativePath}:`, error.message);
      errors++;
    }
  }

  console.log('\n📊 Summary:');
  console.log(`   ✅ Processed: ${processed}`);
  console.log(`   ⏭️  Skipped: ${skipped}`);
  console.log(`   ❌ Errors: ${errors}`);
  console.log('\n✅ Ottimizzazione completata');
}

// Run
optimizeImages().catch(err => {
  console.error('❌ Errore:', err);
  process.exit(1);
});
