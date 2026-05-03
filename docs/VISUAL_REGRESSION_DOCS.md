# Visual Regression Skill - Implementazione Completa

## ✅ Implementazione Completata

Sistema di validazione grafica automatica creato e configurato per bitprepared.it.

## 📁 File Creati

### Script Node.js
- `scripts/visual-regression/package.json` - Dipendenze
- `scripts/visual-regression/capture.js` - Screenshot multi-viewport
- `scripts/visual-regression/compare.js` - Confronto pixelmatch
- `scripts/visual-regression/create-baseline.js` - Generazione baseline
- `scripts/visual-regression/README.md` - Documentazione

### Directory
- `tests/visual-baseline/{desktop,mobile,tablet}/` - Baseline images
- `screenshots/{serve,static,diff}/{desktop,mobile,tablet}/` - Temp images

### Configurazioni
- `Makefile` - Nuovi target: validate-graphics, visual-baseline, visual-clean
- `.gitignore` - screenshots/ e node_modules/ ignorati

## 🚀 Quick Start

### 1. Setup (già fatto)
```bash
cd scripts/visual-regression
npm install
```

### 2. Crea baseline (prima volta)
```bash
make visual-baseline
git add tests/visual-baseline/
git commit -m "Add visual baseline"
```

### 3. Valida prima di release
```bash
make validate-graphics
```

**Output**:
- ✅ **Pass**: `Validazione completata`
- ❌ **Fail**: Report HTML in `screenshots/report/index.html`

## 📊 Report HTML

Apri report per vedere differenze:
```bash
xdg-open screenshots/report/index.html
```

**Contenuto**:
- Tabella tutti test (57 tests: 19 pagine × 3 viewports)
- Percentuale differenza pixel
- Status ✅/❌
- Link a diff images
- Filtri: All, Failures Only

## 🎯 Target Makefile

```bash
make help
```

Nuovi target:
- `validate-graphics` - Validazione completa
- `visual-baseline` - Crea/aggiorna baseline
- `visual-clean` - Pulisci screenshot temp

## 📱 Viewports

- **Desktop**: 1920×1080
- **Tablet**: 768×1024
- **Mobile**: 375×667

## 📄 Pagine Testate (19)

**Critical (5)**:
- `/` - Homepage
- `/eventi/epppi/` - Layout evento speciale
- `/about/` - About staff
- `/software/` - Indice software
- `/blog/` - Blog

**Eventi (2)**:
- `/eventi/campo-eg/`
- `/eventi/stage/`

**Software (10)**:
- `/software/libreoffice/`
- `/software/gimp/`
- `/software/qgis/`
- `/software/mayalinux/`
- `/software/vlc/`
- `/software/wordpress/`
- `/software/flora/`
- `/software/code/`
- `/software/prbm/`

**Altro (1)**:
- `/articles/`

## 🔧 Funzionamento Tecnico

### Stack
- **Screenshot**: Playwright (Chromium headless)
- **Confronto**: pixelmatch (pixel-by-pixel)
- **Threshold**: 1% pixel diversi
- **Report**: HTML + JSON

### Processo
1. `capture.js`:
   - Avvia `make serve` (porta 4000)
   - Screenshot 19 pagine × 3 viewports
   - Avvia `make serve-static` (porta 8000)
   - Screenshot 19 pagine × 3 viewports

2. `compare.js`:
   - Confronta screenshots vs baseline
   - Genera diff images
   - Calcola % differenze
   - Genera report HTML
   - Exit code 1 se fail

## 📝 Workflow Release

```bash
# 1. Sviluppi feature
git checkout -b feature/new-layout

# 2. Valida graficamente
make validate-graphics

# 3a. Se OK:
# ✅ Validazione completata
# Procedi con deploy

# 3b. Se differenze:
# ❌ Validazione fallita
# Apri report: xdg-open screenshots/report/index.html

# 4. Review diff images
# Se differenze accettabili (fix bug grafico):
make visual-baseline
git add tests/visual-baseline/
git commit -m "Update baseline after fix"

# Se differenze bug da fixare:
# Fix codice CSS/HTML
# Ripeti da step 2

# 5. Deploy
git push
```

## ⚙️ Configurazione

### Modifica Threshold (1% default)
Edit `scripts/visual-regression/compare.js`:
```javascript
const THRESHOLD_PERCENT = 1; // Modifica qui
```

### Aggiungi pagine
Edit `scripts/visual-regression/capture.js`:
```javascript
const pages = [
  '/',
  '/new-page/',  // Aggiungi qui
  // ...
];
```

### Modifica viewports
Edit `scripts/visual-regression/capture.js`:
```javascript
const viewports = {
  desktop: { width: 1920, height: 1080 },
  custom: { width: 1440, height: 900 },  // Aggiungi qui
};
```

## 🧪 Test

Verifica installazione:
```bash
cd scripts/visual-regression
node -e "console.log(require('pixelmatch'), require('pngjs'), require('@playwright/test'))"
```

Verifica target Makefile:
```bash
make help | grep visual
```

## 📊 Performance

- **Tempo totale**: ~5-10 minuti
  - Screenshot: 3-5 min (57 images × 2 server)
  - Confronto: ~10 sec
  - Report: ~5 sec

- **Spazio disco**:
  - Baseline: ~50 MB
  - Screenshots temp: ~150 MB
  - Report: ~1 MB

## 🐛 Troubleshooting

**Dipendenze non installate**:
```bash
cd scripts/visual-regression
npm install
```

**Baseline mancante**:
```bash
make visual-baseline
```

**Server non parte**:
```bash
# Verifica Docker attivo
docker ps

# Verifica porte libere
netstat -tuln | grep -E '4000|8000'
```

**Screenshot vuoti**:
```bash
# Aumenta timeout in capture.js
await page.goto(fullUrl, {
  waitUntil: 'networkidle',
  timeout: 60000  // Aumenta da 30000
});
```

## 🎉 Prossimi Passi

1. **Prima volta**: Crea baseline
   ```bash
   make visual-baseline
   git add tests/visual-baseline/
   git commit -m "Add visual baseline"
   ```

2. **Prima di ogni release**: Valida
   ```bash
   make validate-graphics
   ```

3. **Se cambia grafica intenzionalmente**: Aggiorna baseline
   ```bash
   make visual-baseline
   git add tests/visual-baseline/
   git commit -m "Update baseline for new design"
   ```

## 📚 Riferimenti

- Playwright: https://playwright.dev/
- pixelmatch: https://github.com/mapbox/pixelmatch
- Makefile: `make help`

---

**Creato**: 2026-04-21
**Versione**: 1.0.0
**Stato**: ✅ Pronto per uso
