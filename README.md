# Bit Prepared

**Digito ergo sum** — Per un uso consapevole del digitale

[www.bitprepared.it](https://www.bitprepared.it)

---

## Cos'è Bit Prepared

Bit Prepared è un gruppo di soci **AGESCI** (Associazione Guide e Scout Cattolici Italiani) e non che promuove l'educazione digitale consapevole nelle comunità scout.

### Mission

Accompagnare gli scout nell'era digitale attraverso:

- Competenze tecnologic​he (Maestro delle Tecnologie, Esperto del Computer, Digital Life)
- Riflessione etica sull'uso del digitale
- Formazione sul campo (campi EG, EPPPI, stage)

### Eventi principali

- **Campo EG**: Campo di competenza per Esploratori/Guide (digital life, fotoritocco, video editing, coding, ... )
- **EPPPI**: Workshop intensivi per Rover/Scolte ( "Esseri solidi in una società immateriale")
- **Stage per Capi**: Formazione su scoutismo e Web 2.0

---

## Tech Stack

- **Jekyll 4** — Site generator statico
- **Docker** — Ambiente di sviluppo e build containerizzato
- **GitHub Actions** — CI/CD per deployment automatico

### Features custom

- Struttura Jekyll 4 standard (pages, posts, collections)
- Layout `evento` per eventi con hero section, CTA, benefits grid
- Collections custom: `eventi`, `software`
- Sezioni opzionali: highlights, programma, outcomes, FAQ
- Edit button (MarkText) visible solo in development
- Font Awesome icons
- Flexbox-responsive grid system
- Schema.org JSON-LD per SEO automatico

---

## Sviluppo locale

### Requisiti

- Docker (nessuna installazione Ruby/Node locale necessaria)

### Quick start

```bash
make serve      # Avvia server su http://localhost:4000
make build      # Genera sito statico in output/_site/
make clean      # Rimuove output/_site/ e cache
make install    # Installa dipendenze (Docker)
```

Per tutti i comandi disponibili: `make help`

---

## Struttura progetto

```
bitprepared.it/
├── src/                    → Source code
│   ├── jekyll/            → Jekyll site source
│   │   ├── _posts/        → Blog posts (yyyy-mm-dd-titolo.md)
│   │   ├── _eventi/       → Collection eventi (campo_eg, epppi, stage)
│   │   ├── _software/     → Collection software (GIMP, LibreOffice, etc.)
│   │   ├── _layouts/      → Template Jekyll
│   │   ├── _includes/     → Componenti riutilizzabili
│   │   ├── assets/        → CSS, JS, images
│   │   ├── _config.yml    → Configurazione Jekyll
│   │   └── _config_dev.yml → Override development
│   ├── tailwind/          → Tailwind CSS configuration
│   └── docker/            → Docker configuration files
├── output/                → Generated content (non in git)
│   ├── _site/            → Jekyll build output
│   └── screenshots/      → Visual regression screenshots
├── scripts/               → Utility scripts
│   └── visual-regression/ → Screenshot capture & comparison
├── tests/                 → Tests & baselines
│   └── visual-baseline/   → Screenshot baselines by version
├── docs/                  → Project documentation
│   ├── WORKFLOW.md       → Development workflow guide
│   ├── CHECKLIST.md      → Pre-commit checklist
│   └── VISUAL_REGRESSION_DOCS.md → Technical docs
├── Makefile               → Development commands
└── .github/workflows/     → CI/CD pipelines
```

---

## Workflow Sviluppo

### Visual Regression Testing ⚠️ IMPORTANTE

Il progetto usa **Visual Regression Testing** automatico. Prima di commit di modifiche grafiche:

```bash
# 1. Avvia server (2 terminali)
make serve           # Terminal 1: Jekyll (porta 4000)
make serve-static    # Terminal 2: Python (porta 8000)

# 2. Valida grafica (Terminal 3)
make validate-graphics

# 3. Se fallisce:
#    - Review: xdg-open screenshots/report/index.html
#    - Fix bug OR aggiorna baseline: make visual-baseline
```

**Quando eseguire**:
- ✅ Modifiche CSS/layout
- ✅ Nuove pagine
- ✅ Modifiche template Jekyll
- ⚪ Modifiche contenuto testuale (opzionale)

**Documentazione completa**:
- [WORKFLOW.md](docs/WORKFLOW.md) - Guida workflow dettagliata
- [CHECKLIST.md](docs/CHECKLIST.md) - Checklist rapida pre-commit
- [VISUAL_REGRESSION_DOCS.md](docs/VISUAL_REGRESSION_DOCS.md) - Docs tecniche

### Comandi Utili

```bash
make workflow          # Mostra guida workflow
make help              # Tutti i comandi disponibili
```

---

## Deployment

Il deployment è automatico tramite **GitHub Actions**:

1. Trigger: Merge di una PR sul branch `master`
2. Workflow: `.github/workflows/site-release.yml`
3. Build: Jekyll in container Docker (`jekyll/jekyll:4`)
4. Output: `release.zip` con directory `output/_site/` compilata
5. Release: Creata automaticamente con tag semver (v1.2.3, v1.3.0, etc.)
6. Changelog: `CHANGELOG.txt` usato come release body

---

## Configurazione

### Environment

- **Development**: `JEKYLL_ENV=development` (default per `make serve`)
  - Edit button visibile
  - Live reload attivo
- **Production**: `JEKYLL_ENV=production` (per `make build`)
  - Ottimizzazioni attive
  - Edit button nascosto

### File config

- `src/jekyll/_config.yml` — Configurazione principale
- `src/jekyll/_config_dev.yml` — Override per development

---

## Contribuire

1. Forka il repository
2. Crea branch feature (`git checkout -b feature/nova-feature`)
3. Commit changes (`git commit -m 'Aggiungo nova feature'`)
4. Push al branch (`git push origin feature/nova-feature`)
5. Apri Pull Request verso `master`

Al merge della PR, il sito sarà automaticamente buildato e rilasciato.

---

## Licenza

[Creative Commons Attribution 3.0 Unported](LICENSE.txt)

---

## Contatti

- **Email**: info@bitprepared.it
- **Web**: www.bitprepared.it
- **Twitter**: [@bitprepared](https://twitter.com/bitprepared)
