# Visual Regression Testing

Validazione automatica grafica per sito BitPrepared.

## Scopo

Verifica che il sito sia graficamente identico tra:
- `make serve` (Jekyll dev server, porta 4000)
- `make serve-static` (Python static server, porta 8000)

## Setup Iniziale

```bash
cd scripts/visual-regression
npm install
```

## Creazione Baseline

Prima esecuzione: crea baseline images.

```bash
make visual-baseline
```

Commit baseline in git:

```bash
git add tests/visual-baseline/
git commit -m "Add visual baseline"
```

## Validazione

Esegui prima di ogni release:

```bash
make validate-graphics
```

**Output**:
- ✅ Se OK: `Validazione completata`
- ❌ Se differenze > 1%: `Validazione fallita` + report

**Report**: `screenshots/report/index.html`

## Workflow Release

```bash
# 1. Sviluppi feature
git checkout -b feature/new-layout

# 2. Valida graficamente
make validate-graphics

# 3. Se ci sono differenze:
# - Apri screenshots/report/index.html
# - Se differenze accettabili (fix bug):
make visual-baseline
git add tests/visual-baseline/
git commit -m "Update baseline after fix"

# - Se differenze bug:
# Fix codice e ripeti da step 2

# 4. Deploy
git push
```

## Viewports Testati

- **Desktop**: 1920×1080
- **Tablet**: 768×1024
- **Mobile**: 375×667

## Pagine Testate (19)

Critical:
- `/`
- `/eventi/epppi/`
- `/about/`
- `/software/`
- `/blog/`

Eventi:
- `/eventi/campo-eg/`
- `/eventi/stage/`

Software (10 pagine)

Altre:
- `/articles/`
- `/project/github/`

## Comandi

- `make validate-graphics` - Valida grafica
- `make visual-baseline` - Crea baseline
- `make visual-clean` - Rimuovi screenshot temp

## Troubleshooting

**Dipendenze non installate**:
```bash
cd scripts/visual-regression
npm install
```

**Baseline mancante**:
```bash
make visual-baseline
```

**Report non si apre**:
```bash
xdg-open screenshots/report/index.html
```
