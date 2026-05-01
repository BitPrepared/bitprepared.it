# Fase 1: CSS/JS Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rimuovi tutti gli inline CSS/JS dal sito Jekyll, mantieni solo inline legittimi (JSON-LD SEO, tags page con Liquid)

**Architecture:** Sposta inline styles in classi CSS utility, sposta edit button in JS file esterno con data attributes per passare variabili Liquid

**Tech Stack:** Jekyll 4, CSS utility classes, JavaScript ES6, Makefile

---

## File Structure

```
bitprepared.it/
├── assets/
│   ├── css/
│   │   └── scout-tech.css          # MODIFY: Aggiungi .text-brand-dark, .text-muted
│   └── js/
│       └── edit-button-dev.js      # CREATE: Development edit button
├── _includes/
│   └── edit-button.html            # MODIFY: Sposta logica in JS, usa data attributes
├── index.html                      # MODIFY: Rimuovi style="" inline
└── Makefile                        # MODIFY: Aggiungi target test-cleanup
```

---

## Task 1: Aggiungi Utility Classes CSS

**Files:**
- Modify: `assets/css/scout-tech.css`

- [ ] **Step 1: Apri file scout-tech.css**

```bash
nano assets/css/scout-tech.css
# Oppure usa il tuo editor preferito
```

- [ ] **Step 2: Aggiungi utility classes per brand colors**

Aggiungi alla fine del file:
```css
/* ==================================================
   BRAND COLOR UTILITIES
   Sostituiscono inline styles in index.html
   ================================================== */

.text-brand-dark {
  color: #0a3d0a;
}

.text-muted {
  color: #666666;
}
```

- [ ] **Step 3: Salva file**

```bash
# Salva ed esci dall'editor
# In nano: Ctrl+O, Invio, Ctrl+X
```

- [ ] **Step 4: Verifica sintassi CSS**

```bash
# Non c'è syntax checker CSS di base, ma verifica che il file sia valido
cat assets/css/scout-tech.css | tail -10
# Expected: Vedi le nuove classi aggiunte
```

- [ ] **Step 5: Commit**

```bash
git add assets/css/scout-tech.css
git commit -m "feat: add brand color utility classes

Add .text-brand-dark and .text-muted to replace inline styles"
```

---

## Task 2: Rimuovi Inline CSS da index.html (Card 1)

**Files:**
- Modify: `index.html:56-57`

- [ ] **Step 1: Trova inline styles in index.html**

```bash
grep -n "style=" index.html
# Expected: 5 occorrenze trovate
```

- [ ] **Step 2: Apri index.html alla linea 56**

```bash
sed -n '50,60p' index.html
# Vedi le due linee con style="color: #0a3d0a;" e style="color: #666666;"
```

- [ ] **Step 3: Sostituisci primo inline style (h3 title)**

Cerca:
```html
<h3 class="text-2xl font-display font-bold mb-3" style="color: #0a3d0a;">Campo di Competenza EG</h3>
```

Sostituisci con:
```html
<h3 class="text-2xl font-display font-bold mb-3 text-brand-dark">Campo di Competenza EG</h3>
```

- [ ] **Step 4: Sostituisci secondo inline style (p description)**

Cerca:
```html
<p class="mb-4 flex-grow" style="color: #666666;">Google, social network, fotoritoco, video editing, coding e tanto altro. Mantenendo lo stile scout che ci contraddistingue!</p>
```

Sostituisci con:
```html
<p class="mb-4 flex-grow text-muted">Google, social network, fotoritocco, video editing, coding e tanto altro. Mantenendo lo stile scout che ci contraddistingue!</p>
```

- [ ] **Step 5: Verifica modifiche**

```bash
sed -n '50,60p' index.html
# Expected: Vedi class="text-brand-dark" e class="text-muted", nessuno style=""
```

- [ ] **Step 6: Commit**

```bash
git add index.html
git commit -m "refactor: remove inline styles from card 1 (Campo EG)

Replace style=\"color: #0a3d0a;\" with .text-brand-dark class
Replace style=\"color: #666666;\" with .text-muted class"
```

---

## Task 3: Rimuovi Inline CSS da index.html (Card 2)

**Files:**
- Modify: `index.html:69-70`

- [ ] **Step 1: Trova seconda occorrenza inline styles**

```bash
grep -n "style=" index.html | head -5
# Expected: 3 occorrenze rimaste (linee ~69, 70, 82, 83)
```

- [ ] **Step 2: Sostituisci inline style in h3 (Card 2)**

Cerca (linea ~69):
```html
<h3 class="text-2xl font-display font-bold mb-3" style="color: #0a3d0a;">EPPPI per RS</h3>
```

