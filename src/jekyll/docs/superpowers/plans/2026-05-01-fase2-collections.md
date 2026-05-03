# Fase 2: Collections Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Riorganizza contenuti in collections pulite, separa blog da news con type field

**Architecture:** Type field in frontmatter (non collections separate), permalink collections, pagine indice blog/news

**Tech Stack:** Jekyll 4 collections, Liquid templates, YAML frontmatter

---

## File Structure

```
bitprepared.it/
├── _config.yml              # MODIFY: permalink collections
├── _posts/                  # MODIFY: add type: blog|news
├── blog/                    # CREATE: pagina indice blog
├── news/                    # CREATE: pagina indice news
└── _includes/nav.html       # MODIFY: aggiungi link blog/news
```

---

## Task 1: Verifica permalink collections

**Files:**
- Modify: `_config.yml`

- [ ] **Step 1: Leggi collections config**

```bash
grep -A 5 "collections:" _config.yml
```

- [ ] **Step 2: Verifica permalink presenti**

```bash
grep -A 2 "eventi:" _config.yml | grep permalink
grep -A 2 "software:" _config.yml | grep permalink
```

- [ ] **Step 3: Se mancanti, aggiungi permalink**

Se eventi non ha permalink:
```yaml
eventi:
  output: true
  permalink: /eventi/:name/
```

Se software non ha permalink:
```yaml
software:
  output: true
  permalink: /software/:name/
```

- [ ] **Step 4: Commit**

```bash
git add _config.yml
git commit -m "config: add permalink to collections

Add permalink to eventi and software collections for clean URLs"
```

---

## Task 2: Aggiungi type field a posts esistenti

**Files:**
- Modify: `_posts/*.md`

- [ ] **Step 1: Lista tutti posts**

```bash
ls -1 _posts/
```

- [ ] **Step 2: Aggiungi type: blog a ogni post**

Per ogni file, aggiungi frontmatter:
```yaml
---
title: "Titolo esistente"
layout: post
type: blog  # AGGIUNGI QUESTO
---
```

- [ ] **Step 3: Verifica modifiche**

```bash
grep "type: blog" _posts/*.md
# Expected: tutti i posts hanno type: blog
```

- [ ] **Step 4: Commit**

```bash
git add _posts/
git commit -m "content: add type: blog to all posts

Distinguish blog posts from news with type field"
```

---

## Task 3: Crea blog/index.md

**Files:**
- Create: `blog/index.md`

- [ ] **Step 1: Crea directory e file**

```bash
mkdir -p blog
cat > blog/index.md << 'EOF'
---
layout: page
title: Blog
permalink: /blog/
---

<h1 id="blog-title">Blog Bit Prepared</h1>

<div class="blog-grid">
  {% for post in site.posts %}
    {% if post.type == 'blog' or post.type == nil %}
      <article class="blog-card">
        {% if post.date %}
          <span class="post-date">{{ post.date | date: '%d %B %Y' }}</span>
        {% endif %}
        <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
        {% if post.excerpt %}
          <p class="post-excerpt">{{ post.excerpt | strip_html | truncate: 200 }}</p>
        {% endif %}
        <a href="{{ post.url }}" class="btn btn-primary">Leggi tutto</a>
      </article>
    {% endif %}
  {% endfor %}
</div>
EOF
```

- [ ] **Step 2: Verifica file creato**

```bash
cat blog/index.md
```

- [ ] **Step 3: Commit**

```bash
git add blog/index.md
git commit -m "feat: add blog index page

Create blog index with type: blog filtering.
Shows only blog posts, excludes news."
```

---

## Task 4: Crea news/index.md

**Files:**
- Create: `news/index.md`

- [ ] **Step 1: Crea file news**

