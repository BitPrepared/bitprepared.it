# Image Management System - Design Document

**Data**: 2026-05-04
**Status**: Approved
**Autore**: Claude + User brainstorming

## Obiettivo

Sistema completo per gestione immagini post ed eventi BitPrepared:

1. **Immagini post**: basate su tipo evento + ambientazione (es: `epppi` + `star-wars`)
2. **Immagini generiche**: per post senza evento
3. **Volantini eventi**: per ogni tipo + anno
4. **Override manuale**: sempre possibile nel frontmatter
5. **Placeholder generati**: bloccano deployment se non sostituiti
6. **Ottimizzazione automatica**: dimensioni e peso corretti

## Architettura

Sistema diviso in 3 parti:

1. **Frontmatter (dati)**: Post/eventi dichiarano `event_type` e `ambientazione`
2. **Liquid (logica view)**: Layout scelgono immagine giusta con fallback
3. **Script Node (automazione)**: Generano placeholder + verificano CI

```
Autore crea post → Aggiunge frontmatter → Layout Liquid usa regole → Sceglie immagine
                                              ↓
                                        Override manuale possible
```

### File Modificati

- `src/jekyll/_layouts/post.html` - logica immagine post
- `src/jekyll/_layouts/evento.html` - logica volantino
- `Makefile` - target ottimizzazione immagini
- `.github/workflows/validate-pr.yml` - check placeholder

### File Nuovi

- `src/jekyll/_data/eventi.yaml` - config tipi evento
- `src/jekyll/_data/ambientazioni.yaml` - config ambientazioni
- `src/jekyll/assets/images/generic-featured.png` - immagine generica
- `scripts/generate-image-placeholders.js` - genera placeholder
- `scripts/check-image-placeholders.js` - verifica CI
- `scripts/validate-image-specs.js` - validazione dimensioni
- `docs/IMAGE_GUIDE.md` - guida per creatori

## Componenti

### 1. Data Files Config

**`src/jekyll/_data/eventi.yaml`**:
```yaml
epppi:
  name: "EPPPI"
  slug: "epppi"

campo-eg:
  name: "Campo EG"
  slug: "campo-eg"

stage:
  name: "Stage"
  slug: "stage"
```

**`src/jekyll/_data/ambientazioni.yaml`**:
```yaml
momo:
  name: "Momo"
  slug: "momo"

star-trek:
  name: "Star Trek"
  slug: "star-trek"

star-wars:
  name: "Star Wars"
  slug: "star-wars"

monkey-island:
  name: "Monkey Island"
  slug: "monkey-island"
```

### 2. Frontmatter Post

**Post con evento + ambientazione**:
```yaml
---
layout: post
title: "Titolo"
event_type: epppi
ambientazione: star-wars
---
```

**Post generico (senza evento)**:
```yaml
---
layout: post
title: "Titolo"
---
```

**Override manuale**:
```yaml
---
layout: post
title: "Titolo"
featured: images/custom-image.jpg
---
```

### 3. Frontmatter Evento

```yaml
---
layout: evento
slug: epppi
title: "EPPPI 2026"
event_type: epppi
year: 2026
---
```

Se `image` non presente, sistema genera automaticamente:
```
/assets/images/epppi/locandina_epppi_2026.jpg
```

Override manuale:
```yaml
---
layout: evento
slug: epppi
title: "EPPPI 2026"
event_type: epppi
year: 2026
image: /assets/images/epppi/custom-locandina.jpg
---
```

## Logica Liquid Layouts

### Layout Post - Immagine Featured

In `src/jekyll/_layouts/post.html`:

```liquid
{% if page.featured %}
  {% assign featured_image = page.featured %}
{% elsif page.event_type and page.ambientazione %}
  {% assign event_slug = site.data.eventi[page.event_type].slug %}
  {% assign amb_slug = site.data.ambientazioni[page.ambientazione].slug %}
  {% assign featured_image = "/assets/images/" | append: event_slug | append: "/" | append: event_slug | append: "-" | append: amb_slug | append: "-featured.jpg" %}
{% else %}
  {% assign featured_image = "/assets/images/generic-featured.png" %}
{% endif %}

{% unless site.static_files contains featured_image %}
  {% assign featured_image = "/assets/images/generic-featured.png" %}
{% endunless %}
```

