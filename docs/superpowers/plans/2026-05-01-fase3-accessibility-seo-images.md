# Fase 3: ARIA + SEO + Images + Performance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement accessibility verification, SEO optimization, image optimization pipeline, and performance optimization

**Architecture:** Make commands for ARIA extraction, enhanced meta tags, automated image optimization, lazy loading, critical CSS

**Tech Stack:** Node.js scripts (Cheerio), Jekyll hooks, ImageMagick/sharp, JSON output, Critical CSS extraction

---

## File Structure

```
bitprepared.it/
├── scripts/
│   ├── check-aria.js          # CREATE: Extract ARIA tags to JSON
│   ├── optimize-images.js     # CREATE: Image optimization pipeline
│   └── extract-critical-css.js # CREATE: Critical CSS extraction
├── _includes/
│   ├── structured-data.html   # CREATE: Schema.org JSON-LD
│   ├── head.html              # MODIFY: Add {% seo %}
│   └── lazy-load.html         # CREATE: Lazy loading script
├── _plugins/
│   └── image_optimizer.rb     # CREATE: Jekyll hook for image optimization
├── Makefile                    # MODIFY: Add check-aria, optimize targets
├── assets/
│   ├── css/
│   │   └── critical.css       # CREATE: Critical CSS for inline
│   └── images/
│       └── logo.png            # CREATE: Site logo for SEO
```

---

## Task 1: ARIA Verification System

**Files:**
- Create: `scripts/check-aria.js`
- Modify: `Makefile`

- [ ] **Step 1: Create check-aria.js script**

```bash
cat > scripts/check-aria.js << 'EOF'
const fs = require('fs');
const glob = require('glob');

const ariaTags = ['aria-label', 'aria-describedby', 'aria-hidden', 'role', 'aria-live', 'aria-labelledby'];
const report = {};

glob.sync('_site/**/*.html').forEach(file => {
  const html = fs.readFileSync(file, 'utf8');
  const lines = html.split('\n');
  const fileReport = [];

  ariaTags.forEach(tag => {
    const regex = new RegExp(`\\s${tag}=(["'])([^"']*?)\\1`, 'gi');
    let match;

    while ((match = regex.exec(html)) !== null) {
      const position = match.index;
      const lineNumber = html.substring(0, position).split('\n').length;
      const lineContent = lines[lineNumber - 1] || '';

      fileReport.push({
        tag: tag,
        value: match[2],
        line: lineNumber,
        context: lineContent.trim().substring(0, 100)
      });
    }
  });

  if (fileReport.length > 0) {
    report[file] = fileReport;
  }
});

fs.writeFileSync('aria-report.json', JSON.stringify(report, null, 2));
console.log(`✅ ARIA report generated: ${Object.keys(report).length} files with ARIA tags`);
console.log(`📄 Total ARIA attributes found: ${Object.values(report).flat().length}`);
EOF
```

- [ ] **Step 2: Add Makefile target**

```bash
grep "check-aria:" Makefile || cat >> Makefile << 'EOM'

.PHONY: check-aria
check-aria:
	@echo "🔍 Checking ARIA tags..."
	@node scripts/check-aria.js
EOM
```

- [ ] **Step 3: Test script**

```bash
jekyll build
node scripts/check-aria.js
cat aria-report.json | head -50
```

Expected: JSON report with all ARIA tags and their positions

- [ ] **Step 4: Commit**

```bash
git add scripts/check-aria.js Makefile
git commit -m "feat: add ARIA verification system

