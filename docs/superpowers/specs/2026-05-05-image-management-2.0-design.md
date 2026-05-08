# Image Management 2.0 - Design Document

**Data**: 2026-05-05
**Status**: Approved
**Autore**: Claude + User brainstorming

## Obiettivo

Sistema migliorato per gestione immagini BitPrepared che risolve:
1. **Matrici confuse**: PNG/JPG mescolati senza regole chiare
2. **Icone multiple**: Favicon, apple-touch-icon difficili da gestire
3. **Immagini bloccate**: File già ottimizzati che non devono essere toccati
4. **Placeholder automatici**: Generati per tutte le combinazioni mancanti

## Architettura

Sistema basato su **3 pilastri**:

1. **Struttura matrici organizzata** - Directory esplicite per tipologia
2. **Sorgente unica icone** - SVG → genera automaticamente tutte le varianti
3. **File manifesto** - Dichiarano regole di conversione e file bloccati

```
Matrici (src/matrici/images/)
    ↓ Struttura organizzata
Manifesti (.locked + .rules)
    ↓ Regole esplicite
Assets (src/jekyll/assets/images/)
    ↓ Ottimizzati per produzione
Sito pubblicato
```

## Componenti

### 1. Struttura Directory Matrici

```
src/matrici/images/
├── production/           # → assets/images/ (ottimizzato per sito)
│   ├── eventi/          # Locandine + featured per eventi
│   │   ├── epppi/
│   │   ├── campo-eg/
│   │   └── stage/
│   ├── software/        # Loghi software
│   ├── loghi-branche/   # Loghi EG/RS/Capi
│   └── root/            # generic-featured, agesci-logo, placeholders
├── source-icons/        # Sorgenti uniche → generano multiple varianti
│   └── site-icon.svg    # Genera favicon.ico, apple-touch-icon*.png, manifest.json
├── supporto/            # NON copiato (strumenti, mockup, risorse)
│   ├── mockup/
│   ├── strumenti/
│   └── risorse/
└── .gitignore           # Esclude supporto/ da git
```

**Regole copia:**
- `production/**` → copiato in `assets/images/`
- `source-icons/` → genera icone multiple, non copiato direttamente
- `supporto/` → mai copiato, archivio solo

**Nota**: `favicon.ico`, `apple-touch-icon*.png`, `manifest.json` sono generati da `source-icons/site-icon.svg`, non presenti in `production/`

### 2. File Manifesto

**`.locked`** - File che non devono essere modificati:
```bash
# Immagini "congelate" - non ottimizzare né convertire
generic-featured.png
agesci_logo.png
placeholder-blog.png
placeholder-news.png
```

**`.rules`** - Regole conversioni per categoria:
```bash
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
```

### 3. Sorgente Unica Icone (SVG)

**`source-icons/site-icon.svg`** - Unico file vettoriale

**Genera automaticamente:**
- `favicon.ico` (multi-size: 16x16, 32x32)
- `apple-touch-icon-72x72-precomposed.png`
- `apple-touch-icon-114x114-precomposed.png`
- `apple-touch-icon-144x144-precomposed.png`
- `favicon.png` (32x32)
- `apple-touch-icon-precomposed.png` (fallback)
- `manifest.json` per PWA

**Vantaggi:**
- Aggiorni 1 solo SVG
- Rigeneri tutte le varianti
- Nessuna ridondanza

### 4. Makefile Targets

```makefile
# Organizza matrici (crea struttura se non esiste)
init-matrici:
	@echo "📁 Inizializzazione struttura matrici..."
	@mkdir -p src/matrici/images/{production/{eventi,software,loghi-branche,root},source-icons,supporto}
	@echo "✅ Struttura creata"

# Genera icone da SVG sorgente
generate-icons:
	@echo "🎨 Generazione icone da SVG..."
	@node scripts/generate-icons-from-svg.js
	@echo "✅ Icone generate"

# Ottimizza production (rispetta .locked e .rules)
optimize-images:
	@echo "🖼️  Ottimizzazione immagini con manifesti..."
	@node scripts/optimize-with-manifest.js
	@echo "✅ Ottimizzazione completata"
```

### 5. Script Intelligente

**`scripts/optimize-with-manifest.js`**:
```javascript
// 1. Legge .locked → salta file bloccati
// 2. Legge .rules → applica conversioni per categoria
// 3. Rispetta struttura production/ vs supporto/
// 4. Genera assets/images/ ottimizzati
```

