# Guida Immagini Post ed Eventi

## Panoramica

Il sito BitPrepared usa un sistema automatico per selezionare le immagini giuste basandosi sul tipo di evento e sull'ambientazione. Questa guida spiega come creare, ottimizzare e gestire le immagini per il sito.

## Percorsi dei File

**Importante:** Ci sono due tipi di percorsi da conoscere:

1. **Percorso sorgente** (dove lavori): `src/jekyll/assets/images/`
   - Qui crei e modifichi i file
   - Esempio: `src/jekyll/assets/images/epppi/locandina_epppi_2026.jpg`

2. **Percorso pubblicato** (nel sito): `/assets/images/`
   - Questo è il percorso che Jekyll usa nel sito generato
   - Non includere `src/jekyll/` nel frontmatter

**Esempio:**
- File nel filesystem: `src/jekyll/assets/images/epppi/locandina_epppi_2026.jpg`
- Nel frontmatter evento: `image: /assets/images/epppi/locandina_epppi_2026.jpg`

## Struttura Matrici Organizzata

Il sistema matrici è ora organizzato in 3 sottodirectory:

### production/
Immagini usate dal sito, ottimizzate per produzione
- `eventi/` - Locandine e featured per eventi
- `software/` - Loghi software
- `loghi-branche/` - Loghi EG/RS/Capi
- `root/` - Immagini root (generic-featured, agesci-logo, placeholders)

### source-icons/
Sorgenti uniche che generano multiple varianti
- `site-icon.svg` - Genera favicon.ico, apple-touch-icon*.png, manifest.json

### supporto/
Archivio, non copiato in assets
- `mockup/` - Mockup design
- `strumenti/` - File di lavoro
- `risorse/` - Risorse varie

## File Manifesto

### .locked
File che non devono essere modificati:
- generic-featured.png
- agesci_logo.png
- placeholder-blog.png
- placeholder-news.png

### .rules
Regole conversioni per categoria. Vedi design document per dettagli completi.

## Archivio Originali (Matrici)

**Importante:** I file originali (PNG) sono archiviati in `src/matrici/images/`, non in `src/jekyll/assets/images/`.

**Percorsi:**
- **Originali (PNG)**: `src/matrici/images/` - archivio, non pubblicato
- **Ottimizzati (JPG)**: `src/jekyll/assets/images/` - pubblicato nel sito
- **Eccezioni**: favicon.png, logo.png restano in `src/jekyll/assets/images/` (grafica piccola)

**Flusso lavoro:**
1. Salva originale PNG in `src/matrici/images/`
2. Esegui `make optimize-images` per generare JPG in `src/jekyll/assets/images/`
3. Jekyll pubblica solo JPG ottimizzati

**Esempio:**
- File originale: `src/matrici/images/epppi/locandina_epppi_2026.png`
- File ottimizzato: `src/jekyll/assets/images/epppi/locandina_epppi_2026.jpg`
- Nel frontmatter: `image: /assets/images/epppi/locandina_epppi_2026.jpg`

## Tipi di Immagini

### 1. Volantini Eventi (Locandine)

Usati per: Pagine evento (`_eventi/*.md`)

**Specifiche:**
- **Dimensioni**: 3508 × 4961 pixel (A3 verticale @ 300 DPI)
- **Formato**: JPG, qualità 85%
- **Peso massimo**: 500 KB
- **Colori**: RGB, profilo sRGB
- **Nome file**: `locandina_{tipo}_{anno}.jpg`
- **Posizione**: `/assets/images/{tipo}/`

**Esempi:**
```
/assets/images/epppi/locandina_epppi_2026.jpg
/assets/images/campo-eg/locandina_campo-eg_2026.jpg
/assets/images/stage/locandina_stage_2026.jpg
```

**Come funziona:**
1. Nel frontmatter dell'evento specifichi `event_type: epppi` e `year: 2026`
2. Jekyll automaticamente usa `/assets/images/epppi/locandina_epppi_2026.jpg`
3. Se vuoi usare un'immagine diversa, aggiungi `image: /percorso/custom.jpg`

**Esempio frontmatter:**
```yaml
---
layout: evento
event_type: epppi
year: 2026
title: Essere solidi in una società immateriale
---
```

---

### 2. Immagini Featured Post

Usate per: Post del blog (`_posts/*.md`)

**Specifiche:**
- **Dimensioni**: 1200 × 630 pixel (rapporto 16:9)
- **Formato**: JPG qualità 85% o WebP
- **Peso massimo**: 200 KB
- **Colori**: RGB, profilo sRGB
- **Nome file**: `{tipo}-{ambientazione}-featured.jpg`
- **Posizione**: `/assets/images/{tipo}/`

