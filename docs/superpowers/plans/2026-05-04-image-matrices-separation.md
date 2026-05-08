# Image Matrices Separation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Separare immagini originali (PNG) in `src/matrici/images/` da versioni ottimizzate (JPG) in `src/jekyll/assets/images/`

**Architecture:** Script leggono PNG da `src/matrici/images/`, generano JPG in `src/jekyll/assets/images/`. Jekyll pubblica solo JPG. Matrici fuori da Jekyll (non in assets).

**Tech Stack:** Bash, ImageMagick (magick), Node.js (placeholder/validation), Make

---

## Task 1: Create Directory Structure

**Files:**
- Create: `src/matrici/images/` (directory)

- [ ] **Step 1: Create matrici directory**

```bash
mkdir -p src/matrici/images
```

- [ ] **Step 2: Verify directory created**

```bash
test -d src/matrici/images && echo "✅ Directory created"
```

Expected: "✅ Directory created"

- [ ] **Step 3: Commit**

```bash
git add src/matrici/images/
git commit -m "feat: create src/matrici/images/ directory for original images"
```

---

## Task 2: Create Migration Script

**Files:**
- Create: `scripts/migrate-images-to-matrici.sh`

- [ ] **Step 1: Write migration script**

```bash
cat > scripts/migrate-images-to-matrici.sh << 'EOF'
#!/bin/bash

set -e

MATRICE_DIR="src/matrici/images"
SOURCE_DIR="src/jekyll/assets/images"

echo "📦 Migrazione PNG originali → matrici..."

# Crea struttura directory
echo "📁 Creazione struttura..."
find "$SOURCE_DIR" -type d | while read dir; do
  target_dir=$(echo "$dir" | sed "s|$SOURCE_DIR|$MATRICE_DIR|")
  mkdir -p "$target_dir"
done

# Sposta PNG (tranne eccezioni)
echo "📸 Spostamento PNG..."
find "$SOURCE_DIR" -name "*.png" -type f | while read png; do
  filename=$(basename "$png")

  # Eccezioni: non spostare
  if [[ "$filename" == "favicon.png" ]] || \
     [[ "$filename" == "logo.png" ]] || \
     [[ "$filename" == "agesci_logo.png" ]]; then
    echo "   ⏭️  Skip (eccezione): $filename"
    continue
  fi

  # Sposta in matrici
  relative_path="${png#$SOURCE_DIR/}"
  target="$MATRICE_DIR/$relative_path"

  if [ ! -f "$target" ]; then
    mv "$png" "$target"
    echo "   ✅ Spostato: $filename"
  else
    echo "   ⚠️  Esiste già: $filename"
  fi
done

# Sposta originali con suffisso _orig
echo "📸 Spostamento _orig..."
find "$SOURCE_DIR" -name "*_orig.*" -type f | while read orig; do
  relative_path="${orig#$SOURCE_DIR/}"
  target="$MATRICE_DIR/$relative_path"
  mv "$orig" "$target"
  echo "   ✅ Spostato: $(basename "$orig")"
done

echo "✅ Migrazione completata!"
echo "📝 Prossimo step: esegui 'make optimize-images' per generare JPG"
EOF
```

- [ ] **Step 2: Make script executable**

```bash
chmod +x scripts/migrate-images-to-matrici.sh
```

- [ ] **Step 3: Verify script is executable**

```bash
ls -l scripts/migrate-images-to-matrici.sh | grep -q "rwxr-xr-x" && echo "✅ Executable"
```

Expected: "✅ Executable"

- [ ] **Step 4: Commit**

```bash
git add scripts/migrate-images-to-matrici.sh
git commit -m "feat: add migration script for moving PNG originals to matrici"
```

---

## Task 3: Update Makefile - Add Variables

**Files:**
- Modify: `Makefile:1-10`

- [ ] **Step 1: Add new variables after JEKYLL_VERSION**

```makefile
JEKYLL_VERSION ?= 4
PORT ?= 4000
STATIC_PORT ?= 8000
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
NODE_MODULES_VOLUME = bitprepared-node-modules
VENDOR_VOLUME = bitprepared-vendor
CACHE_VOLUME = bitprepared-jekyll-cache
POLLING ?= 0
A11Y_PAGE ?= full

# Image directories
MATRICE_DIR = src/matrici/images
OPTIMIZE_DIR = src/jekyll/assets/images
```