**`scripts/generate-icons-from-svg.js`**:
```javascript
// Genera tutte le varianti icone da site-icon.svg
const sharp = require('sharp');

async function generateIcons() {
  const svg = 'src/matrici/images/source-icons/site-icon.svg';
  const output = 'src/jekyll/assets/images';
  
  // Favicon.ico (multi-size)
  await sharp(svg)
    .resize(16, 16)
    .toFile(`${output}/favicon-16x16.png`);
  await sharp(svg)
    .resize(32, 32)
    .toFile(`${output}/favicon-32x32.png`);
  // Combina in .ico usando icongen o sharp-ico
  
  // Apple touch icons
  await sharp(svg)
    .resize(72, 72)
    .png()
    .toFile(`${output}/apple-touch-icon-72x72-precomposed.png`);
    
  await sharp(svg)
    .resize(114, 114)
    .png()
    .toFile(`${output}/apple-touch-icon-114x114-precomposed.png`);
    
  await sharp(svg)
    .resize(144, 144)
    .png()
    .toFile(`${output}/apple-touch-icon-144x144-precomposed.png`);
  
  // Fallback PNG
  await sharp(svg)
    .resize(192, 192)
    .png()
    .toFile(`${output}/apple-touch-icon-precomposed.png`);
  
  // Manifest.json per PWA
  const manifest = {
    name: "Bit Prepared",
    icons: [
      { src: "/assets/images/apple-touch-icon-72x72-precomposed.png", sizes: "72x72", type: "image/png" },
      { src: "/assets/images/apple-touch-icon-114x114-precomposed.png", sizes: "114x114", type: "image/png" },
      { src: "/assets/images/apple-touch-icon-144x144-precomposed.png", sizes: "144x144", type: "image/png" }
    ]
  };
  
  fs.writeFileSync(
    `${output}/manifest.json`,
    JSON.stringify(manifest, null, 2)
  );
}
```

## Workflow Sviluppo

### Nuovo Evento

```bash
# 1. Aggiungi locandina alle matrici
cp locandina_campo-eg_2026.png src/matrici/images/production/eventi/campo-eg/

# 2. Ottimizza (rispetta manifesti)
make optimize-images

# 3. Verifica output
ls -lh src/jekyll/assets/images/eventi/campo-eg/locandina_campo-eg_2026.jpg
```

### Nuovo Logo Software

```bash
# 1. Aggiungi PNG alle matrici
cp gimp-nuovo.png src/matrici/images/production/software/

# 2. Ottimizza (copia PNG, no conversione per .rules)
make optimize-images

# 3. Verifica
ls -lh src/jekyll/assets/images/software/gimp-nuovo.png
```

### Aggiorna Icone Sito

```bash
# 1. Modifica solo SVG sorgente
vim src/matrici/images/source-icons/site-icon.svg

# 2. Rigenera tutte le varianti
make generate-icons

# 3. Verifica
ls -lh src/jekyll/assets/images/favicon.ico
ls -lh src/jekyll/assets/images/apple-touch-icon-*-precomposed.png
```

## Conversion Rules

### Production → Assets

**Eventi** (`production/eventi/`):
- PNG → JPG
- Dimensioni: 3508×4961 (A3 @ 300DPI)
- Qualità: 85%
- Max peso: 500KB

**Software** (`production/software/`):
- PNG → PNG (trasparenza preservata)
- Copia diretta, no ottimizzazione
- Regola: `copy_only: true`

**Loghi Bran** (`production/loghi-branche/`):
- PNG → PNG (trasparenza preservata)
- Copia diretta, no ottimizzazione
- Regola: `copy_only: true`

**Root** (`production/root/`):
- PNG → JPG (se non in `.locked`)
- Dimensioni: 1200×630 (16:9)
- Qualità: 85%
- Max peso: 300KB

### Gestione JPG durante migrazione

**File JPG in matrici (vecchio sistema):**
- Rimossi durante migrazione (comando `find ... -name "*.jpg" -delete`)
- Solo PNG originali mantenuti come "fonte della verità"
- JPG generati automaticamente da PNG durante `make optimize-images`

**Eccezioni:**
- Se hai JPG che NON derivano da PNG (es. foto esterne)
- Aggiungi direttamente a `production/` con estensione .jpg
- Sistema li tratterà come "già ottimizzati" e copierà solo

### File Locked

### Production → Assets

**Eventi** (`production/eventi/`):
- PNG → JPG
- Dimensioni: 3508×4961 (A3 @ 300DPI)
- Qualità: 85%
- Max peso: 500KB

