# Piano SEO Improvement - BitPrepared.it

## Stato Implementazione

- ✅ **Fase 1: Fix Critici** - Completata (2026-04-30)
  - ✅ lang/locale it_IT nel config
  - ✅ robots.txt creato
  - ✅ jekyll-sitemap aggiunto
  - ✅ Makefile aggiornato
- ✅ **Fase 2: Performance** - Completata (2026-04-30)
  - ✅ Google Fonts ottimizzato (già OK)
  - ✅ Generator meta tag rimosso
  - ⏸️ Tailwind CDN - Mantenuto per compatibilità (build locale complesso)
- ✅ **Fase 3: On-Page SEO** - Completata (2026-04-30)
  - ✅ Meta description homepage aggiornata
  - ✅ Title homepage aggiornato
  - ✅ EducationalOrganization schema aggiunto
- ✅ **Fase 4: Architettura** - Completata (2026-05-01)
  - ❌ Breadcrumb navigation (rimosso - non visibile)
  - ✅ Privacy Policy creata (GDPR compliant)
  - ✅ Cookie Policy creata
  - ✅ Footer aggiornato con link legali
  - ✅ CSS footer-legal aggiunto

---

## Contesto

Sito statico Jekyll per BitPrepared (organizzazione no-profit che prepara giovani al Service Digitale). Audit SEO del sito generato in `_site/`.

**Problemi identificati:**
- Canonical URLs con IP locale (0.0.0.0:4000) - CRITICO
- og:locale sbagliato (en_US invece di it_IT) - CRITICO  
- Manca robots.txt - CRITICO
- Manca sitemap.xml - CRITICO
- Tailwind CSS via CDN - performance
- Meta description generica
- Google Fonts non ottimizzato
- Generator meta tag superfluo

## Obiettivo

Risolvere tutti i problemi SEO critici e migliorare indicizzazione/posizionamento su Google.

---

## Fase 1: Fix Critici (Week 1)

### 1.1 Configurare Jekyll SEO Plugin

**File:** `_config.yml`

**Modifiche:**
```yaml
# Aggiungi queste righe:
url: "https://www.bitprepared.it"
lang: it_IT
locale: it_IT

# Plugins (se non esiste, aggiungi)
plugins:
  - jekyll-sitemap
```

**Perché:** 
- `url` risolve il problema canonical URLs
- `lang` e `locale` risolvono og:locale sbagliato
- `jekyll-sitemap` genera sitemap automaticamente

### 1.2 Installa Gemma Sitemap

**File:** `Gemfile`

**Aggiungi:**
```ruby
gem 'jekyll-sitemap'
```

**Esegui:**
```bash
bundle install
```

### 1.3 Crea robots.txt

**File:** `robots.txt` (nella root del progetto, non in `_site`)

**Contenuto:**
```txt
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /.jekyll-cache/
Disallow: /vendor/

Sitemap: https://www.bitprepared.it/sitemap.xml
```

### 1.4 Aggiorna Makefile per Copiare robots.txt

**File:** `Makefile` - target `build`

**Aggiungi dopo il comando docker run:**
```makefile
build:
	docker run ... # comando esistente
	@cp robots.txt _site/  # AGGIUNGI QUESTO
```

---

## Fase 2: Ottimizzazioni Performance (Week 2)

### 2.1 Ottimizza Google Fonts

**File:** `_includes/head.html` o dove viene caricato Google Fonts

**Modifica:**
```html
<!-- PRIMA -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@500;600;700&display=swap" rel="stylesheet">

# oppure meglio:
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
```

**Perché:** `display=swap` previene FOUT e blocco rendering.

### 2.2 Rimuovi Generator Meta Tag

**File:** `_layouts/default.html` o layout base

**Cerca e rimuovi:**
```liquid
<meta name="generator" content="Jekyll v4.4.1" />
```

**Oppure nascondi condizionalmente.**

### 2.3 Verifica Tailwind CSS Build

**Obiettivo:** Assicurarsi che Tailwind sia compilato in locale, non da CDN.

**Verifica file:** `assets/css/main.css` o simili - dovrebbe contenere CSS Tailwind compilato.

Se usi CDN per sviluppo, assicurati che in produzione sia buildato.

---

## Fase 3: On-Page SEO (Week 3)

### 3.1 Migliora Meta Description Homepage

**File:** `_pages/index.md` frontmatter o dove definita description SEO

**Attuale:** "Digito ergo sum, per un uso consapevole del digitale"

**Nuova:**
```markdown
description: "Bit Prepared organizza eventi di preparazione al Service Digitale e percorsi formativi per giovani. Campi scout estivi, stage pratici, orientamento professionale nel settore tech."
```

**Keywords:** "corso service digitale", "preparazione informatica giovani", "formazione tech"

### 3.2 Migliora Title Homepage

**Attuale:** "Bit Prepared - Digito ergo sum | Bit Prepared"

**Nuova proposta:**
```markdown
title: "Bit Prepared | Percorso di Preparazione al Service Digitale"
```

### 3.3 Aggiungi LocalBusiness Schema

**File:** `_includes/head.html` o `_layouts/default.html`

