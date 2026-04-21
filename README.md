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

- **Jekyll 3** — Site generator statico
- **Docker** — Ambiente di sviluppo e build containerizzato
- **GitHub Actions** — CI/CD per deployment automatico
- **Custom Plugin** — `jekyll-pages-directory.rb` per gestione `_pages/`

### Features custom

- Layout `evento` per eventi con hero section, CTA, benefits grid
- Sezioni opzionali: highlights, programma, outcomes, FAQ
- Edit button (MarkText) visible solo in development
- Font Awesome icons
- Flexbox-responsive grid system
- Schema.org JSON-LD per SEO automatico

---

## Sviluppo locale

### Requisiti

- Docker (nessuna installazione Ruby locale necessaria)

### Quick start

```bash
make serve      # Avvia server su http://localhost:4000
make build      # Genera sito statico in _site/
make clean      # Rimuove _site/ e cache
make install    # Installa dipendenze bundle (Docker)
```

Per tutti i comandi disponibili: `make help`

---

## Struttura progetto

```
bitprepared.it/
├── _pages/          → Pagine statiche (eventi, software, articles)
│   ├── eventi/      → Eventi (campo_eg, epppi, stage)
│   │   └── README_EVENTO.md → Guida template evento
│   ├── software/    → Guide software (GIMP, LibreOffice, etc.)
│   └── about/       → Chi siamo
├── _posts/          → Blog posts (format: yyyy-mm-dd-titolo.md)
├── _layouts/        → Template Jekyll
│   ├── evento.html  → Layout standard per eventi (ex epppi)
│   ├── default.html
│   ├── page.html
│   └── post.html
├── _plugins/        → Plugin Jekyll custom
│   └── jekyll-pages-directory.rb
├── _includes/       → Componenti riutilizzabili (nav, footer, etc.)
├── assets/          → CSS, JS, images
│   └── css/
│       └── evento-custom.css → Stili template evento
├── _config.yml      → Configurazione Jekyll
├── Makefile         → Comandi sviluppo
└── .github/workflows/
    └── site-release.yml  → CI/CD deployment
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
- [docs/WORKFLOW.md](docs/WORKFLOW.md) - Guida workflow dettagliata
- [docs/CHECKLIST.md](docs/CHECKLIST.md) - Checklist rapida pre-commit
- [docs/VISUAL_REGRESSION_DOCS.md](docs/VISUAL_REGRESSION_DOCS.md) - Docs tecniche

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
3. Build: Jekyll in container Docker (`jekyll/builder:latest`)
4. Output: `release.zip` con directory `_site/` compilata
5. Release: Creata automaticamente con tag timestamp (YYYYMMDDTHHmmss)
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

- `_config.yml` — Configurazione principale
- `_config_dev.yml` — Override per development

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