**Software** (`production/software/`):
- PNG → PNG (trasparenza preservata)
- Copia diretta, no ottimizzazione
- Regola: `copy_only: true`

**Loghi Bran** (`production/loghi-branche/`):
- PNG → PNG (trasparenza preservata)
- Copia diretta, no ottimizzazione
- Regola: `copy_only: true`

**Root** (`production/root/`):
- PNG → JPG (se non in `.locked`)
- Dimensioni: 1200×630 (16:9)
- Qualità: 85%
- Max peso: 300KB

### File Locked

File in `.locked` vengono **copiati mai modificati**:
- `generic-featured.png` → copiato così com'è
- `agesci_logo.png` → copiato così com'è
- `placeholder-*.png` → copiato così com'è

### Supporto/

File in `supporto/` **mai copiati** in assets:
- Mockup design
- Strumenti di lavoro
- Risorse varie
- Archivio storico

## Placeholder Automatici

Sistema placeholder esistente (`generate-image-placeholders.js`) aggiornato:
- Genera solo per combinazioni mancanti
- Rispetta struttura `production/`
- Verifica `.locked` prima di sovrascrivere
- Crea file in `production/` non in `assets/`

## Migrazione Sistema Attuale

### Fase 1: Riorganizza Matrici

```bash
# 1. Inizializza nuova struttura
make init-matrici

# 2. Identifica immagini inutilizzate
# Verifica quali file non sono referenziati nel sito
grep -r "epppi-matrix" src/jekyll/_posts/ src/jekyll/_eventi/ || echo "epppi-matrix non usato"
grep -r "locandina_stage" src/jekyll/_eventi/ || echo "locandina_stage non usato"

# 3. Sposta file usati in production/ (solo PNG originali)
mv src/matrici/images/epppi/*.png src/matrici/images/production/eventi/epppi/
mv src/matrici/images/campo-eg/*.png src/matrici/images/production/eventi/campo-eg/
mv src/matrici/images/stage/*.png src/matrici/images/production/eventi/stage/
mv src/matrici/images/pages/software src/matrici/images/production/software
mv src/matrici/images/loghi_branche/* src/matrici/images/production/loghi-branche/

# 4. Sposta root PNG usati
mv src/matrici/images/generic-featured.png src/matrici/images/production/root/
mv src/matrici/images/agesci_logo.png src/matrici/images/production/root/
mv src/matrici/images/placeholder-*.png src/matrici/images/production/root/

# 5. Sposta immagini inutilizzate in supporto/
# Esempi: vecchie versioni, ambientazioni non usate, file di test
mv src/matrici/images/campo-eg/campo-eg-matrix-featured.png src/matrici/images/supporto/
mv src/matrici/images/epppi/epppi-matrix-featured.png src/matrici/images/supporto/
mv src/matrici/images/stage/stage-matrix-featured.png src/matrici/images/supporto/

# 6. Rimuovi JPG duplicati da vecchio sistema
find src/matrici/images -name "*.jpg" -delete

# 7. Crea SVG sorgente icone (versione 1: upscaling PNG esistente)
# NOTA: 57x57 è troppo piccolo per qualità, meglio ridisegnare in vettoriale
# Opzione A: Upscaling temporaneo (qualità mediocre)
convert src/matrici/images/apple-touch-icon-precomposed.png -resize 512x512 src/matrici/images/source-icons/site-icon.svg

# Opzione B: Ridisegno vettoriale (consigliato)
# Usare Inkscape/Figma per creare site-icon.svg 512x512 da zero
# Oppure usare servizio online per convertire PNG → SVG
```

### Fase 2: Crea Manifesti

```bash
# Crea .locked
cat > src/matrici/images/.locked << 'EOF'
# Immagini "congelate" - non ottimizzare né convertire
generic-featured.png
agesci_logo.png
placeholder-blog.png
placeholder-news.png
EOF

# Crea .rules
cat > src/matrici/images/.rules << 'EOF'
# Regole conversione per categoria
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
EOF
```

### Fase 3: Implementa Script

