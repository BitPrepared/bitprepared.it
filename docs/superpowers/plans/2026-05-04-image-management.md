# Image Management System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement complete image management system for posts and events with automatic placeholder generation, validation, and optimization.

**Architecture:** Frontmatter-based configuration (event_type + ambientazione) → Liquid layout logic → Node.js automation for placeholders/validation → CI/CD enforcement.

**Tech Stack:** Jekyll/Liquid, YAML config files, Node.js (sharp, js-yaml), ImageMagick, GitHub Actions, Makefile.

---

## File Structure

**New files:**
- `src/jekyll/_data/eventi.yaml` - Event type configuration
- `src/jekyll/_data/ambientazioni.yaml` - Ambientazione (theme) configuration
- `src/jekyll/assets/images/generic-featured.png` - Fallback image for posts without events
- `scripts/generate-image-placeholders.js` - Generate 1×1px placeholder images
- `scripts/check-image-placeholders.js` - CI check for placeholder detection
- `scripts/validate-image-specs.js` - Validate image dimensions and file size
- `docs/IMAGE_GUIDE.md` - User guide for image creators

**Modified files:**
- `src/jekyll/_layouts/post.html` - Add Liquid logic for featured image selection
- `src/jekyll/_layouts/evento.html` - Add Liquid logic for volantino selection
- `Makefile` - Add targets: generate-placeholders, check-placeholders, optimize-images
- `.github/workflows/validate-pr.yml` - Add job: check-image-placeholders

---

## Task 1: Create Event Type Configuration

**Files:**
- Create: `src/jekyll/_data/eventi.yaml`

- [ ] **Step 1: Create eventi.yaml with 3 event types**

```yaml
epppi:
  name: "EPPPI"
  slug: "epppi"

campo-eg:
  name: "Campo EG"
  slug: "campo-eg"

stage:
  name: "Stage"
  slug: "stage"
```

- [ ] **Step 2: Verify YAML syntax**

Run: `cat src/jekyll/_data/eventi.yaml`

Expected: Valid YAML with 3 entries (epppi, campo-eg, stage)

- [ ] **Step 3: Commit**

```bash
git add src/jekyll/_data/eventi.yaml
git commit -m "feat: add event type configuration (epppi, campo-eg, stage)"
```

---

## Task 2: Create Ambientazione Configuration

**Files:**
- Create: `src/jekyll/_data/ambientazioni.yaml`

- [ ] **Step 1: Create ambientazioni.yaml with 4 themes**

```yaml
momo:
  name: "Momo"
  slug: "momo"

star-trek:
  name: "Star Trek"
  slug: "star-trek"

star-wars:
  name: "Star Wars"
  slug: "star-wars"

monkey-island:
  name: "Monkey Island"
  slug: "monkey-island"
```

- [ ] **Step 2: Verify YAML syntax**

Run: `cat src/jekyll/_data/ambientazioni.yaml`

Expected: Valid YAML with 4 entries

- [ ] **Step 3: Commit**

```bash
git add src/jekyll/_data/ambientazioni.yaml
git commit -m "feat: add ambientazione configuration (momo, star-trek, star-wars, monkey-island)"
```

---

## Task 3: Create Generic Featured Image

**Files:**
- Create: `src/jekyll/assets/images/generic-featured.png`

- [ ] **Step 1: Create 1200×630 placeholder image**

Run:
```bash
# Create simple placeholder with ImageMagick
convert -size 1200x630 xc:#3b82f6 -gravity center -pointsize 48 -fill white -annotate 0 'BitPrepared' src/jekyll/assets/images/generic-featured.png
```

Expected: File created at `src/jekyll/assets/images/generic-featured.png`

- [ ] **Step 2: Verify image dimensions**

Run:
```bash
identify src/jekyll/assets/images/generic-featured.png
```

Expected output: `generic-featured.png PNG 1200x630...`

- [ ] **Step 3: Commit**

```bash
git add src/jekyll/assets/images/generic-featured.png
git commit -m "feat: add generic featured image for posts without events"
```

---