Sostituisci con:
```html
<h3 class="text-2xl font-display font-bold mb-3 text-brand-dark">EPPPI per RS</h3>
```

- [ ] **Step 3: Sostituisci inline style in p (Card 2)**

Cerca (linea ~70):
```html
<p class="mb-4 flex-grow" style="color: #666666;">La scelta politica nelle società iperconnesse. Come possiamo sfruttare i social network per agire? Workshop intensivi per Rover/Scolte.</p>
```

Sostituisci con:
```html
<p class="mb-4 flex-grow text-muted">La scelta politica nelle società iperconnesse. Come possiamo sfruttare i social network per agire? Workshop intensivi per Rover/Scolte.</p>
```

- [ ] **Step 4: Verifica modifiche**

```bash
grep -n "style=" index.html
# Expected: 2 occorrenze rimaste (Card 3)
```

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "refactor: remove inline styles from card 2 (EPPPI)

Replace style=\"color: #0a3d0a;\" with .text-brand-dark class
Replace style=\"color: #666666;\" with .text-muted class"
```

---

## Task 4: Rimuovi Inline CSS da index.html (Card 3)

**Files:**
- Modify: `index.html:82-83`

- [ ] **Step 1: Trova ultime occorrenze inline styles**

```bash
grep -n "style=" index.html
# Expected: 2 occorrenze (Card 3 - Stage)
```

- [ ] **Step 2: Sostituisci inline style in h3 (Card 3)**

Cerca (linea ~82):
```html
<h3 class="text-2xl font-display font-bold mb-3" style="color: #0a3d0a;">Stage per Capi</h3>
```

Sostituisci con:
```html
<h3 class="text-2xl font-display font-bold mb-3 text-brand-dark">Stage per Capi</h3>
```

- [ ] **Step 3: Sostituisci inline style in p (Card 3)**

Cerca (linea ~83):
```html
<p class="mb-4 flex-grow" style="color: #666666;">Essere scout nell'era del Web 2.0. La legge scout riletta in ottica del sempre connesso e del tutto adesso, qui e subito.</p>
```

Sostituisci con:
```html
<p class="mb-4 flex-grow text-muted">Essere scout nell'era del Web 2.0. La legge scout riletta in ottica del sempre connesso e del tutto adesso, qui e subito.</p>
```

- [ ] **Step 4: Verifica zero inline styles**

```bash
grep -r "style=" index.html
# Expected: Nessuna occorrenza (solo JSON-LD schema in <script type="application/ld+json">)
```

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "refactor: remove inline styles from card 3 (Stage)

Replace style=\"color: #0a3d0a;\" with .text-brand-dark class
Replace style=\"color: #666666;\" with .text-muted class

All inline CSS removed from index.html (except JSON-LD schema)"
```

---

## Task 5: Crea Edit Button Development Script

**Files:**
- Create: `assets/js/edit-button-dev.js`

- [ ] **Step 1: Leggi edit-button.html corrente**

```bash
cat _includes/edit-button.html
# Expected: Vedi lo script inline che deve essere spostato
```

- [ ] **Step 2: Crea nuovo file JS**