**`scripts/optimize-with-manifest.js`**:
```javascript
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const MATRICE_DIR = 'src/matrici/images';
const ASSETS_DIR = 'src/jekyll/assets/images';

// Leggi manifesti
const lockedFiles = fs.readFileSync(`${MATRICE_DIR}/.locked`, 'utf8')
  .split('\n')
  .filter(line => line && !line.startsWith('#'))
  .map(line => line.trim());

const rules = parseRules(`${MATRICE_DIR}/.rules`);

// Ottimizza production/
async function optimizeProduction() {
  const productionDir = path.join(MATRICE_DIR, 'production');
  
  findFiles(productionDir).forEach(file => {
    const relativePath = path.relative(productionDir, file);
    const targetPath = path.join(ASSETS_DIR, relativePath);
    
    // Skip se locked
    if (lockedFiles.includes(relativePath)) {
      console.log(`🔒 Locked: ${relativePath}`);
      copyFile(file, targetPath);
      return;
    }
    
    // Applica regole per categoria
    const category = getCategory(relativePath);
    const rule = rules[category];
    
    if (rule && rule.copy_only) {
      console.log(`📋 Copy only: ${relativePath}`);
      copyFile(file, targetPath);
    } else if (rule && rule.convert_to) {
      console.log(`📸 Convert: ${relativePath} → ${rule.convert_to}`);
      convertFile(file, targetPath, rule);
    }
  });
}
```

### Fase 4: Aggiorna Makefile

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

## Error Handling

### Manifesti Mancanti

```bash
# Se .locked non esiste
if [ ! -f "${MATRICE_DIR}/.locked" ]; then
  echo "⚠️  .locked mancante, uso default (nessun file locked)"
  lockedFiles=()
fi

# Se .rules non esiste
if [ ! -f "${MATRICE_DIR}/.rules" ]; then
  echo "⚠️  .rules mancante, uso default (JPG per tutti)"
  useDefaultRules=true
fi
```

### SVG Sorgente Mancante

```bash
# Se site-icon.svg non esiste
if [ ! -f "${MATRICE_DIR}/source-icons/site-icon.svg" ]; then
  echo "❌ ERRORE: site-icon.svg non trovato"
  echo "   Crea: src/matrici/images/source-icons/site-icon.svg"
  exit 1
fi
```

### File Already Locked

Se tentativo di ottimizzare file in `.locked`:
```bash
if [[ " ${lockedFiles[@]} " =~ " ${filename} " ]]; then
  echo "⚠️  SKIP: ${filename} è locked (vedi .locked)"
  continue
fi
```

## Testing

### Test Struttura

```bash
# Verifica struttura matrici
make init-matrici
tree src/matrici/images/

# Atteso:
# ├── production/
# ├── source-icons/
# └── supporto/
```

### Test Locked

```bash
# Aggiungi file a .locked
echo "test-locked.png" >> src/matrici/images/.locked

# Prova ottimizzare
make optimize-images

# Verifica che test-locked.png sia stato copiato non modificato
```

### Test Icone

```bash
# Genera icone da SVG
make generate-icons

# Verifica file generati
ls -lh src/jekyll/assets/images/favicon.ico
ls -lh src/jekyll/assets/images/apple-touch-icon-*-precomposed.png
ls -lh src/jekyll/assets/images/manifest.json
```

## Success Criteria

✅ Struttura matrici organizzata in 3 sottodirectory  
✅ File `.locked` protegge immagini da modifiche  
✅ File `.rules` dichiara conversioni per categoria  
✅ SVG singolo genera tutte le varianti icone  
✅ Script rispetta manifesti durante ottimizzazione  
✅ `supporto/` escluso da copia automatica  
✅ Placeholder generati solo se mancanti  
✅ CI verifica sync matrici → assets  

## Documentazione Aggiornata

**`docs/IMAGE_GUIDE.md`** - Sezioni nuove:
- "Struttura Matrici Organizzata"
- "File Manifesti (.locked e .rules)"
- "Sorgente Unica Icone (SVG)"
- "Workflow Migrazione Sistema Attuale"

**`README.md`** - Sezione aggiornata:
- "Gestione Immagini 2.0"
- Comandi nuovi: `init-matrici`, `generate-icons`

## Prossimi Passi

1. **Implementazione**:
   - Riorganizza struttura matrici
   - Crea file manifesti
   - Implementa script optimize-with-manifest.js
   - Implementa script generate-icons-from-svg.js
   - Aggiorna Makefile targets

2. **Testing**:
   - Test struttura organizzata
   - Test locked files
   - Test generazione icone SVG
   - Test regole conversione

3. **Documentazione**:
   - Aggiorna IMAGE_GUIDE.md
   - Aggiorna README.md
   - Crea guida migrazione

4. **Deploy**:
   - CI verifica sync matrici → assets
   - CI genera icone durante build
   - Placeholder bloccano deployment
