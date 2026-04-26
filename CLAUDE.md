# BitPrepared.it - Memoria Persistente per Claude

## Visual Regression - Quando Ricordare

**Trigger principali**:
- Utente aggiunge nuove pagine
- Utente modifica CSS/layout
- Utente modifica template Jekyll
- Utente apre PR per merge

**Domande standard**:
- "Hai eseguito make validate-graphics?"
- "Vuoi aggiornare la baseline con make visual-baseline?"
- "Vuoi revieware il report in screenshots/report/index.html?"

**Quando NON ricordare**:
- Modifica contenuto testuale solo
- Fix bug logici non grafici
- Aggiornamento documentazione

## Pattern Progetto

### Layout Eventi
- Layout: `_layouts/evento.html` (NON `_layouts/epppi.html`)
- Classi CSS: `.evento-*` (NON `.epppi-*`)
- CSS: `assets/css/evento-custom.css`

### Struttura File
- Pagine: `_pages/*.md` o `*.html`
- Blog: `_posts/YYYY-MM-DD-titolo.md`
- Template: `_layouts/*.html` (default, page, post, evento)
- Assets: `assets/css/*.css`, `assets/js/*`

### Frontmatter Jekyll
```yaml
---
layout: page
title: Titolo Pagina
---
```

### JavaScript e Liquid Variables
**IMPORTANTE**: JavaScript che usa variabili Liquid (`{% for %}`, `{{ variable }}`) deve stare **inline** nei file HTML/Markdown, NON in file `.js` esterni.

**Perché**: Jekyll non processa i file `.js` - li tratta come asset statici.

**Esempio**: `tags/index.md` ha JS inline perché genera dati da `site.tags` con loop Liquid. Se sposti JS in file esterno, le variabili Liquid non vengono processate e il codice si rompe.

## File Critici da Aggiornare

Quando utente aggiunge/modifica features:

- **`scripts/visual-regression/capture.js`**
  - Aggiungi nuove pagine all'array `const pages`
  - Esempio: `const pages = [..., '/nuova-pagina/']`

- **`tests/visual-baseline/`**
  - Committa baseline quando aggiornata
  - Diviso in `desktop/`, `mobile/`, `tablet/`

- **`docs/CHECKLIST.md`**
  - Riferimento per workflow completo
  - Consulta per scenari nuovi

## Query Standard

### "Sto aggiungendo una nuova pagina"
```bash
# Ricorda di dire:
1. Aggiungi URL a scripts/visual-regression/capture.js (const pages array)
2. Esegui make visual-baseline (make serve deve essere attivo)
3. Committa tests/visual-baseline/
```

### "Ho modificato il CSS"
```bash
# Ricorda di dire:
1. Esegui make validate-graphics (richiede 3 terminali: serve, serve-static, validate)
2. Review screenshots/report/index.html se fallisce
3. Fix bug grafici OR aggiorna baseline con make visual-baseline
```

### "Prima di fare il commit"
```bash
# Ricorda di chiedere:
1. Hai eseguito make validate-graphics?
2. Il report è ok (sotto 1% differenze)?
3. Hai aggiornato la baseline se necessario?
4. Hai verificato i link con make check-links?
```

### "Verifica link broken"
```bash
# Ricorda di suggerire:
make check-links
# Verifica tutti i link (interni ed esterni) nel sito generato
# Esclude automaticamente social media e localhost
```

### "Sto modificando un template Jekyll"
```bash
# Ricorda di dire:
1. Esegui make validate-graphics dopo modifiche
2. Controlla che tutte le pagine con quel template siano ok
3. Aggiorna baseline se modifiche grafiche accettabili
```

## Riferimenti

Per dettagli completi:
- **Workflow**: `docs/WORKFLOW.md`
- **Checklist**: `docs/CHECKLIST.md`
- **Docs tecnici**: `docs/VISUAL_REGRESSION_DOCS.md`
- **Comandi**: `make help`

---

**Versione**: 2.0.0 (semplificato)
**Focus**: Operativo per implementazione features
**Ultimo aggiornamento**: 2026-04-21