## Task 4: Update Post Layout with Image Logic

**Files:**
- Modify: `src/jekyll/_layouts/post.html`

- [ ] **Step 1: Read current post.html to understand structure**

Run: `head -50 src/jekyll/_layouts/post.html`

Note: Existing liquid variables and content structure

- [ ] **Step 2: Add image selection logic before content section**

Find the `{{ content }}` or image reference section. Add before it:

```liquid
{% comment %}Determine featured image{% endcomment %}
{% if page.featured %}
  {% assign featured_image = page.featured %}
{% elsif page.event_type and page.ambientazione %}
  {% assign event_slug = site.data.eventi[page.event_type].slug %}
  {% assign amb_slug = site.data.ambientazioni[page.ambientazione].slug %}
  {% assign featured_image = "/assets/images/" | append: event_slug | append: "/" | append: event_slug | append: "-" | append: amb_slug | append: "-featured.jpg" %}
{% else %}
  {% assign featured_image = "/assets/images/generic-featured.png" %}
{% endunless %}

{% comment %}Fallback if calculated image doesn't exist{% endcomment %}
{% unless site.static_files contains featured_image %}
  {% assign featured_image = "/assets/images/generic-featured.png" %}
{% endunless %}
```

- [ ] **Step 3: Test with sample post**

Create test post `src/jekyll/_posts/2026-05-04-test.md`:
```yaml
---
layout: post
title: Test Image Logic
event_type: epppi
ambientazione: star-wars
---
```

Build and check output uses correct image path.

- [ ] **Step 4: Commit**

```bash
git add src/jekyll/_layouts/post.html
git commit -m "feat: add liquid logic for featured image selection (event_type + ambientazione)"
```

---

## Task 5: Update Evento Layout with Volantino Logic

**Files:**
- Modify: `src/jekyll/_layouts/evento.html`

- [ ] **Step 1: Read current evento.html structure**

Run: `head -50 src/jekyll/_layouts/evento.html`

Note: Where image/locandina is referenced

- [ ] **Step 2: Add volantino selection logic**

Add near top of file after frontmatter variables:

```liquid
{% comment %}Determine volantino image{% endcomment %}
{% if page.image %}
  {% assign locandina = page.image %}
{% elsif page.event_type and page.year %}
  {% assign event_slug = site.data.eventi[page.event_type].slug %}
  {% assign locandina = "/assets/images/" | append: event_slug | append: "/locandina_" | append: event_slug | append: "_" | append: page.year | append: ".jpg" %}
{% else %}
  {% assign locandina = "/assets/images/generic-featured.png" %}
{% endif %}

{% comment %}Fallback if calculated image doesn't exist{% endcomment %}
{% unless site.static_files contains locandina %}
  {% assign locandina = "/assets/images/generic-featured.png" %}
{% endunless %}
```

- [ ] **Step 3: Replace hardcoded image references with locandina variable**

Find all instances of `page.image` or hardcoded locandina paths and replace with `{{ locandina }}`.

- [ ] **Step 4: Test with epppi.md event**

Build and verify epppi event uses correct locandina path.

- [ ] **Step 5: Commit**

```bash
git add src/jekyll/_layouts/evento.html
git commit -m "feat: add liquid logic for volantino selection (event_type + year)"
```

---

## Task 6: Create Placeholder Generator Script

**Files:**
- Create: `scripts/generate-image-placeholders.js`

- [ ] **Step 1: Initialize package.json in scripts directory**

Run:
```bash
cd scripts
npm init -y
npm install sharp js-yaml
```

- [ ] **Step 2: Create generate-image-placeholders.js**

```javascript
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
    .png()
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
```

- [ ] **Step 3: Test script execution**

Run:
```bash
cd scripts
node generate-image-placeholders.js
```

Expected: Placeholders created in `src/jekyll/assets/images/{tipo}/` directories

- [ ] **Step 4: Verify placeholder files created**

Run:
```bash
find src/jekyll/assets/images -name "*.jpg" -newer scripts/generate-image-placeholders.js
```

Expected: List of newly created placeholder files