```bash
cat > news/index.md << 'EOF'
---
layout: page
title: News
permalink: /news/
---

<h1 id="news-title">News Bit Prepared</h1>

<div class="news-grid">
  {% for post in site.posts %}
    {% if post.type == 'news' %}
      <article class="news-card">
        {% if post.date %}
          <span class="post-date">{{ post.date | date: '%d %B %Y' }}</span>
        {% endif %}
        <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
        {% if post.excerpt %}
          <p class="post-excerpt">{{ post.excerpt | strip_html | truncate: 200 }}</p>
        {% endif %}
        <a href="{{ post.url }}" class="btn btn-primary">Leggi tutto</a>
      </article>
    {% endif %}
  {% endfor %}
</div>

{% if site.posts.size == 0 or site.posts.type == 'news' %}
  <p>Nessuna notizia disponibile.</p>
{% endif %}
EOF
```

- [ ] **Step 2: Verifica file creato**

```bash
cat news/index.md
```

- [ ] **Step 3: Commit**

```bash
git add news/index.md
git commit -m "feat: add news index page

Create news index with type: news filtering.
Shows only news posts, excludes blog."
```

---

## Task 5: Aggiorna navigazione

**Files:**
- Modify: `_includes/nav.html`

- [ ] **Step 1: Leggi navigazione attuale**

```bash
cat _includes/nav.html
```

- [ ] **Step 2: Aggiungi link Blog e News**

Trova sezione con link (es. dopo Eventi/Software), aggiungi:
```html
<li><a href="/blog/">Blog</a></li>
<li><a href="/news/">News</a></li>
```

- [ ] **Step 3: Verifica modifiche**

```bash
grep -E "Blog|News" _includes/nav.html
```

- [ ] **Step 4: Commit**

```bash
git add _includes/nav.html
git commit -m "feat: add Blog and News links to navigation

Update navigation to include new blog and news index pages"
```

---

## Task 6: Test permalink collections

**Files:**
- Test: `_site/eventi/`, `_site/software/`

- [ ] **Step 1: Build sito**

```bash
jekyll build
```

- [ ] **Step 2: Verifica eventi output**

```bash
find _site/eventi -name "*.html" | wc -l
# Expected: > 0 (numero di eventi)
```

- [ ] **Step 3: Verifica software output**

```bash
find _site/software -name "*.html" | wc -l
# Expected: > 0 (numero di software)
```

- [ ] **Step 4: Verifica blog e news pagine**

```bash
ls -la _site/blog/ _site/news/
# Expected: index.html presente in entrambi
```

- [ ] **Step 5: Verifica permalink corretti**

```bash
grep -r "permalink" _site/eventi/ _site/software/ | head -5
```

- [ ] **Step 6: Commit finale**

```bash
git add .
git commit -m "test: complete Phase 2 collections restructure

All tests passing:
✅ Collections permalink verified
✅ Blog and news pages created
✅ Navigation updated
✅ Type field added to posts

Phase 2 complete. Ready for Phase 3: ARIA + SEO + Images"
```

---

## Testing Strategy

### Automatic Tests
```bash
# 1. Build test
jekyll build

# 2. Collections test
find _site/eventi -name "*.html" | wc -l
find _site/software -name "*.html" | wc -l

# 3. Blog/News pages test
ls _site/blog/index.html
ls _site/news/index.html

# 4. Type field test
grep "type: blog" _posts/*.md
```

### Manual Tests
```bash
# 1. Start server
jekyll serve

# 2. Visit pages
# http://localhost:4000/blog/
# http://localhost:4000/news/
# http://localhost:4000/eventi/
# http://localhost:4000/software/

# 3. Verify navigation
# Click Blog and News links in navbar
```

---

## Next Steps

**Phase 2 Complete** ✅

Prossima fase:
- [ ] Fase 3: ARIA + SEO + Images → `2026-05-01-fase3-accessibility.md`

---

**Piano**: 2026-05-01-fase2-collections.md
**Stato**: READY FOR IMPLEMENTATION
**Prerequisiti**: Nessuno
**Dipendenze**: Fase 1 completata
