# Visual Regression Testing

Validazione automatica grafica per sito BitPrepared.

## Scopo

Verifica che il sito sia graficamente identico tra:
- `make serve` (Jekyll dev server, porta 4000)
- `make serve-static` (Python static server, porta 8000)

## Requisiti

**Docker obbligatorio** per `make validate-graphics`

```bash
# Verifica Docker installato
docker --version
```

## Setup Iniziale

```bash
# Build immagine Docker (prima volta solo)
make docker-build-visual
```

## Creazione Baseline

Prima esecuzione: crea baseline images.

```bash
# Terminal 1: avvia server
make serve

# Terminal 2: crea baseline (Docker)
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
# Terminal 1: avvia Jekyll server
make serve

# Terminal 2: avvia static server
make serve-static

# Terminal 3: valida (Docker)
make validate-graphics
```

**Output**:
- ✅ Se OK: `Visual regression PASSED`
- ❌ Se differenze > 1%: `Visual regression FAILED` + report

**Report**: `output/screenshots/report/index.html`

## Workflow Release

```bash
# 1. Sviluppi feature
git checkout -b feature/new-layout

# 2. Valida graficamente (3 terminali)
# Terminal 1:
make serve
# Terminal 2:
make serve-static
# Terminal 3:
make validate-graphics

# 3. Se ci sono differenze:
# - Apri output/screenshots/report/index.html
# - Se differenze accettabili (fix bug):
# Terminal 1: make serve (se non già attivo)
# Terminal 2: make visual-baseline
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

- `make validate-graphics` - Valida grafica in Docker
- `make visual-baseline` - Crea baseline (richiede make serve attivo)
- `make visual-clean` - Rimuovi screenshot temp
- `make docker-build-visual` - Build immagine Docker

## Troubleshooting

**Docker non installato**:
```bash
# Ubuntu/Debian
sudo apt-get install docker.io

# Avvia Docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

**Build Docker fallita**:
```bash
# Verifica connessione internet
ping google.com

# Rebuild pulito
make docker-build-visual
```

**make visual-baseline fallisce**:
```bash
# Assicurati che make serve sia attivo in altro terminale
make serve  # Terminal 1
make visual-baseline  # Terminal 2
```

**Baseline mancante**:
```bash
make visual-baseline
```

**Report non si apre**:
```bash
xdg-open output/screenshots/report/index.html
```

**Container non parte**:
```bash
# Verifica porte libere
netstat -tuln | grep -E '4000|8000'

# Kill processi sulle porte
sudo lsof -ti:4000 | xargs kill -9
sudo lsof -ti:8000 | xargs kill -9
```