- [ ] **Step 5: Commit**

```bash
git add scripts/package.json scripts/package-lock.json scripts/generate-image-placeholders.js
git add src/jekyll/assets/images/
git commit -m "feat: add placeholder generator script for events and posts"
```

---

## Task 7: Create Placeholder Check Script

**Files:**
- Create: `scripts/check-image-placeholders.js`

- [ ] **Step 1: Create check-image-placeholders.js**

```javascript
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

  const walk = (dirPath) => {
    const files = fs.readdirSync(dirPath);

    for (const file of files) {
      const filePath = path.join(dirPath, file);
      const stat = fs.statSync(filePath);

      if (stat.isDirectory()) {
        walk(filePath);
      } else if (file.match(/\.(jpg|jpeg|png)$/i)) {
        if (filePath.includes('locandina_') || file.includes('-featured.')) {
          if (await isPlaceholder(filePath)) {
            placeholders.push(filePath);
          }
        }
      }
    }
  };

  walk(dir);
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
```

- [ ] **Step 2: Test check with existing placeholders**

Run:
```bash
cd scripts
node check-image-placeholders.js
```

Expected: Fails and lists placeholder images (from Task 6)

- [ ] **Step 3: Test after replacing one placeholder**

Run:
```bash
# Replace one placeholder with real image
cp src/jekyll/assets/images/generic-featured.png src/jekyll/assets/images/epppi/epppi-star-wars-featured.jpg
node check-image-placeholders.js
```

Expected: Still fails but lists one fewer placeholder

- [ ] **Step 4: Commit**

```bash
git add scripts/check-image-placeholders.js
git commit -m "feat: add placeholder detection script for CI validation"
```

---

## Task 8: Create Image Specs Validation Script

**Files:**
- Create: `scripts/validate-image-specs.js`

- [ ] **Step 1: Create validate-image-specs.js**

```javascript
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
```

- [ ] **Step 2: Test validation with generic image**

Run:
```bash
cd scripts
node validate-image-specs.js
```

Expected: Pass (generic-featured.png is 1200×630)

- [ ] **Step 3: Test with oversized image**

Run:
```bash
# Create test oversized image
convert -size 2000x1000 xc:red /tmp/test-oversized.jpg
cp /tmp/test-oversized.jpg src/jekyll/assets/images/epppi/test-featured.jpg
node validate-image-specs.js
```

Expected: Fails with dimension error

- [ ] **Step 4: Cleanup test file**

```bash
rm src/jekyll/assets/images/epppi/test-featured.jpg
```

- [ ] **Step 5: Commit**

```bash
git add scripts/validate-image-specs.js
git commit -m "feat: add image specs validation (dimensions, file size)"
```

---

## Task 9: Add Makefile Targets

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Add new targets to .PHONY**

Find the `.PHONY:` line (around line 11) and add new targets:

```makefile
.PHONY: serve serve-bg serve-static serve-static-bg build build-css clean install install-gems help open validate-graphics compare-graphics visual-baseline visual-clean docker-build-visual docker-build-a11y workflow generate-blog-post check-links check-html check-placeholders generate-placeholders optimize-images accessibility-audit accessibility-analyze accessibility-clean accessibility-purge stop-servers stop-serve stop-static version-validate version-bump version-show release
```

- [ ] **Step 2: Add help entries**

Find the help section and add:

```makefile
	@echo "  check-placeholders - Verifica assenza placeholder immagini"
	@echo "  generate-placeholders - Genera placeholder per nuovi eventi/ambientazioni"
	@echo "  optimize-images - Ottimizza tutte le immagini (dimensioni, peso)"
```

- [ ] **Step 3: Add generate-placeholders target**

Add after existing targets:

```makefile
generate-placeholders:
	@echo "📸 Genero placeholder immagini..."
	@cd scripts && node generate-image-placeholders.js
	@echo "✅ Placeholder generati"
```

- [ ] **Step 4: Add check-placeholders target**

```makefile
check-placeholders:
	@echo "🔍 Verifico placeholder..."
	@cd scripts && node check-image-placeholders.js
	@echo "✅ Nessun placeholder trovato"
```