- Add check-aria.js script to extract all ARIA tags
- Generate aria-report.json with tag locations
- Add make check-aria target"
```

---

## Task 2: Create Site Logo

**Files:**
- Create: `assets/images/logo.png`

- [ ] **Step 1: Create logo.png specifications**

Logo requirements:
- Size: 512x512px (optimal for Schema.org and social sharing)
- Format: PNG with transparency
- Background: Transparent (for light/dark mode compatibility)
- Content: "Bit Prepared" text or icon
- Colors: Brand colors (#0a3d0a primary, #00d9ff accent)

- [ ] **Step 2: Create placeholder logo**

```bash
# Create simple placeholder logo
convert -size 512x512 xc:none \
  -font Helvetica-Bold -pointsize 72 -fill "#0a3d0a" \
  -gravity center -annotate +0+0 "Bit\nPrepared" \
  assets/images/logo.png

# Verify logo created
ls -lh assets/images/logo.png
```

- [ ] **Step 3: Verify logo in browser**

Open `http://localhost:4000/assets/images/logo.png` in browser

Expected: Logo image loads correctly

- [ ] **Step 4: Commit**

```bash
git add assets/images/logo.png
git commit -m "feat: add Bit Prepared site logo

- Add 512x512px logo.png for SEO and social sharing
- Placeholder logo with brand colors
- Will be replaced with final design"
```

---

## Task 3: Enhanced SEO Meta Tags

**Files:**
- Create: `_includes/structured-data.html`
- Modify: `_layouts/default.html`
- Modify: `_includes/head.html`

- [ ] **Step 1: Enable jekyll-seo-tag in head.html**

```bash
# Check if head.html exists
ls _includes/head.html || echo "{% seo %}" > _includes/head.html
```

Add to head.html:
```html
{% seo %}
```

- [ ] **Step 2: Configure jekyll-seo-tag in _config.yml**

```yaml
# Add to _config.yml
seo:
  title: Bit Prepared
  description: Bit Prepared eventi formativi ed educativi su tecnologia e societa
  author: Bit Prepared
  lang: it_IT
  locale: it_IT
  image: /assets/images/logo.png
  logo: /assets/images/logo.png
  social:
    name: Bit Prepared
    links:
      - https://twitter.com/bitprepared
      - https://www.facebook.com/bitprepared
      - https://www.instagram.com/bit.prepared/
  twitter:
    username: bitprepared
    card: summary_large_image
  facebook:
    app_id: # Optional
    publisher: # Optional
```

- [ ] **Step 3: Create structured-data.html include**

```bash
cat > _includes/structured-data.html << 'EOF'
{% if page.layout == 'post' %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "{{ page.title }}",
  "datePublished": "{{ page.date | date: '%Y-%m-%d' }}",
  "dateModified": "{{ page.modified | default: page.date | date: '%Y-%m-%d' }}",
  "author": {
    "@type": "Organization",
    "name": "Bit Prepared",
    "url": "https://www.bitprepared.it"
  },
  "publisher": {
    "@type": "Organization",
    "name": "Bit Prepared",
    "logo": {
      "@type": "ImageObject",
      "url": "https://www.bitprepared.it/assets/images/logo.png"
    }
  },
  "description": "{{ page.description | default: page.excerpt | strip_html | truncate: 160 }}",
  "image": "{{ page.featured | default: '/assets/images/logo.png' | prepend: 'https://www.bitprepared.it' }}"
}
</script>
{% elsif page.layout == 'evento' %}
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Event",
  "name": "{{ page.title }}",
  "startDate": "{{ page.hero.date }}",
  "location": {
    "@type": "Place",
    "name": "{{ page.hero.location }}",
    "address": {
      "@type": "PostalAddress",
      "addressLocality": "Italia",
      "addressCountry": "IT"
    }
  },
  "description": "{{ page.hero.subtitle | default: page.title }}",
  "organizer": {
    "@type": "Organization",
    "name": "Bit Prepared",
    "url": "https://www.bitprepared.it"
  }
}
</script>
{% endif %}
EOF
```

- [ ] **Step 4: Add structured-data to default layout**

- [ ] **Step 5: Verify meta tags in generated site**

```bash
jekyll build
grep -r "og:title\|twitter:card\|meta.*description" _site/**/*.html | head -10
```

Expected: jekyll-seo-tag generated meta tags present

