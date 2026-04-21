# BitPrepared.it - Memoria Persistente per Claude

## Panorama Progetto

**Tipo**: Sito statico Jekyll per associazione scout BitPrepared
**Stack**: Jekyll 3, Docker, GitHub Actions, Visual Regression (Playwright)
**Linguaggio**: Italiano
**Owner**: Stefano Tamagnini (yoghi)

## Sistema Visual Regression

### Cos'è
Sistema automatizzato di testing grafico che compara:
- Jekyll dev server (porta 4000)
- Static Python server (porta 8000)

### Tecnologia
- **Screenshot**: Playwright (Chromium headless)
- **Confronto**: pixelmatch (pixel-by-pixel)
- **Container**: Docker con Playwright v1.59.1
- **Test**: 57 screenshot (19 pagine × 3 viewports)
- **Threshold**: 1% differenza pixel

### Comandi Chiave
```bash
make docker-build-visual    # Build immagine Docker
make validate-graphics      # Valida grafica (Docker, richiede 2 server)
make visual-baseline        # Crea baseline (Docker, richiede make serve)
make visual-clean          # Pulisci temp
```

### Quando Ricordare All'Utente

**✅ RICORDA SEMPRE** quando utente:
1. Aggiunge nuove pagine
2. Modifica CSS/layout
3. Modifica template Jekyll (_layouts/)
4. Modifica file in assets/css/
5. Apre PR per merge

**🟢 CHIEDI**:
- "Hai eseguito make validate-graphics?"
- "Vuoi aggiornare la baseline con make visual-baseline?"
- "Vuoi revieware il report in screenshots/report/index.html?"

**❌ NON RICORDARE** per:
- Modifica contenuto testuale solo
- Fix bug logici non grafici
- Aggiornamento documentazione

### File Critici Visual Regression

- **`scripts/visual-regression/capture.js`**
  - Contiene array `const pages` con URL da testare
  - Se utente aggiunge pagina, RICORDA di aggiornare questo file
  - Aggiungi nuovo URL: `const pages = [..., '/nuova-pagina/']`

- **`tests/visual-baseline/`**
  - Contiene baseline images per tutti i test
  - Diviso in `desktop/`, `mobile/`, `tablet/`
  - Git tracked - committare quando aggiornato

- **`screenshots/report/index.html`**
  - Report HTML generato dopo ogni validate-graphics
  - Mostra differenze pixel-by-pixel
  - Strumento principale per debug grafico

## Struttura Progetto

```
bitprepared.it/
├── _pages/              # Pagine statiche (eventi, software, about)
├── _posts/              # Blog posts
├── _layouts/            # Template Jekyll (default.html, evento.html)
├── assets/css/          # Fogli stile (style.css, evento-custom.css)
├── scripts/visual-regression/  # Sistema visual regression
├── tests/visual-baseline/      # Baseline images
└── Makefile             # Comandi sviluppo
```

## Workflow Sviluppo Standard

### 1. Nuova Feature
```bash
git checkout -b feature/new-feature
# Sviluppo feature
make validate-graphics  # RICORDATI
git commit
```

### 2. Modifica Grafica
```bash
# Modifica CSS
make validate-graphics  # RICORDATI
# Se fail → review screenshots/report/index.html
# Se bug → fix, ripeti
# Se ok → make visual-baseline, commit baseline
git commit
```

### 3. Prima di Merge
```bash
git rebase main
make validate-graphics  # RICORDATI
git push
```

## Pagina da Testare (19)

**Critical**:
- `/` Homepage
- `/eventi/epppi/` Layout evento speciale
- `/about/`
- `/software/`
- `/blog/`

**Eventi**:
- `/eventi/campo-eg/`
- `/eventi/stage/`

**Software** (10 pagine):
- `/software/libreoffice/`
- `/software/gimp/`
- `/software/qgis/`
- `/software/mayalinux/`
- `/software/vlc/`
- `/software/wordpress/`
- `/software/flora/`
- `/software/code/`
- `/software/prbm/`

**Altro**:
- `/articles/`
- `/project/github/`

## Viewports

- **Desktop**: 1920×1080
- **Tablet**: 768×1024
- **Mobile**: 375×667

## Troubleshooting Comune

### Utente: "validate-graphics fallisce"
**Risposta**:
1. Controlla che `make serve` e `make serve-static` siano attivi
2. Review `screenshots/report/index.html`
3. Se bug grafico → fix
4. Se nuovo design ok → `make visual-baseline`

### Utente: "Nuova pagina non compare nei test"
**Risposta**:
Aggiorna `scripts/visual-regression/capture.js`:
```javascript
const pages = [
  '/',
  '/nuova-pagina/',  // Aggiungi qui
  // ...
];
```

Poi esegui `make visual-baseline`.

### Utente: "Docker non parte"
**Risposta**:
Verifica Docker installato e attivo:
```bash
docker --version
docker ps
```

## Comandi Make Utili

```bash
make help              # Mostra tutti i comandi
make serve             # Jekyll server (porta 4000)
make serve-static      # Python static server (porta 8000)
make build             # Build sito statico
make clean             # Pulisci _site/
make workflow          # Mostra WORKFLOW.md
```

## Pattern da Notare

### Layout Eventi
- Layout speciale: `_layouts/evento.html`
- Classi CSS: `.evento-*` (NON `.epppi-*`)
- CSS file: `assets/css/evento-custom.css`

### CSS Organization
- Main CSS: `assets/css/style.css`
- Event CSS: `assets/css/evento-custom.css`
- Responsive: `assets/css/style-*.css`

### Frontmatter Jekyll
```yaml
---
layout: page
title: Titolo Pagina
---
```

## Note Importanti

### Visual Regression
- **Non automatica**: Utente deve eseguirla manualmente
- **Docker based**: Tutto gira in container
- **Server host**: Container si connette a server sull'host machine
- **3 terminali**: serve (T1), serve-static (T2), validate (T3)

### Jekyll
- **Versione**: 3.x (vecchia, non aggiornare)
- **Plugins**: Custom in `_plugins/`
- **Config**: `_config.yml` e `_config_dev.yml`

### Docker
- **Immagine**: `mcr.microsoft.com/playwright:v1.59.1-jammy`
- **Container name**: `bitprepared-visual-regression:latest`
- **Network**: `--add-host=host.docker.internal:host-gateway`

## Riferimenti

- **Workflow completo**: `WORKFLOW.md`
- **Checklist rapida**: `CHECKLIST.md`
- **Documentazione visual regression**: `VISUAL_REGRESSION_DOCS.md`
- **README progetto**: `README.md`

## Query Comuni per Claude

### "Sto aggiungendo una nuova pagina"
```bash
# Ricorda di dire:
1. Aggiungi a scripts/visual-regression/capture.js
2. Esegui make visual-baseline (con make serve attivo)
3. Committa tests/visual-baseline/
```

### "Ho modificato il CSS"
```bash
# Ricorda di dire:
1. Esegui make validate-graphics (3 terminali)
2. Review screenshots/report/index.html
3. Fix OR make visual-baseline
```

### "Prima di fare il commit"
```bash
# Ricorda di chiedere:
1. Hai eseguito make validate-graphics?
2. Il report è ok?
3. Hai aggiornato la baseline se necessario?
```

---

**Versione**: 1.0.0
**Ultimo aggiornamento**: 2026-04-21
**Maintainer**: Claude AI + Stefano Tamagnini