**Aggiungi prima di `</head>`:**
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "EducationalOrganization",
  "name": "Bit Prepared",
  "url": "https://www.bitprepared.it",
  "logo": "https://www.bitprepared.it/assets/images/logo.png",
  "description": "Organizzazione che prepara giovani al Service Digitale attraverso percorsi formativi e eventi pratici.",
  "address": {
    "@type": "PostalAddress",
    "addressLocality": "Città",
    "addressRegion": "IT",
    "addressCountry": "IT"
  },
  "contactPoint": {
    "@type": "ContactPoint",
    "email": "info@bitprepared.it",
    "contactType": "customer service"
  },
  "sameAs": [
    "https://twitter.com/bitprepared",
    "https://www.facebook.com/bitprepared",
    "https://www.instagram.com/bit.prepared/"
  ]
}
</script>
```

---

## Fase 4: Architecture & Linking (Week 4)

### 4.1 Aggiungi Breadcrumb

**File:** `_includes/breadcrumb.html` (crea nuovo)

**Contenuto:**
```html
<nav aria-label="Breadcrumb" class="breadcrumb">
  <ol class="breadcrumb-list">
    <li><a href="/">Home</a></li>
    <li aria-current="page">{{ page.title }}</li>
  </ol>
</nav>
```

**Includi in layout principali prima del `<main>`.

### 4.2 Aggiungi Footer con Link Importanti

**File:** `_includes/footer.html` (crea nuovo se non esiste)

**Link da includere:**
- Chi siamo (About)
- Eventi
- Software
- Privacy Policy (crea se manca)
- Contatti

### 4.3 Verifica Internal Linking

**Check:** Assicurati che pagine importanti siano linkate dalla homepage.

**Script di verifica:**
```bash
grep -r "href="\"" /workspace/bitprepared.it/_site/index.html | head -20
```

---

## Piano di Test

### Test Pre-Deploy

1. **Locale build:**
   ```bash
   make build
   grep -r "canonical" _site/ | head -5
   # Dovrebbe mostrare https://www.bitprepared.it non 0.0.0.0:4000
   ```

2. **Verifica robots.txt:**
   ```bash
   ls _site/robots.txt
   ```

3. **Verifica sitemap:**
   ```bash
   ls _site/sitemap.xml
   curl http://localhost:4000/sitemap.xml  # dopo make serve
   ```

### Test Post-Deploy

1. **Rich Results Test:** https://search.google.com/test/rich-results
   - Incolla URL: https://www.bitprepared.it
   - Verifica schema Organization

2. **PageSpeed Insights:**
   - Testa homepage
   - Verifica Core Web Vitals

3. **Google Search Console:**
   - Invia sitemap
   - Controlla "Coverage" report
   - Controlla "Enhancements"

---

## File da Modificare

### Configurazione
- `_config.yml` - aggiungi url, lang, locale, plugins
- `Gemfile` - aggiungi jekyll-sitemap

### Nuovi File
- `robots.txt` - root directory
- `_includes/breadcrumb.html` - navigation helper
- `_includes/footer.html` - se non esistente
- `docs/PRIVACY_POLICY.md` - se mancante (GDPR)

### Layout
- `_layouts/default.html` - rimuovi generator tag, aggiungi schema
- `_includes/head.html` - ottimizza fonts

### Contenuto
- `_pages/index.md` - migliora title e description

### Build
- `Makefile` - aggiungi copia robots.txt nel target build

---

## Cronologia Stimata

- **Giorno 1-2:** Config fixes (critical)
- **Giorno 3-5:** Performance fixes
- **Giorno 6-10:** On-page improvements
- **Giorno 11-14:** Architecture improvements
- **Giorno 15:** Test e deploy
- **Giorno 16-30:** Monitoraggio risultati in Google Search Console

---

## Metriche di Successo

### KPI (Key Performance Indicators)

**1 Mese:**
- Sitemap inviata a Google ✅
- Robots.txt presente ✅
- Canonical URLs corrette ✅
- og:locale corretto (it_IT) ✅

**3 Mesi:**
- 50+ pagine indicizzate (vs attuale probabilmente 0)
- Core Web Vitals nel range "good"
- Schema markup valido

**6 Mesi:**
- Top 10 per keywords target ("corso service digitale", "preparazione informatica giovani")
- traffico organico +50% vs baseline
- 0 errori in Search Console

---

## Note Importanti

### DNS/Hosting
- Assicurati che DNS punti al posto giusto
- Verifica hosting supporti HTTPS (vedi build del sito)

### Monitoraggio
- Setup Google Search Console
- installa Google Analytics (se non presente)
- Monitora position ranking keywords target

### Iterazione
- SEO è continuo, non one-time
- Monitora Search Console per problemi emergenti
- Aggiorna contenuto regolarmente per mantenere relevanza

---

## Rischi e Mitigazioni

| Rischio | Mitigazione |
|---------|------------|
| Breaksito build durante config | Test in ambiente locale prima |
| Sitemap non generata correttamente | Verifica XML validità |
| Robots.txt blocca tutto | Test con Google Search Console tester |
| peggioramento traffico temporaneo | Normale durante upgrade SEO |

---

## Prossimi Passi

1. **Approvazione piano** - Revisione questo piano
2. **Setup ambiente** - Installa gemme aggiuntive
3. **Implementazione Fase 1** - Fix critici
4. **Deploy e test** - Verifica in produzione
5. **Fasi successive** - Continua con miglioramenti
6. **Monitoraggio** - Traccia progresso in GSC

---

**File:** docs/SEO_IMPROVEMENT_PLAN.md
**Creato:** 2026-04-30
**Stato:** Da approvare