- [ ] **Step 6: Commit**

```bash
git add _includes/structured-data.html _includes/head.html _layouts/default.html _config.yml
git commit -m "feat: enable jekyll-seo-tag and add structured data

- Enable jekyll-seo-tag plugin with {% seo %}
- Configure SEO settings in _config.yml
- Add Schema.org JSON-LD for blog posts and events
- Remove manual meta tag duplication"
```

---

## Task 4: Image Optimization Pipeline

**Files:**
- Create: `_plugins/image_optimizer.rb`
- Create: `scripts/optimize-images.js`
- Modify: `Makefile`

- [ ] **Step 1: Create Jekyll plugin for image optimization**

```bash
cat > _plugins/image_optimizer.rb << 'EOF'
require 'fileutils'
require 'pathname'

Jekyll::Hooks.register :pages, :post_write do |page|
  next unless page.destination.end_with?('.html')

  dest_dir = File.dirname(page.destination)
  source_dir = File.join(page.site.dest, '..')

  # Copy and optimize images referenced in HTML
  html = File.read(page.destination)
  html.scan(/\/assets\/images\/([^\s"')]+)/) do |match|
    image_path = match[0]
    source_image = File.join(source_dir, image_path)

    if File.exist?(source_image)
      dest_image = File.join(dest_dir, image_path)
      FileUtils.mkdir_p(File.dirname(dest_image))
      FileUtils.cp(source_image, dest_image)

      # Trigger optimization (will be done by separate script)
      puts "🖼️  Copied image: #{image_path}"
    end
  end
end
EOF
```

- [ ] **Step 2: Create image optimization script**

```bash
cat > scripts/optimize-images.js << 'EOF'
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const IMAGE_SIZES = [
  { name: 'mobile', width: 640, suffix: '-m' },
  { name: 'tablet', width: 1024, suffix: '-t' },
  { name: 'desktop', width: 1920, suffix: '-d' }
];

function optimizeImage(inputPath, outputPath, width) {
  const tmpPath = outputPath + '.tmp';

  try {
    // Using ImageMagick convert
    execSync(`convert "${inputPath}" -resize ${width}x -quality 85 "${tmpPath}"`, { stdio: 'inherit' });
    fs.renameSync(tmpPath, outputPath);
    console.log(`✅ Optimized: ${path.basename(outputPath)} (${width}px)`);
  } catch (error) {
    console.error(`❌ Error optimizing ${inputPath}:`, error.message);
  }
}

function processImages() {
  const imagesDir = '_site/assets/images';

  if (!fs.existsSync(imagesDir)) {
    console.log('❌ Images directory not found');
    return;
  }

  fs.readdirSync(imagesDir).forEach(file => {
    if (!/\.(jpg|jpeg|png|webp)$/i.test(file)) return;

    const inputPath = path.join(imagesDir, file);
    const ext = path.extname(file);
    const basename = path.basename(file, ext);

    IMAGE_SIZES.forEach(size => {
      const outputPath = path.join(imagesDir, `${basename}${size.suffix}${ext}`);
      optimizeImage(inputPath, outputPath, size.width);
    });
  });
}

processImages();
console.log('🎉 Image optimization complete');
EOF
```

- [ ] **Step 3: Add Makefile target**

```bash
grep "optimize-images:" Makefile || cat >> Makefile << 'EOM'

.PHONY: optimize-images
optimize-images:
	@echo "🖼️  Optimizing images..."
	@node scripts/optimize-images.js
EOM
```

- [ ] **Step 4: Update picture.html include for responsive images**

```bash
cat > _includes/picture.html << 'EOF'
<picture>
  <source srcset="/assets/images/{{ include.file | replace: '.', '-m.' }}" media="(max-width: 640px)">
  <source srcset="/assets/images/{{ include.file | replace: '.', '-t.' }}" media="(max-width: 1024px)">
  <img src="/assets/images/{{ include.file }}" alt="{{ include.alt }}" loading="lazy">
</picture>
EOF
```