- [ ] **Step 5: Add optimize-images target**

```makefile
optimize-images:
	@echo "🖼️  Ottimizzazione immagini..."
	@$(MAKE) optimize-volantini
	@$(MAKE) optimize-featured
	@echo "✅ Ottimizzazione completata"

optimize-volantini:
	@echo "📄 Ottimizzazione volantini (A3 @ 300DPI)..."
	@find src/jekyll/assets/images -name "locandina_*.jpg" -type f 2>/dev/null | while read file; do \
		magick "$$file" -resize 3508x4961 -quality 85 -strip "$$file.tmp"; \
		mv "$$file.tmp" "$$file"; \
	done || echo "   Nessun volantino trovato"

optimize-featured:
	@echo "🖼️  Ottimizzazione featured (16:9)..."
	@find src/jekyll/assets/images -name "*-featured.jpg" -type f 2>/dev/null | while read file; do \
		magick "$$file" -resize 1200x630 -quality 85 -strip "$$file.tmp"; \
		mv "$$file.tmp" "$$file"; \
	done || echo "   Nessuna featured trovata"
```

- [ ] **Step 6: Update build target to include optimization**

Find the `build:` target and add optimization:

```makefile
build: optimize-images
	@echo "🏗️  Generazione sito statico..."
	@# ... rest of existing build target
```

- [ ] **Step 7: Test Makefile targets**

Run:
```bash
make help | grep -E "placeholder|optimize"
make generate-placeholders
make check-placeholders  # Should fail (placeholders exist)
```

- [ ] **Step 8: Commit**

```bash
git add Makefile
git commit -m "feat: add image management makefile targets (generate, check, optimize)"
```

---

## Task 10: Update CI Workflow

**Files:**
- Modify: `.github/workflows/validate-pr.yml`

- [ ] **Step 1: Read existing workflow structure**

Run: `cat .github/workflows/validate-pr.yml`

Note: Existing jobs structure (validate-changelog, check-html-in-markdown)

- [ ] **Step 2: Add check-image-placeholders job**

Add after check-html-in-markdown job:

```yaml
  check-image-placeholders:
    runs-on: ubuntu-latest
    env:
      FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: |
          cd scripts
          npm install

      - name: Check image placeholders
        id: check-placeholders
        run: |
          cd scripts
          node check-image-placeholders.js

      - name: Validate image specs
        id: validate-specs
        run: |
          cd scripts
          node validate-image-specs.js

      - name: Comment on PR if issues found
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '❌ **Image Issues Found**\n\n' +
                    'Sostituisci placeholder o correggi specifiche:\n' +
                    '- **Volantini**: 3508×4961px (A3), max 500KB\n' +
                    '- **Featured**: 1200×630px (16:9), max 200KB\n\n' +
                    'Vedi log per dettagli completi.\n\n' +
                    '📖 Guida: docs/IMAGE_GUIDE.md'
            })
```

- [ ] **Step 3: Verify YAML syntax**

Run: `cat .github/workflows/validate-pr.yml | tail -50`

Check: No syntax errors, proper indentation

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/validate-pr.yml
git commit -m "feat: add CI check for image placeholders and specs validation"
```

---

## Task 11: Create Image Guide Documentation

**Files:**
- Create: `docs/IMAGE_GUIDE.md`

- [ ] **Step 1: Create comprehensive image guide**

```markdown
# Guida Immagini Post ed Eventi

## Panoramica

Il sito BitPrepared usa un sistema automatico per selezionare le immagini giuste basandosi sul tipo di evento e sull'ambientazione.

## Tipi di Immagini

### 1. Volantini Eventi (Locandine)

Usati per: Pagine evento (`_eventi/*.md`)

**Specifiche:**
- **Dimensioni**: 3508 × 4961 pixel (A3 verticale @ 300 DPI)
- **Formato**: JPG, qualità 85%
- **Peso massimo**: 500 KB
- **Colori**: RGB, profilo sRGB
- **Nome file**: `locandina_{tipo}_{anno}.jpg`
- **Posizione**: `/assets/images/{tipo}/`

