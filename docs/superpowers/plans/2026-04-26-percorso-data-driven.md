# Percorso Timeline Data-Driven Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-step. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert percorso timeline from hardcoded HTML to data-driven YAML + Liquid layout

**Architecture:** Markdown file contains YAML frontmatter with tappa data (label, eta, icon, cta_text, event reference). Layout uses Liquid to lookup evento by slug and render HTML.

**Tech Stack:** Jekyll, Liquid templating, YAML frontmatter

---

## File Structure

**Modified files:**
- `_eventi/campo-eg.md` - Add `slug` frontmatter
- `_eventi/epppi.md` - Add `slug` frontmatter
- `_eventi/stage.md` - Add `slug` frontmatter
- `_eventi/percorso.md` - Replace HTML with YAML frontmatter
- `_layouts/percorso.html` - Replace hardcoded HTML with Liquid lookup

**CSS:** No changes needed - existing classes work

---

### Task 1: Add slug to campo-eg.md

**Files:**
- Modify: `_eventi/campo-eg.md:1-10`

- [ ] **Step 1: Add slug to frontmatter**

Read file, add `slug: campo-eg` after `layout: evento` line:

```bash
# Current frontmatter starts:
---
layout: evento
title: Campo di Competenza Esploratori e Guide
# ...

# Should become:
---
layout: evento
slug: campo-eg
title: Campo di Competenza Esploratori e Guide
# ...
```

Edit file to insert slug line.

- [ ] **Step 2: Verify change**

Run: `head -15 _eventi/campo-eg.md`
Expected: See `slug: campo-eg` after `layout: evento`

- [ ] **Step 3: Commit**

```bash
git add _eventi/campo-eg.md
git commit -m "feat: add slug to campo-eg event"
```

---

### Task 2: Add slug to epppi.md

**Files:**
- Modify: `_eventi/epppi.md:1-10`

- [ ] **Step 1: Add slug to frontmatter**

Read file, add `slug: epppi` after `layout: evento` line.

Edit file to insert slug line.

- [ ] **Step 2: Verify change**

Run: `head -15 _eventi/epppi.md`
Expected: See `slug: epppi` after `layout: evento`

- [ ] **Step 3: Commit**

```bash
git add _eventi/epppi.md
git commit -m "feat: add slug to epppi event"
```

---

### Task 3: Add slug to stage.md

**Files:**
- Modify: `_eventi/stage.md:1-10`

- [ ] **Step 1: Read stage.md to get exact frontmatter**

```bash
head -20 _eventi/stage.md
```

- [ ] **Step 2: Add slug to frontmatter**

Add `slug: stage` after `layout: evento` line.

Edit file to insert slug line.

- [ ] **Step 3: Verify change**

Run: `head -15 _eventi/stage.md`
Expected: See `slug: stage` after `layout: evento`

- [ ] **Step 4: Commit**

```bash
git add _eventi/stage.md
git commit -m "feat: add slug to stage event"
```

---

### Task 4: Replace percorso.md content with YAML frontmatter

**Files:**
- Modify: `_eventi/percorso.md`

- [ ] **Step 1: Read current percorso.md**

```bash
cat _eventi/percorso.md
```

- [ ] **Step 2: Replace entire file content**

Replace ALL content (frontmatter + HTML) with:

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

- [ ] **Step 3: Verify change**

Run: `cat _eventi/percorso.md`
Expected: Only YAML frontmatter, no HTML content

- [ ] **Step 4: Commit**

```bash
git add _eventi/percorso.md
git commit -m "refactor: convert percorso.md to data-driven YAML"
```

---

### Task 5: Rewrite _layouts/percorso.html with Liquid lookup

**Files:**
- Modify: `_layouts/percorso.html`

- [ ] **Step 1: Read current layout**

```bash
cat _layouts/percorso.html
```

- [ ] **Step 2: Replace entire layout content**

Replace ALL content with:

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

<!-- Percorso Timeline Content - Full width for timeline -->
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

- [ ] **Step 3: Verify change**

Run: `cat _layouts/percorso.html`
Expected: Liquid loop with `site.eventi | where: "slug", evento_id`

- [ ] **Step 4: Commit**

```bash
git add _layouts/percorso.html
git commit -m "refactor: use Liquid lookup for percorso timeline"
```

---

### Task 6: Test build locally

**Files:**
- Test: Build verification

- [ ] **Step 1: Start Jekyll server**

```bash
make serve
```

Wait for server to start (check for "Server address: http://127.0.0.1:4000/")

- [ ] **Step 2: Check build logs**

Look for Liquid syntax errors or YAML parse errors.

Expected: No errors, successful build

- [ ] **Step 3: Open browser to /eventi/**

Open: `http://127.0.0.1:4000/eventi/`

Verify:
- 3 tappe displayed
- Labels correct (Esploratori/Guide, Rover/Scolte, Capi)
- Age ranges correct
- Icons load (eg.png, rs.png, coca.png)
- Event titles match evento files
- CTA buttons work (link to /eventi/campo-eg/, /eventi/epppi/, /eventi/stage/)

- [ ] **Step 4: Click each CTA button**

Verify each link navigates to correct event page.

- [ ] **Step 5: Stop server**

Ctrl+C in terminal

- [ ] **Step 6: Commit working state**

```bash
git add .
git commit -m "test: verify percorso timeline builds and renders correctly"
```

---

### Task 7: Run visual regression tests

**Files:**
- Test: Visual verification

- [ ] **Step 1: Check visual regression status**

```bash
make validate-graphics
```

Expected: Screenshots match baseline or report shows acceptable differences

- [ ] **Step 2: Review visual differences if any**

If report generated, open: `screenshots/report/index.html`

Check:
- Timeline layout matches
- No broken styling
- Icons render correctly
- Text readable

- [ ] **Step 3: Update baseline if needed**

If changes are acceptable (new HTML structure but same visual):

```bash
make visual-baseline
```

- [ ] **Step 4: Commit new baseline**

```bash
git add tests/visual-baseline/
git commit -m "test: update visual baseline for percorso timeline"
```

---

### Task 8: Check links

**Files:**
- Test: Link verification

- [ ] **Step 1: Run link checker**

```bash
make check-links
```

Expected: No broken links on /eventi/ page

- [ ] **Step 2: Fix any broken links if found**

If broken links reported, fix sources.

- [ ] **Step 3: Re-run link checker**

```bash
make check-links
```

Expected: All links valid

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "test: verify all links valid on percorso page"
```

---

## Self-Review Results

**Spec coverage:**
- ✅ YAML frontmatter structure (Task 4)
- ✅ Liquid lookup layout (Task 5)
- ✅ Slug added to events (Tasks 1-3)
- ✅ CSS unchanged (verified in Task 6)

**Placeholder scan:**
- ✅ No TBD/TODO found
- ✅ All code blocks complete
- ✅ All commands with expected output

**Type consistency:**
- ✅ `tappa.evento` matches lookup
- ✅ `evento.slug` matches frontmatter
- ✅ CSS classes match existing styles

**Coverage complete.**