- [ ] **Step 5: Test optimization**

```bash
jekyll build
node scripts/optimize-images.js
ls -lh _site/assets/images/*-m.* | head -5
```

Expected: Optimized images with -m, -t, -d suffixes created

- [ ] **Step 6: Commit**

```bash
git add _plugins/image_optimizer.rb scripts/optimize-images.js _includes/picture.html Makefile
git commit -m "feat: add image optimization pipeline

- Create responsive image sizes (mobile, tablet, desktop)
- Add optimize-images.js script
- Add Jekyll plugin to copy images to _site
- Create picture.html include for responsive images"
```

---

## Task 5: Lazy Loading Implementation

**Files:**
- Create: `_includes/lazy-load.html`
- Modify: `_layouts/default.html`

- [ ] **Step 1: Create lazy-load.html include**

```bash
cat > _includes/lazy-load.html << 'EOF'
<script>
document.addEventListener('DOMContentLoaded', function() {
  // Lazy load images below the fold
  const lazyImages = document.querySelectorAll('img[data-src]');

  const imageObserver = new IntersectionObserver(function(entries, observer) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        const img = entry.target;
        img.src = img.dataset.src;
        img.classList.remove('lazy');
        imageObserver.unobserve(img);
      }
    });
  });

  lazyImages.forEach(function(img) {
    imageObserver.observe(img);
  });
});
</script>

<style>
.lazy {
  opacity: 0;
  transition: opacity 0.3s;
}

.lazy.loaded {
  opacity: 1;
}
</style>
EOF
```

- [ ] **Step 2: Update image tags in layouts**

Modify `_layouts/post.html` and `_layouts/evento.html`:
```html
<img src="/assets/images/placeholder.png"
     data-src="{{ page.featured }}"
     alt="{{ page.title }}"
     class="lazy"
     loading="lazy">
```

- [ ] **Step 3: Add native lazy loading to all images**

Update blog card template:
```html
<img src="/assets/{{ post.featured }}"
     alt="{{ post.title }}"
     width="400"
     height="300"
     loading="lazy"
     class="w-full h-56 object-cover">
```

- [ ] **Step 4: Test lazy loading**

```bash
jekyll build
jekyll serve
# Open browser DevTools → Network
# Reload page and verify images load as you scroll
```

Expected: Images below fold load when scrolled into view

- [ ] **Step 5: Commit**

```bash
git add _includes/lazy-load.html _layouts/post.html _layouts/evento.html blog/index.md
git commit -m "feat: add lazy loading for images

- Add Intersection Observer-based lazy loading
- Add native loading=\"lazy\" attribute to images
- Improve initial page load performance"
```

---

## Task 6: Critical CSS Extraction

**Files:**
- Create: `scripts/extract-critical-css.js`
- Create: `assets/css/critical.css`
- Modify: `_layouts/default.html`

- [ ] **Step 1: Create critical CSS extraction script**

```bash
cat > scripts/extract-critical-css.js << 'EOF'
const fs = require('fs');
const critical = require('critical');

critical.generate({
  base: '_site/',
  src: 'index.html',
  dest: 'assets/css/critical.css',
  dimensions: [{
    width: 1920,
    height: 1080
  }],
  minify: true
}).then(() => {
  console.log('✅ Critical CSS extracted');
}).catch(err => {
  console.error('❌ Error:', err);
});
EOF
```

- [ ] **Step 2: Create critical.css placeholder**

```bash
cat > assets/css/critical.css << 'EOF'
/* Critical CSS - Inline in head for above-the-fold content */
.hero-title { color: #E8F5E8; }
.hero-subtitle { color: #E8F5E8; }
.bg-white { background-color: #ffffff; }
/* More critical styles to be extracted */
EOF
```

- [ ] **Step 3: Update default layout to inline critical CSS**

