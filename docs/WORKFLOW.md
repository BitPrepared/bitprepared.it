# Workflow Sviluppo BitPrepared

## Overview

Questo documento descrive il workflow di sviluppo per BitPrepared.it, inclusa l'integrazione del sistema di **Visual Regression Testing**.

## Cos'è Visual Regression

Sistema automatizzato che verifica che il sito sia graficamente identico tra:
- **Jekyll dev server** (`make serve`, porta 4000)
- **Static server** (`make serve-static`, porta 8000)

Confronta **57 screenshots** (19 pagine × 3 viewports) pixel-by-pixel con tolleranza 1%.

## Quando Eseguire Visual Regression

### ✅ OBBLIGATORIO
- Prima di commit modifiche CSS/layout
- Prima di aprire PR per merge
- Dopo aggiunta nuove pagine
- Dopo modifica template Jekyll

### 🟡 CONSIGLIATO
- Prima di deploy in produzione
- Dopo aggiornamento dipendenze
- Dopo refactoring significativo

### ⚪ OPZIONALE
- Modifica contenuto testuale solo
- Fix bug non grafici
- Aggiornamento documentazione

## Scenari Comuni

### Scenario 1: Nuova Pagina

**Obiettivo**: Aggiungere nuova pagina al sito

```bash
# 1. Crea pagina file
echo "---\nlayout: page\ntitle: Nuova Pagina\n---\n\nContenuto" > _pages/nuova-pagina.md

# 2. Aggiungi a visual regression
# Edit: scripts/visual-regression/capture.js
# Aggiungi a const pages: ['/nuova-pagina/', ...]

# 3. Test locale
make serve
# Apri http://localhost:4000/nuova-pagina/

# 4. Crea baseline (server deve essere attivo)
make visual-baseline

# 5. Commit baseline
git add tests/visual-baseline/ scripts/visual-regression/capture.js
git commit -m "Add new page to visual regression baseline"

# 6. Commit pagina
git add _pages/nuova-pagina.md
git commit -m "Add new page: Nuova Pagina"
```

**Nota**: Baseline richiede `make serve` attivo in altro terminale.

---

### Scenario 2: Modifica Grafica/Layout

**Obiettivo**: Cambiare CSS o template Jekyll

```bash
# 1. Modifica CSS/layout
vim assets/css/style.css
# oppure
vim _layouts/default.html

# 2. Test locale
make serve
# Verifica modifiche in browser

# 3. Valida grafica (3 terminali)
# Terminal 1: make serve
# Terminal 2: make serve-static
# Terminal 3: make validate-graphics

# 4A. Se PASSED ✓
git add assets/css/style.css
git commit -m "Update style CSS"

# 4B. Se FAILED ✗
# Review report
xdg-open screenshots/report/index.html

# Due opzioni:
# Opzione A: Fix bug grafico
# Ripeti da step 1

# Opzione B: Differenze accettabili (new design)
make visual-baseline  # Aggiorna baseline
git add tests/visual-baseline/
git commit -m "Update baseline for new design"

# 5. Commit modifiche
git add assets/css/style.css
git commit -m "Implement new design"
```

**Importante**: Differenze > 1% causano fallimento.

---

### Scenario 3: Bug Fix Non Grafico

**Obiettivo**: Fix bug logico, no modifica grafica

```bash
# 1. Fix bug
vim _plugins/some-plugin.rb

# 2. Test locale
make serve
# Verifica fix

# 3. Valida (opzionale ma consigliato)
make validate-graphics
# Dovrebbe PASSARE (nessuna modifica grafica)

# 4. Commit
git add _plugins/some-plugin.rb
git commit -m "Fix bug in plugin"
```

---

### Scenario 4: Prima di Merge/PR

**Obiettivo**: Verificare tutto prima di integrare in main