**Esempi:**
```
/assets/images/epppi/epppi-star-wars-featured.jpg
/assets/images/campo-eg/campo-eg-momo-featured.jpg
/assets/images/stage/stage-monkey-island-featured.jpg
```

**Come funziona:**
1. Nel frontmatter del post specifichi `event_type: epppi` e `ambientazione: star-wars`
2. Jekyll automaticamente usa `/assets/images/epppi/epppi-star-wars-featured.jpg`
3. Se vuoi usare un'immagine diversa, aggiungi `featured: /percorso/custom.jpg`

**Esempio frontmatter:**
```yaml
---
layout: post
title: Il nostro campo EPPPI
event_type: epppi
ambientazione: star-wars
---
```

---

### 3. Immagine Generica

Usata per: Post senza evento

**Specifiche:**
- **Dimensioni**: 1200 × 630 pixel (16:9)
- **Formato**: PNG
- **Peso massimo**: 300 KB
- **Nome file**: `generic-featured.png`
- **Posizione**: `/assets/images/`

**Come funziona:**
- Se il post NON ha `event_type` e `ambientazione`, usa automaticamente questa immagine
- Puoi fare override con `featured: /percorso/custom.jpg`

**Esempio frontmatter:**
```yaml
---
layout: post
title: Annuncio generale
# Nessun event_type o ambientazione
# Usa automaticamente generic-featured.png
---
```

---

## Creare Nuove Immagini

### Metodo 1: Usare il sistema di ottimizzazione automatico

Il sistema ottimizza automaticamente le immagini durante il build:

```bash
# 1. Crea la cartella se non esiste
mkdir -p src/matrici/images/epppi/

# 2. Metti la tua immagine PNG nella cartella giusta
cp mia-immagine.png src/matrici/images/epppi/

# 3. Run build (ottimizza automaticamente)
make optimize-images
```

L'immagine verrà:
- Letta da `src/matrici/images/epppi/mia-immagine.png`
- Ottimizzata e salvata in `src/jekyll/assets/images/epppi/mia-immagine.jpg`
- Pubblicata nel sito

**Nota**: Questo metodo richiede che il file sia già nominato correttamente.

### Metodo 2: Ottimizzare manualmente con ImageMagick

```bash
# Installa ImageMagick (se non già installato)
sudo apt-get install imagemagick

# Ottimizza volantino (A3 @ 300DPI)
convert input.jpg -resize 3508x4961 -quality 85 output.jpg

# Ottimizza featured post (16:9)
convert input.jpg -resize 1200x630 -quality 85 output.jpg
```

### Metodo 3: Usare il comando Makefile

```bash
# Ottimizza tutte le immagini
make optimize-images

# Questo comando:
# - Ottimizza i volantini (A3 @ 300DPI, JPG 85%, max 500KB)
# - Ottimizza le featured (16:9, JPG 85%, max 200KB)
# - Ottimizza la generica (16:9, mantiene PNG, max 300KB)
```

---

## Generare Placeholder

Quando crei un nuovo evento o combinazione evento+ambientazione:

```bash
# Genera tutti i placeholder mancanti
make generate-placeholders
```

Questo crea placeholder 1×1px con metadata. Il CI bloccherà il deployment finché non sostituisci i placeholder con immagini reali.

**Esempio:**
```bash
$ make generate-placeholders
🖼️ Generazione placeholder...

✅ Created: src/jekyll/assets/images/epppi/locandina_epppi_2027.jpg
✅ Created: src/jekyll/assets/images/epppi/epppi-momo-featured.jpg

⚠️  Replace placeholders with real images before deploying
```

---

## Verificare Specifiche

Prima di fare commit:

```bash
# Verifica assenza placeholder
make check-placeholders

# Verifica dimensioni e peso
node scripts/validate-image-specs.js
```

**Esempio output:**
```bash
$ make check-placeholders
🔍 Verifico placeholder...
✅ Nessun placeholder trovato

$ node scripts/validate-image-specs.js
🔍 Validating image specifications...
✅ All images meet specifications
```

---

## Eventi e Ambientazioni Disponibili

### Tipi Evento (`event_type`)

- `epppi` - Esperienza Permanente di Progetto e Innovazione
- `campo-eg` - Campo Esploratori/Guide
- `stage` - Stage per Capi

### Ambientazioni (`ambientazione`)

- `star-wars` - Guerre Stellari
- `star-trek` - Star Trek
- `monkey-island` - Monkey Island
- `momo` - Momo

---

## Workflow Completo

### Per un nuovo evento:

1. **Crea il file evento** in `_eventi/nome-evento.md`
2. **Aggiungi il frontmatter** con `event_type` e `year`
3. **Genera il placeholder**:
   ```bash
   make generate-placeholders
   ```
