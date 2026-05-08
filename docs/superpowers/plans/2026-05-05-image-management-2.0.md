# Image Management 2.0 - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Riorganizza sistema gestione immagini con struttura matrici organizzata, file manifesto per regole, e sorgente unica SVG per icone multiple

**Architecture:** Matrici (source/) → Manifesti (regole) → Assets (production/) → Sito pubblicato. Sistema basato su directory esplicite (production/, source-icons/, supporto/) + file .locked/.rules per controllo fine.

**Tech Stack:** Node.js (sharp), Makefile, Shell script, ImageMagick (CLI), Jekyll

---

## File Structure

### New Files
- `src/matrici/images/.locked` - File con lista immagini da non modificare
- `src/matrici/images/.rules` - Regole conversione per categoria
- `src/matrici/images/source-icons/site-icon.svg` - Sorgente vettoriale icone
- `scripts/optimize-with-manifest.js` - Ottimizza immagini rispettando manifesti
- `scripts/generate-icons-from-svg.js` - Genera icone da SVG
- `src/matrici/images/.gitignore` - Esclude supporto/ da git

### Modified Files
- `Makefile` - Nuovi target: init-matrici, generate-icons, optimize-images
- `.gitignore` - Aggiungi src/jekyll/assets/images/ (generated cache)
- `scripts/optimize-images.js` - Aggiorna per nuove regole
- `scripts/generate-image-placeholders.js` - Aggiorna per nuova struttura
- `src/jekyll/_layouts/default.html` - Aggiorna riferimenti icone
- `docs/IMAGE_GUIDE.md` - Aggiorna con nuova struttura
- `README.md` - Aggiorna sezione gestione immagini

---

## Task 1: Initialize New Matrici Structure

**Files:**
- Create: `src/matrici/images/.gitignore`