```bash
cat > assets/js/edit-button-dev.js << 'EOF'
/**
 * Development-only Edit Button
 *
 * Caricato solo in development environment (jekyll.environment == 'development')
 * Apre MarkText per modificare il file markdown corrente
 *
 * Dipendenze: Data attributes sul tag <script>
 *   - data-project-path: PATH del progetto (da _config.yml)
 *   - data-page-path: PATH della pagina corrente
 */

(function() {
  'use strict';

  // Leggi configurazione dai data attributes dello script tag
  const scriptTag = document.currentScript || document.querySelector('script[src*="edit-button-dev.js"]');
  if (!scriptTag) {
    console.error('[Edit Button] Script tag non trovato');
    return;
  }

  const projectPath = scriptTag.getAttribute('data-project-path');
  const pagePath = scriptTag.getAttribute('data-page-path');

  if (!projectPath || !pagePath) {
    console.error('[Edit Button] Data attributes mancanti:', { projectPath, pagePath });
    return;
  }

  const markdownPath = `${projectPath}/${pagePath}`;
  console.log('[Edit Button] Inizializzato:', markdownPath);

  /**
   * Apre MarkText con il file markdown corrente
   */
  function openMarkText() {
    console.log('[Edit Button] Click icona modifica');

    if (!markdownPath) {
      console.error('[Edit Button] Nessun path markdown disponibile');
      showNotification('❌ Path markdown non trovato', 'error');
      return;
    }

    try {
      console.log('[Edit Button] File path:', markdownPath);
      const editorUri = `marktext://file/${markdownPath}`;
      console.log('[Edit Button] URI scheme:', editorUri);
      window.location.href = editorUri;
      showNotification('✅ Apertura MarkText...');
    } catch (error) {
      console.error('[Edit Button] Errore:', error);
      showNotification('❌ Errore apertura editor', 'error');
    }
  }

  /**
   * Mostra notifica temporanea
   * @param {string} message - Messaggio da mostrare
   * @param {string} type - 'success' o 'error'
   */
  function showNotification(message, type = 'success') {
    // Rimuovi notifica esistente
    const existing = document.querySelector('.edit-button-notification');
    if (existing) existing.remove();

    const notification = document.createElement('div');
    notification.className = 'edit-button-notification';
    notification.textContent = message;

    // Inline styles per notifica (development-only)
    notification.style.cssText = [
      'position: fixed',
      'top: 20px',
      'right: 20px',
      `background: ${type === 'error' ? '#ef4444' : '#10b981'}`,
      'color: white',
      'padding: 15px 20px',
      'border-radius: 8px',
      'box-shadow: 0 4px 12px rgba(0,0,0,0.15)',
      'z-index: 10001',
      'font-weight: 500',
      'font-family: system-ui, sans-serif'
    ].join(';');

    document.body.appendChild(notification);

    setTimeout(() => notification.remove(), 3000);
  }

  // Inizializza quando il DOM è pronto
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      window.editButtonOpenMarkText = openMarkText;
    });
  } else {
    window.editButtonOpenMarkText = openMarkText;
  }

  console.log('[Edit Button] Pronto');
})();
EOF
```

- [ ] **Step 3: Verifica file creato**

```bash
cat assets/js/edit-button-dev.js | head -20
# Expected: Vedi l'header del file JS
```

- [ ] **Step 4: Commit**

```bash
git add assets/js/edit-button-dev.js
git commit -m "feat: create development-only edit button script

Extract inline JavaScript from _includes/edit-button.html
Uses data attributes to pass Liquid variables to JS
Opens MarkText for current markdown file"
```

---

## Task 6: Modifica edit-button.html per Usare Script Esterno

**Files:**
- Modify: `_includes/edit-button.html`

- [ ] **Step 1: Backup file corrente**

```bash
cp _includes/edit-button.html _includes/edit-button.html.backup
```

- [ ] **Step 2: Sostituisci contenuto file**

```bash
cat > _includes/edit-button.html << 'EOF'
{% if jekyll.environment == 'development' %}
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

<style>
  #edit-btn {
    position: fixed !important;
    top: 20px !important;
    right: 20px !important;
    z-index: 10000 !important;
  }
</style>

<button
  id="edit-btn"
  class="evento-edit-icon"
  onclick="window.editButtonOpenMarkText()"
  title="Modifica con MarkText">
  <i class="fas fa-edit"></i>
</button>

<script
  data-project-path="{{ site.project_path }}"
  data-page-path="{{ page.path }}"
  src="{{ site.baseurl }}/assets/js/edit-button-dev.js">
</script>
{% endif %}
EOF
```

- [ ] **Step 3: Verifica modifiche**

```bash
cat _includes/edit-button.html
# Expected: Vedi il nuovo file con <script src="...">
```

- [ ] **Step 4: Test in development**

```bash
# Avvia Jekyll in development
JEKYLL_ENV=development jekyll serve
# Expected: Server avviato, visita http://localhost:4000
# Verifica che il bottone edit appaia e funzioni
```

- [ ] **Step 5: Verifica production non include script**

```bash
# Build in production
JEKYLL_ENV=production jekyll build

# Cerca edit-button-dev.js nel sito generato
grep -r "edit-button-dev.js" _site/
# Expected: Nessuna occorrenza (escluso in production)
```

- [ ] **Step 6: Commit**

```bash
git add _includes/edit-button.html
git commit -m "refactor: use external JS for edit button