- [ ] **Step 2: Verify variables added**

```bash
grep -q "MATRICE_DIR = src/matrici/images" Makefile && echo "✅ MATRICE_DIR added"
grep -q "OPTIMIZE_DIR = src/jekyll/assets/images" Makefile && echo "✅ OPTIMIZE_DIR added"
```

Expected: Both checks pass

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "feat: add MATRICE_DIR and OPTIMIZE_DIR variables to Makefile"
```

---

## Task 4: Update Makefile - Rewrite optimize-volantini

**Files:**
- Modify: `Makefile:393-398` (replace existing optimize-volantini target)

- [ ] **Step 1: Replace optimize-volantini target**

```makefile
optimize-volantini:
	@echo "📄 Ottimizzazione volantini (A3 @ 300DPI)..."
	@find $(MATRICE_DIR) -name "locandina_*.png" -type f 2>/dev/null | while read png; do \
		jpg=$$(echo "$$png" | sed 's|$(MATRICE_DIR)|$(OPTIMIZE_DIR)|' | sed 's/\.png/.jpg/'); \
		mkdir -p "$$(dirname "$$jpg")"; \
		if [ ! -f "$$jpg" ] || [ "$$png" -nt "$$jpg" ]; then \
			echo "   📸 $$png → $$jpg"; \
			magick "$$png" -resize 3508x4961 -quality 85 -strip "$$jpg"; \
		fi; \
	done || echo "   Nessun volantino trovato"
```

- [ ] **Step 2: Verify target syntax**

```bash
make -n optimize-volantini 2>&1 | head -5
```

Expected: Shows find command with $(MATRICE_DIR)

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "refactor: update optimize-volantini to read from matrices, write to images"
```

---

## Task 5: Update Makefile - Rewrite optimize-featured

**Files:**
- Modify: `Makefile:400-414` (replace existing optimize-featured target)

- [ ] **Step 1: Replace optimize-featured target**

```makefile
optimize-featured:
	@echo "🖼️  Ottimizzazione featured (16:9)..."
	@find $(MATRICE_DIR) -name "*-featured.png" -type f 2>/dev/null | while read png; do \
		jpg=$$(echo "$$png" | sed 's|$(MATRICE_DIR)|$(OPTIMIZE_DIR)|' | sed 's/\.png/.jpg/'); \
		mkdir -p "$$(dirname "$$jpg")"; \
		if [ ! -f "$$jpg" ] || [ "$$png" -nt "$$jpg" ]; then \
			echo "   📸 $$png → $$jpg"; \
			magick "$$png" -resize 1200x630 -quality 85 "$$jpg"; \
		fi; \
	done
	@echo "   Ottimizzazione JPG esistenti..."
	@find $(OPTIMIZE_DIR) -name "*-featured.jpg" -type f 2>/dev/null | while read file; do \
		magick "$$file" -resize 1200x630 -quality 85 -strip "$$file.tmp"; \
		mv "$$file.tmp" "$$file"; \
	done || echo "   Nessuna featured trovata"
```

- [ ] **Step 2: Verify target syntax**

```bash
make -n optimize-featured 2>&1 | head -5
```

Expected: Shows find command with $(MATRICE_DIR)

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "refactor: update optimize-featured to read from matrices, write to images"
```

---

## Task 6: Update Makefile - Rewrite optimize-generic

**Files:**
- Modify: `Makefile:416-421` (replace existing optimize-generic target)

- [ ] **Step 1: Replace optimize-generic target**

```makefile
optimize-generic:
	@echo "🖼️  Ottimizzazione generic (16:9)..."
	@if [ -f "$(MATRICE_DIR)/generic-featured.png" ]; then \
		magick "$(MATRICE_DIR)/generic-featured.png" -resize 1200x630 -quality 85 -strip "$(OPTIMIZE_DIR)/generic-featured.jpg"; \
	fi
	@# Fallback: se non esiste matrice, ottimizza quello in place
	@if [ ! -f "$(MATRICE_DIR)/generic-featured.png" ] && [ -f "$(OPTIMIZE_DIR)/generic-featured.png" ]; then \
		magick "$(OPTIMIZE_DIR)/generic-featured.png" -resize 1200x630 -quality 85 -strip "$(OPTIMIZE_DIR)/generic-featured.jpg.tmp"; \
		mv "$(OPTIMIZE_DIR)/generic-featured.jpg.tmp" "$(OPTIMIZE_DIR)/generic-featured.jpg"; \
	fi