4. **Crea la locandina**:
   - Dimensioni: 3508×4961 pixel (A3 @ 300DPI)
   - Salva come `/assets/images/{tipo}/locandina_{tipo}_{anno}.jpg`
5. **Verifica**:
   ```bash
   make check-placeholders
   node scripts/validate-image-specs.js
   ```

### Per un nuovo post con evento:

1. **Crea il file post** in `_posts/YYYY-MM-DD-titolo.md`
2. **Aggiungi il frontmatter** con `event_type` e `ambientazione`
3. **Genera il placeholder** (se necessario):
   ```bash
   make generate-placeholders
   ```
4. **Crea l'immagine featured**:
   - Dimensioni: 1200×630 pixel (16:9)
   - Salva come `/assets/images/{tipo}/{tipo}-{ambientazione}-featured.jpg`
5. **Verifica**:
   ```bash
   make check-placeholders
   node scripts/validate-image-specs.js
   ```

### Per un post generico:

1. **Crea il file post** in `_posts/YYYY-MM-DD-titolo.md`
2. **Non aggiungere** `event_type` o `ambientazione`
3. **Il sistema userà automaticamente** `generic-featured.png`
4. **Per usare un'immagine personalizzata**, aggiungi `featured: /percorso/custom.jpg`

---

## Troubleshooting

### L'immagine non appare

**Problema:** L'immagine calcolata non esiste

**Soluzione:**
1. Verifica che il file esista nel percorso giusto
2. Verifica il nome file corretto (minuscolo, trattini, no spazi)
3. Se non esiste, il sistema usa automaticamente `generic-featured.png`

**Debug:**
```bash
# Controlla quale immagine sta usando il sito
grep -r "event_type" src/jekyll/_posts/*.md
ls -la src/jekyll/assets/images/epppi/
```

### CI blocca il deployment

**Problema:** Placeholder trovati

**Soluzione:**
1. Leggi il log CI per vedere quali file sono placeholder
2. Sostituiscili con immagini reali
3. Assicurati che dimensioni e peso siano corretti

**Verifica locale:**
```bash
make check-placeholders
```

### Immagine troppo pesante

**Problema:** File size validation fallisce

**Soluzione:**
```bash
# Ottimizza con Makefile
make optimize-images

# O manualmente con ImageMagick
convert input.jpg -resize 1200x630 -quality 85 output.jpg
```

### ImageMagick non trovato

**Problema:** Il comando `magick` o `convert` non esiste

**Soluzione:**
```bash
# Installa ImageMagick
sudo apt-get install imagemagick

# Verifica l'installazione
convert --version
```

### Dimensioni errate

**Problema:** L'immagine ha dimensioni sbagliate

**Soluzione:**
```bash
# Verifica dimensioni attuali
identify input.jpg

# Ridimensiona correttamente
convert input.jpg -resize 3508x4961! -quality 85 output.jpg
# Il ! forza le dimensioni esatte senza mantenere aspect ratio
```

---

## Strumenti Utili

### Makefile

```bash
make help                    # Mostra tutti i comandi disponibili
make generate-placeholders   # Genera placeholder mancanti
make check-placeholders      # Verifica assenza placeholder
make optimize-images         # Ottimizza tutte le immagini
make build                   # Build del sito (ottimizza immagini)
```

### Script di validazione

```bash
# Valida specifiche immagini
node scripts/validate-image-specs.js

# Controlla placeholder
node scripts/check-image-placeholders.js
```

### Informazioni immagine

```bash
# Mostra dimensioni e metadata
identify immagine.jpg

# Mostra informazioni dettagliate
identify -verbose immagine.jpg

# Mostra dimensioni in pixel
identify -format "%w x %h\n" immagine.jpg
```

---

## Best Practices

1. **Usa sempre i placeholder** quando crei nuovi eventi/ambientazioni
2. **Verifica sempre** con `make check-placeholders` prima di commit
3. **Ottimizza le immagini** per mantenere il sito veloce
4. **Usa formati appropriati**: JPG per foto, PNG per grafica, WebP per web
5. **Mantieni la consistenza** nei nomi dei file (minuscolo, trattini)
6. **Testa localmente** prima di deployare
7. **Commit solo immagini validate** (usa lo script di validazione)

---

## Riferimenti

- **Design document:** `docs/superpowers/specs/2026-05-04-image-management-design.md`
- **Implementation plan:** `docs/superpowers/plans/2026-05-04-image-management.md`
- **Makefile:** `make help` per tutti i comandi disponibili
- **Scripts:** `scripts/` directory per script di utilità

---

## Supporto

Per problemi o domande:
1. Controlla questa guida
2. Verifica il design document
3. Usa i comandi di troubleshooting sopra
4. Contatta il team tecnico se il problema persiste