- [ ] **Step 1: Create .gitignore for supporto/**

```bash
cat > src/matrici/images/.gitignore << 'EOF'
# Esclude supporto/ da git (archivio strumenti, mockup, ecc.)
supporto/
EOF
```

- [ ] **Step 2: Verify .gitignore created**

Run: `cat src/matrici/images/.gitignore`
Expected: `supporto/` visible

- [ ] **Step 3: Commit**

```bash
git add src/matrici/images/.gitignore
git commit -m "feat: add gitignore for matrici supporto/ directory"
```

---

## Task 2: Create Manifest Files

**Files:**
- Create: `src/matrici/images/.locked`
- Create: `src/matrici/images/.rules`

- [ ] **Step 1: Create .locked manifest**

```bash
cat > src/matrici/images/.locked << 'EOF'
# Immagini "congelate" - non ottimizzare né convertire
generic-featured.png
agesci_logo.png
placeholder-blog.png
placeholder-news.png
EOF
```

- [ ] **Step 2: Verify .locked created**

Run: `cat src/matrici/images/.locked`
Expected: 4 filenames listed

- [ ] **Step 3: Create .rules file**

```bash
cat > src/matrici/images/.rules << 'EOF'
# Regole conversione per categoria
# Format: [category]
#   convert_to: jpg|png|webp
#   dimensions: WIDTHxHEIGHT (opzionale)
#   quality: 1-100 (opzionale, solo per jpg/webp)
#   copy_only: true|false (se true, non convertire)

[production/eventi]
convert_to: jpg
dimensions: 3508x4961
quality: 85

[production/software]
convert_to: png
copy_only: true

[production/loghi-branche]
convert_to: png
copy_only: true

[production/root]
convert_to: jpg
dimensions: 1200x630
quality: 85
EOF
```

- [ ] **Step 4: Verify .rules created**

Run: `cat src/matrici/images/.rules`
Expected: 4 category sections defined

- [ ] **Step 5: Commit**

```bash
git add src/matrici/images/.locked src/matrici/images/.rules
git commit -m "feat: add image management manifest files (.locked and .rules)"
```

---

## Task 3: Update .gitignore for Assets

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add assets/images to gitignore**

```bash
echo "" >> .gitignore
echo "# Generated images from matrici (run make optimize-images to regenerate)" >> .gitignore
echo "src/jekyll/assets/images/" >> .gitignore
```

- [ ] **Step 2: Verify .gitignore updated**

Run: `tail -5 .gitignore`
Expected: Last line shows `src/jekyll/assets/images/`

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: add src/jekyll/assets/images/ to gitignore (generated cache)"
```

---

## Task 4: Create optimize-with-manifest.js Script

**Files:**
- Create: `scripts/optimize-with-manifest.js`

- [ ] **Step 1: Create script skeleton**

```javascript
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
  const content = fs.readFileSync(rulesPath, 'utf8');
  const sections = content.split(/\[([^\]]+)\]/).filter(s => s.trim());
  
  sections.forEach(section => {
    const lines = section.trim().split('\n');
    const category = lines[0].trim();
    
    rules[category] = {};
    lines.slice(1).forEach(line => {
      const [key, value] = line.split(':').map(s => s.trim());
      if (key && value) {
        rules[category][key] = value;
      }
    });
  });
  
  return rules;
}

// Get category from file path
function getCategory(relativePath) {
  if (relativePath.startsWith('eventi/')) return 'production/eventi';
  if (relativePath.startsWith('software/')) return 'production/software';
  if (relativePath.startsWith('loghi-branche/')) return 'production/loghi-branche';
  if (relativePath.startsWith('root/')) return 'production/root';
  return null;
}

// Main optimization function
async function optimizeImages() {
  const { lockedFiles } = loadManifests();
  const rules = parseRules(`${MATRICE_DIR}/.rules`);
  const productionDir = path.join(MATRICE_DIR, 'production');
  
  // Find all PNG in production/
  const files = findFiles(productionDir, '.png');
  
  for (const file of files) {
    const relativePath = path.relative(productionDir, file);
    const targetPath = path.join(ASSETS_DIR, relativePath);
    const category = getCategory(relativePath);
    
    // Skip locked files
    if (lockedFiles.includes(relativePath)) {
      console.log(`🔒 Locked: ${relativePath}`);
      await copyFile(file, targetPath);
      continue;
    }
    
    // Apply rules
    if (category && rules[category]) {
      const rule = rules[category];
      
      if (rule.copy_only === 'true') {
        console.log(`📋 Copy only: ${relativePath}`);
        await copyFile(file, targetPath);
      } else if (rule.convert_to) {
        console.log(`📸 Convert: ${relativePath} → ${rule.convert_to}`);
        await convertImage(file, targetPath, rule);
      }
    }
  }
  
  console.log('✅ Ottimizzazione completata');
}

// Helper functions
function findFiles(dir, ext) {
  // Implementation here
}

async function copyFile(src, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(src, dest);
}

async function convertImage(src, dest, rule) {
  // Implementation here
}

// Run
optimizeImages().catch(err => {
  console.error('❌ Errore:', err);
  process.exit(1);
});
```

- [ ] **Step 2: Test script syntax**

Run: `node -c scripts/optimize-with-manifest.js`
Expected: No syntax errors

- [ ] **Step 3: Commit**

```bash
git add scripts/optimize-with-manifest.js
git commit -m "feat: add optimize-with-manifest.js script"
```

---

## Task 5: Create generate-icons-from-svg.js Script

**Files:**
- Create: `scripts/generate-icons-from-svg.js`

- [ ] **Step 1: Create icon generation script**

```javascript
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
```

- [ ] **Step 2: Test script syntax**

Run: `node -c scripts/generate-icons-from-svg.js`
Expected: No syntax errors

- [ ] **Step 3: Commit**

```bash
git add scripts/generate-icons-from-svg.js
git commit -m "feat: add generate-icons-from-svg.js script"
```

---

## Task 6: Update Makefile

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Add new targets to Makefile**

Add after existing targets:

```makefile
.PHONY: init-matrici generate-icons optimize-images

init-matrici:
	@echo "📁 Inizializzazione struttura matrici..."
	@mkdir -p src/matrici/images/{production/{eventi,software,loghi-branche,root},source-icons,supporto}
	@echo "✅ Struttura creata"

generate-icons:
	@echo "🎨 Generazione icone da SVG..."
	@node scripts/generate-icons-from-svg.js
	@echo "✅ Icone generate"

optimize-images: generate-icons
	@echo "🖼️  Ottimizzazione immagini con manifesti..."
	@node scripts/optimize-with-manifest.js
	@echo "✅ Ottimizzazione completata"
```

- [ ] **Step 2: Test new targets**

Run: `make help | grep -E "init-matrici|generate-icons"`
Expected: Targets listed in help output

- [ ] **Step 3: Test init-matrici creates directories**

Run: `make init-matrici && ls -la src/matrici/images/`
Expected: All 7 directories created

- [ ] **Step 4: Commit**

```bash
git add Makefile
git commit -m "feat: add init-matrici, generate-icons, optimize-images targets"
```

---

## Task 7: Update optimize-images.js for New Structure

**Files:**
- Modify: `scripts/optimize-images.js`

- [ ] **Step 1: Remove old volantini optimization**

Remove the `optimize-volantini` target logic (no longer needed, handled by optimize-with-manifest.js)

- [ ] **Step 2: Update optimize-images to call new script**

Replace content to call new script:

```javascript
console.log('🖼️  Ottimizzazione immagini con manifesti...');
const { execSync } = require('child_process');

try {
  execSync('node scripts/optimize-with-manifest.js', { stdio: 'inherit' });
  console.log('✅ Ottimizzazione completata');
} catch (error) {
  console.error('❌ Errore ottimizzazione:', error);
  process.exit(1);
}
```

- [ ] **Step 3: Test updated script**

Run: `node scripts/optimize-images.js`
Expected: Completes without errors (may have missing files, that's OK)

- [ ] **Step 4: Commit**

```bash
git add scripts/optimize-images.js
git commit -m "refactor: update optimize-images.js to use new manifest system"
```

---

## Task 8: Update generate-image-placeholders.js

**Files:**
- Modify: `scripts/generate-image-placeholders.js`

- [ ] **Step 1: Update file paths for new structure**

Update paths from:
- Old: `src/jekyll/assets/images/{slug}/`
- New: `src/matrici/images/production/eventi/{slug}/`

In the `generateEventPlaceholders()` and `generatePostPlaceholders()` functions:

```javascript
// OLD
const filepath = path.join(__dirname, '../', MATRICE_DIR, event.slug, filename);

// NEW  
const filepath = path.join(__dirname, '../', MATRICE_DIR, 'production/eventi', event.slug, filename);
```

- [ ] **Step 2: Test updated placeholder generation**

Run: `make generate-placeholders`
Expected: Placeholders created in production/eventi/

- [ ] **Step 3: Commit**

```bash
git add scripts/generate-image-placeholders.js
git commit -m "refactor: update placeholder generation for new matrici structure"
```

---

## Task 9: Create SVG Source Icon

**Files:**
- Create: `src/matrici/images/source-icons/site-icon.svg`

- [ ] **Step 1: Create SVG icon (512x512)**

Create minimal SVG (temporary version):

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="512" height="512" fill="#003366"/>
  <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="white" font-size="48" font-family="Arial">BP</text>
</svg>
```

- [ ] **Step 2: Verify SVG created**

Run: `ls -lh src/matrici/images/source-icons/site-icon.svg`
Expected: File exists, ~1KB

- [ ] **Step 3: Test icon generation**

Run: `make generate-icons`
Expected: All apple-touch-icon files generated

- [ ] **Step 4: Commit**

```bash
git add src/matrici/images/source-icons/site-icon.svg
git commit -m "feat: add SVG source icon for site icon generation"
```

---

## Task 10: Update Jekyll Layout for Icons

**Files:**
- Modify: `src/jekyll/_layouts/default.html`

- [ ] **Step 1: Add manifest.json link to head**

Add in `<head>` section, after existing links:

```html
<link rel="manifest" href="/assets/images/manifest.json">
```

- [ ] **Step 2: Verify HTML structure**

Run: `grep -A5 "manifest.json" src/jekyll/_layouts/default.html`
Expected: manifest link visible

- [ ] **Step 3: Commit**

```bash
git add src/jekyll/_layouts/default.html
git commit -m "feat: add PWA manifest link to default layout"
```

---

## Task 11: Update .gitignore for Old Assets

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Remove old assets/images entries if present**

Check if there are old entries:
```bash
grep -n "assets/images" .gitignore || echo "No existing entries found"
```

- [ ] **Step 2: Ensure new gitignore entry is correct**

Verify the entry added in Task 3 is present

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: ensure assets/images gitignore is correct"
```

---

## Task 12: Documentation Updates

**Files:**
- Modify: `docs/IMAGE_GUIDE.md`
- Modify: `README.md`

- [ ] **Step 1: Update IMAGE_GUIDE.md with new structure**

Add new sections after "Percorsi dei File":

```markdown
## Struttura Matrici Organizzata

Il sistema matrici è ora organizzato in 3 sottodirectory:

### production/
Immagini usate dal sito, ottimizzate per produzione
- `eventi/` - Locandine e featured per eventi
- `software/` - Loghi software
- `loghi-branche/` - Loghi EG/RS/Capi
- `root/` - Immagini root (generic-featured, agesci-logo, placeholders)

### source-icons/
Sorgenti uniche che generano multiple varianti
- `site-icon.svg` - Genera favicon.ico, apple-touch-icon*.png, manifest.json

### supporto/
Archivio, non copiato in assets
- `mockup/` - Mockup design
- `strumenti/` - File di lavoro
- `risorse/` - Risorse varie

## File Manifesto

### .locked
File che non devono essere modificati:
- generic-featured.png
- agesci_logo.png
- placeholder-blog.png
- placeholder-news.png

### .rules
Regole conversioni per categoria. Vedi design document per dettagli completi.
```

- [ ] **Step 2: Update README.md with new commands**

Add/update "Gestione Immagini 2.0" section:

```markdown
## Gestione Immagini 2.0

### Comandi nuovi
make init-matrici       # Inizializza struttura matrici
make generate-icons       # Genera icone da SVG sorgente
make optimize-images      # Ottimizza immagini con manifesti

### Struttura Matrici
- `src/matrici/images/production/` → Immagini per sito
- `src/matrici/images/source-icons/` → Sorgenti icone
- `src/matrici/images/supporto/` → Archivio (non copiato)
```

- [ ] **Step 3: Verify documentation changes**

Run: `grep -A5 "Struttura Matrici Organizzata" docs/IMAGE_GUIDE.md`
Expected: New section visible

- [ ] **Step 4: Commit**

```bash
git add docs/IMAGE_GUIDE.md README.md
git commit -m "docs: update documentation for image management 2.0"
```

---

## Task 13: Migration - Reorganize Existing Files

**Files:**
- Modify: Multiple files in `src/matrici/images/`

- [ ] **Step 1: Create new directory structure**

Run: `make init-matrici`

- [ ] **Step 2: Move event images to production/**

```bash
mv src/matrici/images/eppi/*.png src/matrici/images/production/eventi/epppi/
mv src/matrici/images/campo-eg/*.png src/matrici/images/production/eventi/campo-eg/
mv src/matrici/images/stage/*.png src/matrici/images/production/eventi/stage/
```

- [ ] **Step 3: Move software logos**

```bash
mv src/matrici/images/pages/software src/matrici/images/production/software/
```

- [ ] **Step: Move branch logos**

```bash
mv src/matrici/images/loghi_branche/* src/matrici/images/production/loghi-branche/
```

- [ ] **Step 5: Move root images**

```bash
mv src/matrici/images/generic-featured.png src/matrici/images/production/root/
mv src/matrici/images/agesci_logo.png src/matrici/images/production/root/
mv src/matrici/images/placeholder-*.png src/matrici/images/production/root/
```

- [ ] **Step 6: Move unused images to supporto/**

```bash
mv src/matrici/images/campo-eg/campo-eg-matrix-featured.png src/matrici/images/supporto/
mv src/matrici/images/epppi/epppi-matrix-featured.png src/matrici/images/supporto/
mv src/matrici/images/stage/stage-matrix-featured.png src/matrici/images/supporto/
```

- [ ] **Step 7: Remove old JPG files**

```bash
find src/matrici/images -name "*.jpg" -delete
```

- [ ] **Step 8: Verify structure**

Run: `tree src/matrici/images/ -L 2`
Expected: Shows production/, source-icons/, supporto/ structure

- [ ] **Step 9: Commit**

```bash
git add src/matrici/images/
git commit -m "refactor: reorganize matrici into production/source-icons/supporto structure"
```

---

## Task 14: Test Complete Workflow

**Files:**
- None (testing only)

- [ ] **Step 1: Test optimize-images from scratch**

```bash
rm -rf src/jekyll/assets/images/
make optimize-images
```

- [ ] **Step 2: Verify correct files copied**

Run: `find src/jekyll/assets/images/ -type f | wc -l`
Expected: ~22 files (14 software + 3 branch + 5 root)

- [ ] **Step 3: Test locked files not modified**

Run: 
```bash
# Check generic-featured.png exists and is unchanged
ls -lh src/jekyll/assets/images/generic-featured.png
```

Expected: File exists and matches source

- [ ] **Step 4: Test generate-icons creates all variants**

Run: `rm -f src/jekyll/assets/images/apple-touch-icon*.png && make generate-icons`

Expected: All 4 apple-touch-icon files created

- [ ] **Step 5: Test placeholder generation with new structure**

Run: `make generate-placeholders`

Expected: Placeholders created in production/ directories

---

## Task 15: Final Verification and Documentation

**Files:**
- None (verification only)

- [ ] **Step 1: Verify all spec requirements met**

Check each success criterion from design spec:
- [ ] Struttura matrici organizzata ✅
- [ ] File .locked protezione immagini ✅
- [ ] File .rules regole conversioni ✅
- [ ] SVG genera icone multiple ✅
- [ ] Script rispetta manifesti ✅
- [ ] supporto/ escluso da copia ✅
- [ ] Placeholder generati solo se mancanti ✅

- [ ] **Step 2: Create migration guide document**

Create `docs/migration-image-management-2.0.md` with step-by-step migration instructions

- [ ] **Step 3: Commit**

```bash
git add docs/migration-image-management-2.0.md
git commit -m "docs: add migration guide for image management 2.0"
```

---

## Task 16: Update CI/CD for New System

**Files:**
- Modify: `.github/workflows/validate-pr.yml`

- [ ] **Step 1: Add job to check matrici structure**

Add new job after existing jobs:

```yaml
check-matrici-sync:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Check matrici → assets sync
      run: |
        node scripts/check-matrici-sync.js
    
    - name: Comment on PR if out of sync
      if: failure()
      uses: actions/github-script@v6
      with:
        script: |
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: '❌ **Matrici/Images Out of Sync**\n\n' +
                  'Le immagini in src/matrici/images/ non sono sincronizzate con src/jekyll/assets/images/\n\n' +
                  '**Soluzione:**\n' +
                  '```bash\n' +
                  'make optimize-images\n' +
                  'git add src/jekyll/assets/images/\n' +
                  'git commit -m "chore: sync assets from matrici"\n' +
                  '```\n\n' +
                  'Vedi docs/IMAGE_GUIDE.md per dettagli'
          })
```

- [ ] **Step 2: Create check-matrici-sync.js script**

Create simple script to verify sync

- [ ] **Step 3: Test CI workflow**

Push branch and verify workflow runs

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/validate-pr.yml scripts/check-matrici-sync.js
git commit -m "ci: add matrici sync check to PR validation"
```

---

## Task 17: Clean Up Old Image Files

**Files:**
- Modify: Remove old image files

- [ ] **Step 1: Remove old apple-touch-icon files**

```bash
# These are now generated from SVG
rm -f src/jekyll/assets/images/apple-touch-icon-*.png
```

- [ ] **Step 2: Remove any old optimize-* scripts**

Check for and remove obsolete scripts if any

- [ ] **Step 3: Verify cleanup**

Run: `find src/jekyll/assets/images/ -name "apple-touch-icon*" | wc -l`
Expected: 0 (all removed, will be regenerated)

- [ ] **Step 4: Commit**

```bash
git add src/jekyll/assets/images/
git commit -m "chore: remove old apple-touch-icon files (now generated from SVG)"
```

---

## Success Criteria Verification

Run this final checklist to verify all requirements met:

- [ ] **Structure:** `src/matrici/images/` has production/, source-icons/, supporto/
- [ ] **Manifests:** `.locked` and `.rules` files exist and are correct
- [ ] **Icons:** SVG generates all apple-touch-icon variants + manifest.json
- [ ] **Optimization:** `optimize-with-manifest.js` respects locked files and rules
- [ ] **Placeholders:** Generated in correct production/ directories
- [ ] **Git:** assets/images/ in .gitignore
- [ ] **Documentation:** IMAGE_GUIDE.md and README.md updated
- [ ] **CI:** PR validation checks matrici sync

---

**Total Estimated Time:** 2-3 hours for implementation + testing

**Migration Risk:** Medium - involves moving many files, but backwards compatible with existing workflow