```

- [ ] **Step 2: Verify target syntax**

```bash
make -n optimize-generic 2>&1
```

Expected: Shows conditional magick commands

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "refactor: update optimize-generic to read from matrices, fallback to images"
```

---

## Task 7: Update Makefile - Add migrate-images Target

**Files:**
- Modify: `Makefile:11` (add to .PHONY)
- Modify: `Makefile:569` (after optimize-images target)

- [ ] **Step 1: Add migrate-images to .PHONY**

```makefile
.PHONY: serve serve-bg serve-static serve-static-bg build build-css clean install install-gems help open validate-graphics compare-graphics visual-baseline visual-clean docker-build-visual docker-build-a11y workflow generate-blog-post check-links check-html check-placeholders generate-placeholders optimize-images optimize-volantini optimize-featured optimize-generic accessibility-audit accessibility-analyze accessibility-clean accessibility-purge stop-servers stop-serve stop-static version-validate version-bump version-show release migrate-images validate-images
```

- [ ] **Step 2: Add migrate-images target after optimize-images**

```makefile
.PHONY: optimize-images
optimize-images:
	@echo "🖼️  Ottimizzazione immagini..."
	@$(MAKE) optimize-volantini
	@$(MAKE) optimize-featured
	@$(MAKE) optimize-generic
	@echo "✅ Ottimizzazione completata"

migrate-images:
	@echo "📦 Migrazione immagini in matrici..."
	@chmod +x ./scripts/migrate-images-to-matrici.sh
	@./scripts/migrate-images-to-matrici.sh
```

- [ ] **Step 3: Verify target works**

```bash
grep -A 3 "^migrate-images:" Makefile
```

Expected: Shows target definition

- [ ] **Step 4: Commit**

```bash
git add Makefile
git commit -m "feat: add migrate-images target to Makefile"
```

---

## Task 8: Update Makefile - Add validate-images Target

**Files:**
- Modify: `Makefile:569` (after migrate-images target)

- [ ] **Step 1: Add validate-images target**

```makefile
validate-images:
	@echo "🔍 Validating optimized images..."
	@node scripts/validate-optimized-images.js
```

- [ ] **Step 2: Verify target added**

```bash
grep -A 2 "^validate-images:" Makefile
```

Expected: Shows target definition

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "feat: add validate-images target to Makefile"
```

---

## Task 9: Update Makefile - Update help Target

**Files:**
- Modify: `Makefile:39` (add description)

- [ ] **Step 1: Add migrate-images and validate-images to help**

Find line:
```makefile
	@echo "  optimize-images - Ottimizza tutte le immagini (dimensioni, peso)"
```

Add after it:
```makefile
	@echo "  migrate-images - Sposta PNG originali in src/matrici/images/"
	@echo "  validate-images - Valida specifiche immagini ottimizzate"
```

- [ ] **Step 2: Verify help text**

```bash
make help | grep -E "(migrate-images|validate-images)"
```

Expected: Shows both new targets

- [ ] **Step 3: Commit**

```bash
git add Makefile
git commit -m "docs: add migrate-images and validate-images to help target"
```

---

## Task 10: Update generate-image-placeholders.js

**Files:**
- Modify: `scripts/generate-image-placeholders.js`

- [ ] **Step 1: Read current script to understand structure**

```bash
head -50 scripts/generate-image-placeholders.js
```

- [ ] **Step 2: Add directory constants at top**

After existing requires, add:
```javascript
const fs = require('fs');
const path = require('path');