**Priorità**:
1. Override manuale `featured:`
2. Calcolato da `event_type` + `ambientazione`
3. Fallback generico se file non esiste

### Layout Evento - Volantino

In `src/jekyll/_layouts/evento.html`:

```liquid
{% if page.image %}
  {% assign locandina = page.image %}
{% else %}
  {% assign event_slug = site.data.eventi[page.event_type].slug %}
  {% assign locandina = "/assets/images/" | append: event_slug | append: "/locandina_" | append: event_slug | append: "_" | append: page.year | append: ".jpg" %}
{% endif %}

{% unless site.static_files contains locandina %}
  {% assign locandina = "/assets/images/generic-featured.png" %}
{% endunless %}
```

**Priorità**:
1. Override manuale `image:`
2. Calcolato da `event_type` + `year`
3. Fallback generico se file non esiste

## Script Node

### 1. Generazione Placeholder

**`scripts/generate-image-placeholders.js`**:

Genera placeholder 1×1 pixel rosso con metadata "PLACEHOLDER" per:
- Tutte le combinazioni evento × ambientazione
- Tutti i tipi evento per l'anno corrente

Placeholder includono commento visibile:
```
============================================================
PLACEHOLDER - SOSTITUIRE CON IMMAGINE REALE
============================================================
Tipo: Volantino EPPPI 2026
Dimensioni: 3508 × 4961 px (A3 @ 300 DPI)
Formato: JPG, qualità 85%, max 500 KB
Vedi: docs/IMAGE_GUIDE.md
============================================================
```

### 2. Verifica Placeholder

**`scripts/check-image-placeholders.js`**:

Identifica placeholder tramite:
1. Dimensioni 1×1 pixel
2. Metadata EXIF "PLACEHOLDER"

Fallisce se trova placeholder non sostituiti.

### 3. Validazione Specifiche

**`scripts/validate-image-specs.js`**:

Verifica:
- **Volantini**: 3508 × 4961 px (A3 @ 300 DPI), max 500 KB
- **Featured**: 1200 × 630 px (16:9), max 200 KB
- **Generic**: 1200 × 630 px (16:9), max 300 KB

## CI/CD Integration

### GitHub Actions

**`.github/workflows/validate-pr.yml`** - nuovo job:

```yaml
check-image-placeholders:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'

    - name: Install dependencies
      run: |
        cd scripts
        npm install sharp js-yaml

    - name: Check image placeholders
      id: check-placeholders
      run: |
        node scripts/check-image-placeholders.js

    - name: Validate image specs
      id: validate-specs
      run: |
        node scripts/validate-image-specs.js

    - name: Comment on PR if issues found
      if: failure()
      uses: actions/github-script@v6
      with:
        script: |
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: '❌ **Image Issues Found**\n\n' +
                  'Sostituisci placeholder o correggi specifiche:\n' +
                  '- Volantini: 3508×4961px, max 500KB\n' +
                  '- Featured: 1200×630px, max 200KB\n' +
                  '- Vedi: docs/IMAGE_GUIDE.md'
          })
```

### Makefile Targets

```makefile
# Genera placeholder per nuove combinazioni
generate-placeholders:
	@echo "📸 Genero placeholder immagini..."
	@cd scripts && node generate-image-placeholders.js
	@echo "✅ Placeholder generati"

# Verifica assenza placeholder
check-placeholders:
	@echo "🔍 Verifico placeholder..."
	@cd scripts && node check-image-placeholders.js
	@echo "✅ Nessun placeholder trovato"

# Ottimizza tutte le immagini
optimize-images:
	@echo "🖼️  Ottimizzazione immagini..."
	@$(MAKE) optimize-volantini
	@$(MAKE) optimize-featured
	@$(MAKE) optimize-generic
	@echo "✅ Ottimizzazione completata"

optimize-volantini:
	@echo "📄 Ottimizzazione volantini (A3 @ 300DPI)..."
	@find src/jekyll/assets/images -name "locandina_*.jpg" -type f | while read file; do \
		magick "$$file" -resize 3508x4961 -quality 85 -strip "$$file.tmp"; \
		mv "$$file.tmp" "$$file"; \
	done

optimize-featured:
	@echo "🖼️  Ottimizzazione featured (16:9)..."
	@find src/jekyll/assets/images -name "*-featured.jpg" -type f | while read file; do \
		magick "$$file" -resize 1200x630 -quality 85 -strip "$$file.tmp"; \
		mv "$$file.tmp" "$$file"; \
	done
```