```bash
# 1. Pull latest main
git checkout main
git pull origin main
git checkout feature-branch
git rebase main

# 2. Clean rebuild
make clean
make build

# 3. Visual regression completa (3 terminali)
# Terminal 1: make serve
# Terminal 2: make serve-static
# Terminal 3: make validate-graphics

# 4. Review report se fallito
xdg-open screenshots/report/index.html

# 5. Fix se necessario, poi ripeti da step 3

# 6. Push/merge
git push origin feature-branch
# Apri/aggiorna PR su GitHub
```

---

### Scenario 5: Nuovo Blog Post

**Obiettivo**: Generare blog post Jekyll da file evento

```bash
# 1. Genera blog post automatico
make generate-blog-post
# Prompt: _pages/eventi/epppi_rs.md
# Script eseguito in Docker (non richiede Ruby locale)

# 2. Personalizza contenuti
# Il file generato ha sezioni commentate da completare:
# - [DESCRIZIONE PERSONALIZZATA DA AGGIUNGERE QUI]
# - [INSERISCI QUOTA]
# - [INSERISCI DATA]

# 3. Verifica frontmatter
# Apri il file generato in _posts/
# Controlla titolo, descrizione, tags, permalink

# 4. Esegui git add e commit
git add _posts/2026-*.md
git commit -m "Add blog post: EPPPI 2026"

# 5. (Opzionale) Visual regression
# Se hai modificato template blog post
make validate-graphics
```

**Nota**: Lo script genera 80% automaticamente:
- ✅ Frontmatter completo
- ✅ Struttura Markdown
- ✅ Sezioni commented placeholder
- 📝 Tu aggiungi: descrizione personalizzata, quota, deadline

---

## Troubleshooting

### "Validazione fallita: differenze > 1%"

**Causa**: Modifiche grafiche superano tolleranza

**Soluzioni**:
1. **Bug grafico**: Fix CSS/layout, ripeti validate
2. **Design intenzionale**: Aggiorna baseline con `make visual-baseline`
3. **Anti-aliasing**: Se < 1.5%, considera accettabile

### "No baseline for X"

**Causa**: Baseline mancante per nuova pagina

**Soluzione**:
```bash
make visual-baseline
```

### "Cannot connect to server"

**Causa**: Server non attivo

**Soluzione**:
```bash
# Terminal 1
make serve

# Terminal 2
make serve-static

# Terminal 3
make validate-graphics
```

### Report troppo lungo

**Causa**: 57 test generano molto output

**Soluzione**: Filtra report per failures only
```bash
# Apri report HTML, usa filtro "Failures Only"
xdg-open screenshots/report/index.html
```

---

## Quick Reference

### Comandi Visual Regression

```bash
make docker-build-visual    # Build immagine Docker (prima volta)
make validate-graphics      # Valida grafica (richiede 2 server attivi)
make visual-baseline        # Crea/aggiorna baseline (richiede make serve)
make visual-clean          # Pulisci screenshot temp
make workflow              # Mostra questo documento
```

### Server per Testing

```bash
make serve                # Jekyll dev server (porta 4000)
make serve-static         # Python static server (porta 8000)
make build                # Build sito statico
make clean                # Pulisci _site/
```

### File Critici

- `scripts/visual-regression/capture.js` - Pagine da testare
- `tests/visual-baseline/` - Baseline images (git tracked)
- `screenshots/report/index.html` - Report HTML
- `WORKFLOW.md` - Questo documento
- `CHECKLIST.md` - Checklist rapida

---

## Best Practices

### DO ✅
- Esegui visual regression prima di ogni commit grafico
- Review diff images prima di aggiornare baseline
- Committa baseline insieme al codice
- Tieni documentazione aggiornata

### DON'T ❌
- Non skippare visual regression per modifiche CSS
- Non forzare merge se validation fallita
- Non committare baseline senza codice
- Non ignorare errori report

---

## Support

Per problemi o domande:

1. Controlla `docs/CHECKLIST.md` per checklist rapida
2. Leggi `docs/VISUAL_REGRESSION_DOCS.md` per dettagli tecnici
3. Usa `make help` per comandi disponibili
4. Review `screenshots/report/index.html` per debug

---

**Versione**: 1.0.0
**Aggiornamento**: 2026-04-21
**Autore**: BitPrepared Team