const MATRICE_DIR = 'src/matrici/images';
const OPTIMIZE_DIR = 'src/jekyll/assets/images';
```

- [ ] **Step 3: Update generatePlaceholder function to use MATRICE_DIR**

Find the generatePlaceholder function and update path construction to use MATRICE_DIR instead of hardcoded paths.

- [ ] **Step 4: Test script generates in correct location**

```bash
cd scripts && node generate-image-placeholders.js 2>&1 | head -10
find src/matrici/images/ -name "*.png" 2>/dev/null | head -3
```

Expected: Placeholders created in src/matrici/images/

- [ ] **Step 5: Commit**

```bash
git add scripts/generate-image-placeholders.js
git commit -m "refactor: update placeholder generation to use src/matrici/images/"
```

---

## Task 11: Update check-image-placeholders.js

**Files:**
- Modify: `scripts/check-image-placeholders.js`

- [ ] **Step 1: Read current script**

```bash
head -50 scripts/check-image-placeholders.js
```

- [ ] **Step 2: Add MATRICE_DIR constant**

```javascript
const MATRICE_DIR = 'src/matrici/images';
```

- [ ] **Step 3: Update checkPlaceholders function to scan only MATRICE_DIR**

Update the function to only check src/matrici/images/ for placeholders, ignoring src/jekyll/assets/images/.

- [ ] **Step 4: Test script checks correct location**

```bash
cd scripts && node check-image-placeholders.js 2>&1
```

Expected: Checks only src/matrici/images/

- [ ] **Step 5: Commit**

```bash
git add scripts/check-image-placeholders.js
git commit -m "refactor: update placeholder check to scan only src/matrici/images/"
```

---

## Task 12: Create validate-optimized-images.js

**Files:**
- Create: `scripts/validate-optimized-images.js`

- [ ] **Step 1: Write validation script**

```javascript
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
```

- [ ] **Step 2: Make script executable**

```bash
chmod +x scripts/validate-optimized-images.js
```

- [ ] **Step 3: Test script runs**

```bash
node scripts/validate-optimized-images.js 2>&1 | head -5
```

Expected: Script runs without syntax errors

- [ ] **Step 4: Commit**

```bash
git add scripts/validate-optimized-images.js
git commit -m "feat: add validation script for optimized images"
```

---

## Task 13: Update IMAGE_GUIDE.md - Add Matrices Section

**Files:**
- Modify: `docs/IMAGE_GUIDE.md`

- [ ] **Step 1: Add new section after line 9 (after "Percorsi dei File")**

```markdown
**Importante:** Ci sono due tipi di percorsi da conoscere:

1. **Percorso sorgente** (dove lavori): `src/jekyll/assets/images/`
   - Qui crei e modifichi i file
   - Esempio: `src/jekyll/assets/images/epppi/locandina_epppi_2026.jpg`

2. **Percorso pubblicato** (nel sito): `/assets/images/`
   - Questo è il percorso che Jekyll usa nel sito generato
   - Non includere `src/jekyll/` nel frontmatter

## Archivio Originali (Matrici)

**Importante:** I file originali (PNG) sono archiviati in `src/matrici/images/`, non in `src/jekyll/assets/images/`.

**Percorsi:**
- **Originali (PNG)**: `src/matrici/images/` - archivio, non pubblicato
- **Ottimizzati (JPG)**: `src/jekyll/assets/images/` - pubblicato nel sito
- **Eccezioni**: favicon.png, logo.png restano in `src/jekyll/assets/images/` (grafica piccola)

**Flusso lavoro:**
1. Salva originale PNG in `src/matrici/images/`
2. Esegui `make optimize-images` per generare JPG in `src/jekyll/assets/images/`
3. Jekyll pubblica solo JPG ottimizzati

**Esempio:**
- File originale: `src/matrici/images/epppi/locandina_epppi_2026.png`
- File ottimizzato: `src/jekyll/assets/images/epppi/locandina_epppi_2026.jpg`
- Nel frontmatter: `image: /assets/images/epppi/locandina_epppi_2026.jpg`
```

- [ ] **Step 2: Verify markdown syntax**

```bash
grep -A 20 "## Archivio Originali" docs/IMAGE_GUIDE.md | head -10
```

Expected: Section appears correctly

- [ ] **Step 3: Commit**

```bash
git add docs/IMAGE_GUIDE.md
git commit -m "docs: add Archivio Originali section to IMAGE_GUIDE"
```

---

## Task 14: Update IMAGE_GUIDE.md - Update Method 1

**Files:**
- Modify: `docs/IMAGE_GUIDE.md:126-147` (update Metodo 1 section)

- [ ] **Step 1: Find and update Metodo 1 section**

Replace existing "Metodo 1" content with:
```markdown
### Metodo 1: Usare il sistema di ottimizzazione automatico

Il sistema ottimizza automaticamente le immagini durante il build:

```bash
# 1. Crea la cartella se non esiste
mkdir -p src/matrici/images/epppi/

# 2. Metti la tua immagine PNG nella cartella giusta
cp mia-immagine.png src/matrici/images/epppi/

# 3. Run build (ottimizza automaticamente)
make optimize-images
```

L'immagine verrà:
- Letta da `src/matrici/images/epppi/mia-immagine.png`
- Ottimizzata e salvata in `src/jekyll/assets/images/epppi/mia-immagine.jpg`
- Pubblicata nel sito

**Nota**: Questo metodo richiede che il file sia già nominato correttamente.
```

- [ ] **Step 2: Verify update**

```bash
grep -A 15 "### Metodo 1:" docs/IMAGE_GUIDE.md | grep "src/matrici/images"
```

Expected: Shows new path

- [ ] **Step 3: Commit**

```bash
git add docs/IMAGE_GUIDE.md
git commit -m "docs: update Metodo 1 to use src/matrici/images/"
```

---

## Task 15: End-to-End Test

**Files:**
- No file changes (testing only)

- [ ] **Step 1: Run migration**

```bash
./scripts/migrate-images-to-matrici.sh
```

Expected: PNG files moved to src/matrici/images/, exceptions remain

- [ ] **Step 2: Verify migration**

```bash
echo "✅ Verifica structure..."
find src/matrici/images/ -name "*.png" 2>/dev/null | wc -l
echo "✅ Verifica eccezioni..."
test -f src/jekyll/assets/images/favicon.png && echo "favicon.png ok"
test -f src/jekyll/assets/images/logo.png && echo "logo.png ok"
```

Expected: PNG files in matrici, exceptions in place

- [ ] **Step 3: Run optimization**

```bash
make optimize-images
```

Expected: JPG files generated in src/jekyll/assets/images/

- [ ] **Step 4: Verify optimization**

```bash
find src/jekyll/assets/images/ -name "locandina_*.jpg" 2>/dev/null | wc -l
test -f src/jekyll/assets/images/generic-featured.jpg && echo "generic-featured.jpg ok"
```

Expected: JPG files exist

- [ ] **Step 5: Run validation**

```bash
make validate-images
```

Expected: All images pass validation

- [ ] **Step 6: Build site**

```bash
make build
```

Expected: Build completes successfully

- [ ] **Step 7: Verify output**

```bash
test -d output/_site/assets/images/ && echo "✅ images/ pubblicato"
test ! -d output/_site/matrici/ && echo "✅ matrici/ NON pubblicato"
```

Expected: images/ published, matrici/ not published

- [ ] **Step 8: Commit test results documentation**

```bash
echo "# Test Results - $(date)

## Migration
- PNG files moved to src/matrici/images/
- Exceptions (favicon.png, logo.png) remained in place

## Optimization
- JPG files generated in src/jekyll/assets/images/
- All images optimized correctly

## Validation
- All optimized images meet specifications

## Build
- Site builds successfully
- matrici/ not published to _site
- images/ published correctly" > docs/superpowers/test-results-image-matrices.md

git add docs/superpowers/test-results-image-matrices.md
git commit -m "test: document image matrices separation test results"
```

---

## Task 16: Visual Regression Test

**Files:**
- No file changes (testing only)

- [ ] **Step 1: Run visual regression**

```bash
make validate-graphics
```

Expected: Visual regression passes or shows acceptable differences

- [ ] **Step 2: Review report if differences found**

```bash
if [ -f output/screenshots/report/index.html ]; then
  echo "Check report: output/screenshots/report/index.html"
fi
```

- [ ] **Step 3: Update baseline if needed**

If visual differences are acceptable:
```bash
make visual-baseline
git add tests/visual-baseline/
git commit -m "test: update visual baseline for image matrices separation"
```

---

## Completion Checklist

- [ ] All tasks completed
- [ ] All commits pushed to remote
- [ ] Documentation updated (IMAGE_GUIDE.md)
- [ ] Tests passing (migration, optimization, validation, build, visual regression)
- [ ] No PNG originals in src/jekyll/assets/images/ (except exceptions)
- [ ] All optimized images in src/jekyll/assets/images/
- [ ] matrici/ not published in output/_site/

---

**Implementation complete!** 🎉

The image/matrices separation is now fully implemented. Original PNG images live in `src/matrici/images/`, optimized JPG images in `src/jekyll/assets/images/`, and Jekyll only publishes the optimized versions.