Replace inline script with external edit-button-dev.js
Pass Liquid variables via data attributes
Script only loads in development environment"
```

---

## Task 7: Aggiungi Make Target per Test Cleanup

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Trova sezione targets nel Makefile**

```bash
grep -n "^[a-z-]*:" Makefile | head -20
# Expected: Lista di tutti i target make
```

- [ ] **Step 2: Aggiungi target test-cleanup**

Aggiungi dopo i target esistenti:
```makefile
# Test: Verifica che inline CSS/JS siano stati rimossi
test-cleanup:
	@echo "Testing CSS/JS cleanup..."
	@echo "1. Checking for inline CSS styles..."
	@! grep -r 'style="color:' _site/index.html || { echo "❌ FAIL: Found inline color styles"; exit 1; }
	@echo "✅ PASS: No inline color styles in index.html"
	@echo "2. Checking for inline JavaScript..."
	@! grep -r '<script' _site/index.html | grep -v 'src=' | grep -v 'application/ld+json' || { echo "❌ FAIL: Found inline JavaScript"; exit 1; }
	@echo "✅ PASS: No inline JavaScript (except JSON-LD)"
	@echo "3. Checking edit-button-dev.js excluded from production..."
	@! grep -r 'edit-button-dev.js' _site/ || { echo "❌ FAIL: edit-button-dev.js found in production"; exit 1; }
	@echo "✅ PASS: edit-button-dev.js excluded from production"
	@echo ""
	@echo "✅ All cleanup tests passed!"
```

- [ ] **Step 3: Verifica target aggiunto**

```bash
grep -A 10 "test-cleanup:" Makefile
# Expected: Vedi il nuovo target
```

- [ ] **Step 4: Test target**

```bash
# Prima fai build
jekyll build

# Poi lancia test
make test-cleanup
# Expected: Tutti i test passano ✅
```

- [ ] **Step 5: Commit**

```bash
git add Makefile
git commit -m "test: add test-cleanup target

Add make target to verify CSS/JS cleanup:
- Check for inline color styles in index.html
- Check for inline JavaScript (except JSON-LD)
- Verify edit-button-dev.js excluded from production"
```

---

## Task 8: Test Completi Fase 1

**Files:**
- Test: `index.html`, `_site/index.html`

- [ ] **Step 1: Build sito completo**

```bash
jekyll build
# Expected: Build completato senza errori
```

- [ ] **Step 2: Verifica zero inline CSS**

```bash
grep -r 'style="color:' _site/index.html
# Expected: Nessuna occorrenza
```

- [ ] **Step 3: Verifica inline JavaScript legittimi**

```bash
grep '<script' _site/index.html
# Expected: Solo <script type="application/ld+json"> (JSON-LD schema)
```

- [ ] **Step 4: Esegui make test-cleanup**

```bash
make test-cleanup
# Expected: Tutti i test passano
```

- [ ] **Step 5: Verifica visual regression**

```bash
make validate-graphics
# Expected: Visual regression report mostra differenze minime (<1%)
# Se fallisce: https://github.com/user/repo/pull/123
```

- [ ] **Step 6: Start development server e test manuale**

```bash
jekyll serve
# Visit http://localhost:4000
# Verifica:
# 1. Le card hanno colori corretti (titoli verdi, descrizioni grigie)
# 2. Il bottone edit appare in development
# 3. Cliccando edit si apre MarkText
```

- [ ] **Step 7: Commit finale Fase 1**

```bash
git add .
git commit -m "test: complete Phase 1 CSS/JS cleanup testing

All tests passing:
✅ Zero inline CSS in index.html
✅ Zero inline JavaScript (except legitimate JSON-LD)
✅ Edit button dev-only excluded from production
✅ Visual regression tests passing
✅ Manual testing complete

Phase 1 complete. Ready for Phase 2: Collections Restructure."
```

---

## Testing Strategy Completa

### Automatic Tests
```bash
# 1. Build test
jekyll build

# 2. CSS cleanup test
grep -r 'style="color:' _site/index.html
# Expected: Empty output

# 3. JS cleanup test
grep '<script' _site/index.html | grep -v 'src=' | grep -v 'application/ld+json'
# Expected: Empty output

# 4. Make target test
make test-cleanup
# Expected: All tests passing ✅
```

### Manual Tests
```bash
# 1. Start server
jekyll serve

# 2. Visit homepage
# http://localhost:4000
# Verify: Card colors match original design

# 3. Check edit button (development only)
# Verify: Button appears, clicking opens MarkText

# 4. Build production
JEKYLL_ENV=production jekyll build
# Verify: edit-button-dev.js NOT in _site/
```

### Visual Regression
```bash
make validate-graphics
# Expected: Differences < 1%
# If fails: Review screenshots/report/index.html
```

---

## Next Steps

**Phase 1 Complete** ✅

Prossima fase:
- [ ] Fase 2: Collections Restructure → `2026-05-01-fase2-collections.md`
- [ ] Fase 3: ARIA + SEO + Images → `2026-05-01-fase3-accessibility.md`

---

**Piano**: 2026-05-01-fase1-cleanup.md
**Stato**: READY FOR IMPLEMENTATION
**Prerequisiti**: Nessuno
**Dipendenze**: Nessuna