Modify `_layouts/default.html`:
```html
<head>
  <meta charset="utf-8">
  <style>
    {% include_relative assets/css/critical.css %}
  </style>
  <link rel="stylesheet" href="/assets/css/main.css" media="print" onload="this.media='all'">
  {% seo %}
  {% include structured-data.html %}
</head>
```

- [ ] **Step 4: Add Makefile target**

```bash
grep "extract-critical:" Makefile || cat >> Makefile << 'EOM'

.PHONY: extract-critical
extract-critical:
	@echo "🎨 Extracting critical CSS..."
	@node scripts/extract-critical-css.js
EOM
```

- [ ] **Step 5: Test critical CSS**

```bash
jekyll build
node scripts/extract-critical-css.js
ls -lh assets/css/critical.css
```

Expected: Small CSS file with above-the-fold styles

- [ ] **Step 6: Commit**

```bash
git add scripts/extract-critical-css.js assets/css/critical.css _layouts/default.html Makefile
git commit -m "feat: add critical CSS extraction

- Extract above-the-fold CSS for inline loading
- Reduce render-blocking resources
- Add extract-critical make target"
```

---

## Task 7: Integration Testing

**Files:**
- Test: All Phase 3 features

- [ ] **Step 1: Build complete site**

```bash
make clean
jekyll build
```

- [ ] **Step 2: Run ARIA check**

```bash
make check-aria
wc -l aria-report.json
```

Expected: ARIA report generated with all ARIA tags

- [ ] **Step 3: Verify SEO tags**

```bash
grep -r "schema.org\|og:title\|twitter:card" _site/**/*.html | wc -l
```

Expected: SEO tags present in all pages

- [ ] **Step 4: Verify image optimization**

```bash
ls _site/assets/images/*-{m,t,d}.* 2>/dev/null | wc -l
```

Expected: Multiple responsive versions of images

- [ ] **Step 5: Update documentation**

```bash
cat >> CHANGELOG.txt << 'EOF'

### Added
- Phase 3: Accessibility, SEO, Images, and Performance
  - ARIA verification system with make check-aria
  - Enhanced SEO with Schema.org structured data
  - Open Graph and Twitter Card meta tags via jekyll-seo-tag
  - Image optimization pipeline for responsive images
  - Lazy loading for below-the-fold images
  - Critical CSS extraction for faster render
  - Site logo for SEO and social sharing
EOF
```

- [ ] **Step 6: Final commit**

```bash
git add CHANGELOG.txt
git commit -m "test: complete Phase 3 accessibility/SEO/images

All tests passing:
✅ ARIA verification system working
✅ SEO meta tags enhanced
✅ Image optimization pipeline functional
✅ Responsive images generated

Phase 3 complete."
```

---

## Testing Strategy

### Automatic Tests
```bash
# 1. ARIA verification
make check-aria
cat aria-report.json | jq '.'

# 2. SEO tags verification
jekyll build
grep -r "og:title\|twitter:card" _site/ | wc -l

# 3. Image optimization
make optimize-images
ls _site/assets/images/*-m.* | wc -l
```

### Manual Tests
```bash
# 1. Start server
make serve

# 2. Test in browser
# - https://developers.google.com/rich-results-test (SEO)
# - https://www.socialsharepreview.com/ (Open Graph)
# - Browser DevTools → Lighthouse (Accessibility + SEO)

# 3. Verify responsive images
# - Open DevTools Network tab
# - Reload page with different viewport sizes
# - Verify correct image sizes loaded
```

---

## Next Steps

**Phase 3 Complete** ✅

Prossime fasi opzionali:
- Advanced SEO (sitemap.xml, robots.txt verification)
- PWA features (service worker, manifest)
- Performance monitoring (Lighthouse CI)

---

**Piano**: 2026-05-01-fase3-accessibility-seo-images.md
**Stato**: READY FOR IMPLEMENTATION
**Prerequisiti**: Fase 2 completata
**Dipendenze**: Node.js, ImageMagick