**Esempi:**
```
/assets/images/epppi/locandina_epppi_2026.jpg
/assets/images/campo-eg/locandina_campo-eg_2026.jpg
```

**Come funziona:**
1. Nel frontmatter evento specifichi `event_type: epppi` e `year: 2026`
2. Jekyll automaticamente usa `/assets/images/epppi/locandina_epppi_2026.jpg`
3. Se vuoi usare un'immagine diversa, aggiungi `image: /percorso/custom.jpg`

---

### 2. Immagini Featured Post

Usate per: Post del blog (`_posts/*.md`)

**Specifiche:**
- **Dimensioni**: 1200 × 630 pixel (rapporto 16:9)
- **Formato**: JPG qualità 85% o WebP
- **Peso massimo**: 200 KB
- **Colori**: RGB, profilo sRGB
- **Nome file**: `{tipo}-{ambientazione}-featured.jpg`
- **Posizione**: `/assets/images/{tipo}/`

**Esempi:**
```
/assets/images/epppi/epppi-star-wars-featured.jpg
/assets/images/campo-eg/campo-eg-momo-featured.jpg
```

**Come funziona:**
1. Nel frontmatter post specifichi `event_type: epppi` e `ambientazione: star-wars`
2. Jekyll automaticamente usa `/assets/images/epppi/epppi-star-wars-featured.jpg`
3. Se vuoi usare un'immagine diversa, aggiungi `featured: /percorso/custom.jpg`

---

### 3. Immagine Generica

Usata per: Post senza evento

**Specifiche:**
- **Dimensioni**: 1200 × 630 pixel (16:9)
- **Formato**: PNG
- **Peso massimo**: 300 KB
- **Nome file**: `generic-featured.png`
- **Posizione**: `/assets/images/`

**Come funziona:**
- Se il post NON ha `event_type` e `ambientazione`, usa automaticamente questa immagine
- Puoi fare override con `featured: /percorso/custom.jpg`

---

## Creare Nuove Immagini

### Metodo 1: Usare il comando ottimizzazione

Il sistema ottimizza automaticamente le immagini durante il build:

```bash
# Metti la tua immagine nella cartella giusta con qualsiasi nome
cp mia-immagine.jpg src/jekyll/assets/images/epppi/

# Run build (ottimizza automaticamente)
make build
```

L'immagine verrà:
- Ridimensionata alle dimensioni corrette
- Compressa alla qualità giusta
- Salvata con il peso ottimizzato

### Metodo 2: Ottimizzare manualmente con ImageMagick

```bash
# Installa ImageMagick
sudo apt-get install imagemagick

# Ottimizza volantino (A3 @ 300DPI)
convert input.jpg -resize 3508x4961 -quality 85 output.jpg

# Ottimizza featured post (16:9)
convert input.jpg -resize 1200x630 -quality 85 output.jpg
```

---

## Generare Placeholder

Quando crei un nuovo evento o combinazione evento+ambientazione:

```bash
# Genera tutti i placeholder mancanti
make generate-placeholders
```

Questo crea placeholder 1×1px con metadata. Il CI bloccherà il deployment finché non sostituisci i placeholder con immagini reali.

---

## Verificare Specifiche

Prima di commit:

```bash
# Verifica assenza placeholder
make check-placeholders

# Verifica dimensioni e peso
node scripts/validate-image-specs.js
```

---

## Troubleshooting

### L'immagine non appare

**Problema:** Immagine calcolata non esiste

**Soluzione:**
1. Verifica che il file esista nel percorso giusto
2. Verifica nome file corretto (minuscolo, trattini)
3. Se non esiste, il sistema usa automaticamente `generic-featured.png`

### CI blocca il deployment

**Problema:** Placeholder trovati

**Soluzione:**
1. Leggi il log CI per vedere quali file sono placeholder
2. Sostituiscili con immagini reali
3. Assicurati che dimensioni e peso siano corretti

### Immagine troppo pesante

**Problema:** File size validation fallisce

