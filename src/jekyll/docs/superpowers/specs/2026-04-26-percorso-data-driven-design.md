# Percorso Timeline - Data Driven Design

**Data:** 2026-04-26
**Status:** Approved
**Autore:** Claude + User

## Problema

`_eventi/percorso.md` contiene HTML hardcoded per timeline. HTML e dati mischiati. Difficile manutenere.

## Obiettivo

Separare dati da presentazione. Markdown contiene solo frontmatter YAML con dati tappa. Layout genera HTML via Liquid.

## Design

### 1. Struttura Dati - `percorso.md`

Frontmatter YAML con array `tappe`:

```yaml
---
layout: percorso
title: Il Percorso Bit Prepared
subtitle: "Dagli EG ai Capi: un cammino di crescita digitale"
permalink: /eventi/
tags: [bitprepared, eventi, campi, stage]

tappe:
  - label: "Esploratori/Guide"
    eta: "11-16 anni"
    icon: "/assets/images/loghi_branche/eg.png"
    branch: "EG"
    cta_text: "Scopri il campo"
    evento: "campo-eg"

  - label: "Rover/Scolte"
    eta: "16-21 anni"
    icon: "/assets/images/loghi_branche/rs.png"
    branch: "RS"
    cta_text: "Scopri EPPPI"
    evento: "epppi"

  - label: "Capi"
    eta: "Adulti"
    icon: "/assets/images/loghi_branche/coca.png"
    branch: "Capi"
    cta_text: "Scopri lo stage"
    evento: "stage"
---
```

**Campi:**
- `label`: Nome branca (display)
- `eta`: Fascia età (display)
- `icon`: Path icona branca
- `branch`: Codice branca (alt attribute)
- `cta_text`: Testo pulsante (specifico per tappa)
- `evento`: Slug evento (reference lookup)

### 2. Layout Liquid - `_layouts/percorso.html`

```liquid
---
layout: default
---

<!-- Hero Section -->
<header class="hero flex items-center justify-center text-center">
  <div class="hero-content max-w-5xl mx-auto px-6">
    <h1 class="hero-title text-5xl font-display font-bold text-light mb-4">{{ page.title }}</h1>
    {% if page.subtitle %}
    <p class="hero-subtitle text-xl text-light">{{ page.subtitle }}</p>
    {% endif %}
  </div>
</header>

<!-- Percorso Timeline Content -->
<main class="page-section px-6 py-16 min-h-[50vh]">
  <div class="max-w-6xl mx-auto">
    {% include edit-button.html %}

    <div class="percorso-timeline">
      {% for tappa in page.tappe %}
        {% assign evento_id = tappa.evento %}
        {% assign evento = site.eventi | where: "slug", evento_id | first %}

        <article class="percorso-tappa">
          <div class="tappa-icon">
            <img src="{{ tappa.icon }}" alt="{{ tappa.branch }}">
          </div>
          <p class="tappa-label">{{ tappa.label }}</p>
          <p class="tappa-eta">{{ tappa.eta }}</p>
          <div class="tappa-card">
            <h3>{{ evento.hero.title }}</h3>
            <p>{{ evento.hero.subtitle }}</p>
            <a href="{{ evento.permalink }}" class="btn btn-primary">{{ tappa.cta_text }}</a>
          </div>
        </article>
      {% endfor %}
    </div>
  </div>
</main>
```

**Logica:**
1. Loop `page.tappe`
2. Lookup evento via `site.eventi | where: "slug", tappa.evento`
3. Render HTML con dati tappa + dati evento

### 3. Frontmatter Eventi

Aggiungere `slug` a ogni evento per lookup:

**`_eventi/campo-eg.md`:**
```yaml
---
slug: campo-eg
layout: evento
title: Campo di Competenza Esploratori e Guide
# ... resto frontmatter
```

**`_eventi/epppi.md`:**
```yaml
---
slug: epppi
layout: evento
title: Essere solidi in una società immateriale | Bologna 8-10 Maggio
# ... resto frontmatter
```

**`_eventi/stage.md`:**
```yaml
---
slug: stage
layout: evento
title: Stage per Capi
# ... resto frontmatter
```

### 4. CSS

Nessuna modifica necessaria. CSS esistente già supporta classi generate:
- `.percorso-timeline`
- `.percorso-tappa`
- `.tappa-icon`
- `.tappa-label`
- `.tappa-eta`
- `.tappa-card`

## Vantaggi

1. **Separazione concerns:** Dati (YAML) vs presentazione (Liquid)
2. **DRY:** Evento referenziato, non duplicato
3. **Manutenibilità:** Modifica dati in frontmatter, non HTML
4. **Riutilizzabilità:** Pattern riutilizzabile per altre timeline
5. **Type-safe:** Frontmatter YAML strutturato

## Trade-off

**Pro:**
- Pulito, manutenibile
- Single source of truth per eventi
- Adeguato per 3 elementi

**Contro:**
- Lookup Liquid ogni render (negligibile per 3 elementi)

## Implementazione

Vedi implementation plan separato.