## Specifiche Tecniche Immagini

### Volantini Eventi (Locandine)

- **Dimensioni**: 3508 × 4961 px (A3 verticale @ 300 DPI)
- **Formato**: JPG, qualità 85%
- **Peso max**: 500 KB
- **Colori**: RGB, profilo sRGB
- **Nome file**: `locandina_{tipo}_{anno}.jpg`
- **Posizione**: `/assets/images/{tipo}/`
- **Esempio**: `locandina_epppi_2026.jpg`

### Immagini Featured Post

- **Dimensioni**: 1200 × 630 px (16:9)
- **Formato**: JPG qualità 85% o WebP
- **Peso max**: 200 KB
- **Colori**: RGB, profilo sRGB
- **Nome file**: `{tipo}-{ambientazione}-featured.jpg`
- **Posizione**: `/assets/images/{tipo}/`
- **Esempio**: `epppi-star-wars-featured.jpg`

### Immagine Generica Post

- **Dimensioni**: 1200 × 630 px (16:9)
- **Formato**: PNG
- **Peso max**: 300 KB
- **Nome file**: `generic-featured.png`
- **Posizione**: `/assets/images/`

### Ottimizzazione Comandi

```bash
# Installa ImageMagick
sudo apt-get install imagemagick

# Ottimizza volantino
convert input.jpg -resize 3508x4961 -quality 85 output.jpg

# Ottimizza featured
convert input.jpg -resize 1200x630 -quality 85 output.jpg
```

## Error Handling

### Liquid - File Non Esistente

Se immagine calcolata non esiste, fallback automatico a `generic-featured.png`.

### Script Node - Errori

**Cartella inesistente**:
```javascript
if (!fs.existsSync(filepath)) {
  console.error(`❌ ERRORE: Cartella inesistente ${dirPath}`);
  console.log(`   Crea cartella: mkdir -p ${dirPath}`);
  process.exit(1);
}
```

**Validazione fallita**:
```javascript
if (validationResult.valid === false) {
  console.error(`❌ ${imagePath}: ${validationResult.error}`);
  failedImages++;
}
```

### CI - Messaggi Chiari

GitHub Actions comment:
- Lista immagini problematiche
- Cosa correggere (dimensioni, peso, formato)
- Link a `docs/IMAGE_GUIDE.md`

## Documentazione Utente

**`docs/IMAGE_GUIDE.md`** include:

1. Specifiche complete per ogni tipo immagine
2. Comandi ottimizzazione
3. Esempi naming file
4. Troubleshooting comune

## Flusso Lavoro Tipico

### Nuovo Evento

```bash
# 1. Crea file evento
vim src/jekyll/_eventi/epppi-2027.md

# 2. Genera placeholder
make generate-placeholders

# 3. Verifica placeholder generato
ls -lh src/jekyll/assets/images/epppi/locandina_epppi_2027.jpg

# 4. Crea immagine reale con specifiche corrette
# (usare docs/IMAGE_GUIDE.md come riferimento)

# 5. Sostituisci placeholder
mv mia-locandina.jpg src/jekyll/assets/images/epppi/locandina_epppi_2027.jpg

# 6. Verifica
make check-placeholders
make validate-image-specs
```

### Nuovo Post

```bash
# 1. Crea post con event_type + ambientazione
vim src/jekyll/_posts/2026-05-04-mio-post.md

# 2. Genera placeholder se necessario
make generate-placeholders

# 3. Crea immagine o usa override manuale
# Opzione A: crea immagine con nome corretto
# /assets/images/epppi/epppi-star-wars-featured.jpg

# Opzione B: override nel frontmatter
# featured: /assets/images/custom.jpg
```

## Success Criteria

✅ Post con `event_type` + `ambientazione` usano immagine calcolata
✅ Post senza evento usano immagine generica
✅ Override manuale sempre possibile
✅ Volantini evento generati da `event_type` + `year`
✅ Placeholder bloccano deployment
✅ CI verifica dimensioni e peso
✅ Ottimizzazione automatica in build
✅ Documentazione chiara per creatori

## Prossimi Passi

1. Creare data files YAML
2. Modificare layout Jekyll
3. Implementare script Node
4. Aggiornare CI/CD
5. Creare documentazione
6. Test completo flusso