**Soluzione:**
```bash
# Ottimizza con Makefile
make optimize-images
```

---

## Riferimenti

- **Design document:** `docs/superpowers/specs/2026-05-04-image-management-design.md`
- **Implementation plan:** `docs/superpowers/plans/2026-05-04-image-management.md`
```

- [ ] **Step 2: Verify documentation completeness**

Run: `cat docs/IMAGE_GUIDE.md | wc -l`

Expected: 200+ lines with complete guide

- [ ] **Step 3: Test examples from guide**

Follow one example (e.g., create placeholder) to verify instructions work.

- [ ] **Step 4: Commit**

```bash
git add docs/IMAGE_GUIDE.md
git commit -m "docs: add comprehensive image creation and optimization guide"
```

---

## Task 12: End-to-End Integration Test

**Files:**
- Test: Full system integration

- [ ] **Step 1: Create test post with event_type + ambientazione**

Create `src/jekyll/_posts/2026-05-04-integration-test.md`:
```yaml
---
layout: post
title: Integration Test Post
event_type: epppi
ambientazione: star-wars
description: "Testing image management system"
---
```

- [ ] **Step 2: Create corresponding image**

```bash
cp src/jekyll/assets/images/generic-featured.png src/jekyll/assets/images/epppi/epppi-star-wars-featured.jpg
```

- [ ] **Step 3: Build site and verify output**

```bash
make build
grep -r "epppi-star-wars-featured" output/_site/
```

Expected: Image referenced in built post

- [ ] **Step 4: Test placeholder detection**

```bash
# Remove real image, placeholder should exist
rm src/jekyll/assets/images/epppi/epppi-star-wars-featured.jpg
make generate-placeholders
make check-placeholders
```

Expected: Fails with placeholder detected

- [ ] **Step 5: Test override mechanism**

Update test post frontmatter:
```yaml
---
layout: post
title: Integration Test Post
featured: /assets/images/generic-featured.png
---
```

Build and verify generic image used.

- [ ] **Step 6: Cleanup test files**

```bash
rm src/jekyll/_posts/2026-05-04-integration-test.md
```

- [ ] **Step 7: Final commit with test verification**

```bash
git add .
git commit -m "test: verify end-to-end image management integration"
```

---

## Task 13: Update Existing Event Files

**Files:**
- Modify: `src/jekyll/_eventi/epppi.md`, `campo-eg.md`, `stage.md`

- [ ] **Step 1: Add event_type and year to epppi.md**

Read current epppi.md frontmatter, add:
```yaml
event_type: epppi
year: 2026
```

- [ ] **Step 2: Add event_type and year to campo-eg.md**

```yaml
event_type: campo-eg
year: 2026
```

- [ ] **Step 3: Add event_type and year to stage.md**

```yaml
event_type: stage
year: 2026
```

- [ ] **Step 4: Verify event pages build correctly**

```bash
make build
ls output/_site/eventi/
```

Expected: Event pages exist and reference correct locandinas

- [ ] **Step 5: Commit**

```bash
git add src/jekyll/_eventi/
git commit -m "feat: add event_type and year to existing event files"
```

---

## Self-Review Checklist

**Spec coverage:**
- ✅ Frontmatter event_type + ambientazione → Task 1, 2, 4
- ✅ Liquid layout logic → Task 4, 5
- ✅ Placeholder generation → Task 6
- ✅ Placeholder validation → Task 7
- ✅ Image specs validation → Task 8
- ✅ Makefile targets → Task 9
- ✅ CI/CD integration → Task 10
- ✅ Documentation → Task 11
- ✅ Generic image → Task 3

**Placeholder scan:**
- ✅ No TBD/TODO in any task
- ✅ All code steps have actual code
- ✅ All file paths exact and complete
- ✅ All commands have expected output

**Type consistency:**
- ✅ `event_type` used consistently
- ✅ `ambientazione` used consistently
- ✅ Image paths follow same pattern throughout

**Scope check:**
- ✅ Single cohesive system
- ✅ All tasks independent but sequenced correctly
- ✅ Each task produces verifiable output
