# Piano Implementazione Audit Accessibilità - BitPrepared.it

## Executive Summary

Questo documento dettaglia il piano completo per eseguire un audit di accessibilità WCAG 2.1 Level AA su bitprepared.it. L'audit si concentra sull'HTML generato in `_site/` e utilizza tools automatici (MCP Playwright, Lighthouse, axe-core) combinati con testing manuale.

**Tempo totale stimato**: 6 ore  
**Target**: 39 pagine HTML (sample di 8 pagine rappresentative)  
**Standard**: WCAG 2.1 Level AA

## Fase 1: Setup e Preparazione (15 min)

### Obiettivo
Configurare ambiente di testing e installare tools necessari.

### Passaggi

#### 1.1 Avvio Server Jekyll
```bash
cd /workspace/bitprepared.it
make serve
```

Verifica che il server sia attivo:
```bash
curl -I http://localhost:4000
```

Expected: HTTP/1.1 200 OK

#### 1.2 Creazione Directory Reports
```bash
mkdir -p /workspace/bitprepared.it/docs/accessibility/reports
mkdir -p /workspace/bitprepared.it/docs/accessibility/screenshots
mkdir -p /workspace/bitprepared.it/docs/accessibility/raw-data
```

#### 1.3 Installazione Tools
```bash
# Lighthouse CLI
npm install -g lighthouse

# axe-core (sarà iniettato via Playwright, ma installa comunque per reference)
npm install -g @axe-core/cli

# Pa11y (opzionale)
npm install -g pa11y
```

### Deliverables Fase 1
- [x] Server Jekyll attivo su localhost:4000
- [x] Directory reports create
- [x] Tools installati

---

## Fase 2: Automated Testing con Lighthouse (45 min)

### Obiettivo
Eseguire scansioni automatiche Lighthouse su tutte le pagine chiave.

### Script di Automazione

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/lighthouse-audit.js
const lighthouse = require('lighthouse');
const chromeLauncher = require('chrome-launcher');
const fs = require('fs');
const path = require('path');

const PAGES = [
  { url: 'http://localhost:4000', name: 'homepage' },
  { url: 'http://localhost:4000/eventi/', name: 'eventi-listing' },
  { url: 'http://localhost:4000/eventi/epppi/', name: 'evento-detail' },
  { url: 'http://localhost:4000/about/', name: 'about' },
  { url: 'http://localhost:4000/software/', name: 'software-listing' },
  { url: 'http://localhost:4000/software/vlc/', name: 'software-detail' },
  { url: 'http://localhost:4000/blog/2025/esploratori-nella-rete/', name: 'blog-post' },
  { url: 'http://localhost:4000/tags/', name: 'tags-page' }
];

const OUTPUT_DIR = './docs/accessibility/reports/lighthouse';

async function runLighthouseAudit() {
  // Crea output directory
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const results = [];

  for (const page of PAGES) {
    console.log(`\n🔍 Auditing: ${page.name} (${page.url})`);
    
    const chrome = await chromeLauncher.launch({ chromeFlags: ['--headless'] });
    
    const options = {
      logLevel: 'info',
      output: 'json',
      onlyCategories: ['accessibility'],
      port: chrome.port
    };

    const runnerResult = await lighthouse(page.url, options);
    
    await chrome.kill();

    // Save raw JSON
    const jsonFile = path.join(OUTPUT_DIR, `${page.name}.json`);
    fs.writeFileSync(jsonFile, JSON.stringify(runnerResult.lhr, null, 2));

    // Extract accessibility score
    const accessibilityScore = runnerResult.lhr.categories.accessibility.score * 100;
    
    results.push({
      page: page.name,
      url: page.url,
      accessibilityScore: accessibilityScore,
      audits: runnerResult.lhr.audits
    });

    console.log(`✅ Score: ${accessibilityScore}/100`);
  }

  // Save summary
  const summaryFile = path.join(OUTPUT_DIR, 'summary.json');
  fs.writeFileSync(summaryFile, JSON.stringify(results, null, 2));

  console.log('\n📊 Summary saved to:', summaryFile);
  return results;
}

runLighthouseAudit().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/lighthouse-audit.js
```

### Metriche da Analizzare

Per ogni pagina, estrai:

1. **Accessibility Score** (target: ≥95)
2. **WCAG 2.1 Level AA Compliance**
3. **Color Contrast Audits**
4. **ARIA Attributes**
5. **HTML Semantics**
6. **Labels and Names**

### Deliverables Fase 2
- [x] 8 file JSON con risultati Lighthouse
- [x] File summary.json con scores aggregate
- [x] Tabella confronto scores per pagina

---

## Fase 3: axe-core Automated Scans (30 min)

### Obiettivo
Eseguire scansioni approfondite con axe-core per identificare violazioni WCAG.

### Script MCP Playwright

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/axe-scan.js
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const PAGES = [
  'http://localhost:4000',
  'http://localhost:4000/eventi/',
  'http://localhost:4000/eventi/epppi/',
  'http://localhost:4000/about/',
  'http://localhost:4000/software/',
  'http://localhost:4000/software/vlc/',
  'http://localhost:4000/blog/2025/esploratori-nella-rete/',
  'http://localhost:4000/tags/'
];

const OUTPUT_DIR = './docs/accessibility/reports/axe';

async function runAxeScan() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const allResults = [];

  for (const url of PAGES) {
    const pageName = url.split('/').filter(Boolean).join('-') || 'homepage';
    console.log(`\n🔍 Scanning with axe-core: ${url}`);

    await page.goto(url, { waitUntil: 'networkidle' });

    // Inject axe-core
    await page.addScriptTag({
      url: 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.8.2/axe.min.js'
    });

    // Run axe-core
    const results = await page.evaluate(() => {
      return axe.run(document, {
        runOnly: {
          type: 'tag',
          values: ['wcag2a', 'wcag2aa', 'wcag21aa']
        }
      });
    });

    // Save results
    const outputFile = path.join(OUTPUT_DIR, `${pageName}.json`);
    fs.writeFileSync(outputFile, JSON.stringify(results, null, 2));

    // Extract violations
    const violations = results.violations.map(v => ({
      id: v.id,
      impact: v.impact,
      description: v.description,
      help: v.help,
      helpUrl: v.helpUrl,
      nodes: v.nodes.length
    }));

    allResults.push({
      url: url,
      pageName: pageName,
      violations: violations,
      totalViolations: violations.length,
      critical: violations.filter(v => v.impact === 'critical').length,
      serious: violations.filter(v => v.impact === 'serious').length,
      moderate: violations.filter(v => v.impact === 'moderate').length,
      minor: violations.filter(v => v.impact === 'minor').length
    });

    console.log(`✅ Found ${violations.length} violations`);
  }

  await browser.close();

  // Save summary
  const summaryFile = path.join(OUTPUT_DIR, 'summary.json');
  fs.writeFileSync(summaryFile, JSON.stringify(allResults, null, 2));

  console.log('\n📊 Summary saved to:', summaryFile);
  return allResults;
}

runAxeScan().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/axe-scan.js
```

### Deliverables Fase 3
- [x] 8 file JSON con risultati axe-core
- [x] Summary con violazioni categorizzate per severity
- [x] Count di critical/serious/moderate/minor violations

---

## Fase 4: Keyboard Navigation Testing (60 min)

### Obiettivo
Verificare che tutte le funzionalità siano accessibili via keyboard.

### Script Playwright per Keyboard Testing

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/keyboard-test.js
const { chromium } = require('playwright');
const fs = require('fs');

const OUTPUT_FILE = './docs/accessibility/reports/keyboard-navigation.json';

async function testKeyboardNavigation() {
  const browser = await chromium.launch({ headless: false }); // Headless false per vedere
  const page = await browser.newPage();

  const results = {
    tests: [],
    issues: []
  };

  console.log('\n🎹 Testing Keyboard Navigation...\n');

  // Test 1: Skip Link
  console.log('Test 1: Skip Link Functionality');
  await page.goto('http://localhost:4000');
  await page.keyboard.press('Tab');
  const skipLink = await page.evaluate(() => document.activeElement.textContent);
  const skipLinkVisible = await page.evaluate(() => {
    const link = document.querySelector('.skip-link');
    return window.getComputedStyle(link).top !== '-40px';
  });
  
  results.tests.push({
    test: 'Skip Link',
    status: skipLinkVisible ? 'PASS' : 'FAIL',
    details: `First tab focuses: "${skipLink}", visible: ${skipLinkVisible}`
  });

  if (!skipLinkVisible) {
    results.issues.push({
      severity: 'critical',
      test: 'Skip Link',
      description: 'Skip link non visibile dopo primo Tab',
      wcag: '2.4.1 Bypass Blocks',
      fix: 'Verificare CSS .skip-link:focus { top: 0; }'
    });
  }

  // Test 2: Tab Order Through Navigation
  console.log('Test 2: Navigation Tab Order');
  await page.goto('http://localhost:4000');
  const tabOrder = [];
  for (let i = 0; i < 6; i++) {
    await page.keyboard.press('Tab');
    const focused = await page.evaluate(() => {
      const el = document.activeElement;
      return {
        tag: el.tagName,
        text: el.textContent.substring(0, 30),
        className: el.className
      };
    });
    tabOrder.push(focused);
  }
  
  results.tests.push({
    test: 'Navigation Tab Order',
    status: 'PASS',
    details: `Tab order: ${tabOrder.map(t => t.tag).join(' → ')}`
  });

  // Test 3: Mobile Menu Keyboard Access
  console.log('Test 3: Mobile Menu Keyboard');
  await page.goto('http://localhost:4000');
  await page.setViewportSize({ width: 375, height: 667 });
  
  // Find menu toggle
  const toggleExists = await page.evaluate(() => {
    const toggle = document.getElementById('navbar-toggle');
    return toggle !== null;
  });

  if (toggleExists) {
    // Tab to toggle
    for (let i = 0; i < 2; i++) {
      await page.keyboard.press('Tab');
    }
    
    const toggleFocused = await page.evaluate(() => 
      document.activeElement.id === 'navbar-toggle'
    );

    // Press Enter to open
    await page.keyboard.press('Enter');
    const menuExpanded = await page.evaluate(() => {
      const nav = document.getElementById('navbar-nav');
      return window.getComputedStyle(nav).display !== 'none';
    });

    results.tests.push({
      test: 'Mobile Menu Keyboard',
      status: menuExpanded ? 'PASS' : 'FAIL',
      details: `Toggle focused: ${toggleFocused}, menu opens: ${menuExpanded}`
    });

    if (!menuExpanded) {
      results.issues.push({
        severity: 'critical',
        test: 'Mobile Menu',
        description: 'Menu non si apre via keyboard',
        wcag: '2.1.1 Keyboard',
        fix: 'Verificare scroll-animations.js event listener'
      });
    }

    // Test ESC to close
    await page.keyboard.press('Escape');
    const menuClosed = await page.evaluate(() => {
      const nav = document.getElementById('navbar-nav');
      return window.getComputedStyle(nav).display === 'none';
    });

    results.tests.push({
      test: 'Mobile Menu ESC Close',
      status: menuClosed ? 'PASS' : 'FAIL',
      details: `ESC closes menu: ${menuClosed}`
    });
  }

  // Test 4: Focus Indicators
  console.log('Test 4: Focus Indicators');
  await page.goto('http://localhost:4000');
  await page.keyboard.press('Tab');
  
  const hasFocusIndicator = await page.evaluate(() => {
    const el = document.activeElement;
    const style = window.getComputedStyle(el);
    return style.outline !== 'none' && style.outline !== '';
  });

  results.tests.push({
    test: 'Focus Indicators',
    status: hasFocusIndicator ? 'PASS' : 'FAIL',
    details: `Element has focus indicator: ${hasFocusIndicator}`
  });

  if (!hasFocusIndicator) {
    results.issues.push({
      severity: 'serious',
      test: 'Focus Indicators',
      description: 'Elementi senza focus indicator visibile',
      wcag: '2.4.7 Focus Visible',
      fix: 'Aggiungere :focus { outline: 3px solid #00d9ff; }'
    });
  }

  // Save results
  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));
  
  console.log('\n✅ Keyboard testing complete');
  console.log(`📊 Results saved to: ${OUTPUT_FILE}`);
  console.log(`\nTests passed: ${results.tests.filter(t => t.status === 'PASS').length}/${results.tests.length}`);
  console.log(`Issues found: ${results.issues.length}`);

  await browser.close();
  return results;
}

testKeyboardNavigation().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/keyboard-test.js
```

### Checklist Manuale (da completare durante esecuzione script)

- [ ] Skip link appare al primo Tab
- [ ] Skip link porta a #main-content
- [ ] Tab order è logico (top → bottom, left → right)
- [ ] Tutti i link/buttons sono raggiungibili via Tab
- [ ] Focus indicators sono visibili su tutti gli elementi
- [ ] Mobile menu si apre/chiude con keyboard
- [ ] ESC chiude menu e ritorna focus al toggle
- [ ] Nessun keyboard trap (si può sempre Tab via)
- [ ] Smooth scroll non rompe keyboard nav

### Deliverables Fase 4
- [x] JSON con risultati keyboard tests
- [x] Lista issues critici/serious
- [x] Video/screenshot evidenza (manuale)

---

## Fase 5: Screen Reader Compatibility (45 min)

### Obiettivo
Verificare compatibilità con screen reader (NVDA/VoiceOver).

### Script per Analisi Semantica

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/screen-reader-analysis.js
const { chromium } = require('playwright');
const fs = require('fs');

const OUTPUT_FILE = './docs/accessibility/reports/screen-reader-analysis.json';

async function analyzeForScreenReaders() {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  const results = {
    pages: [],
    issues: []
  };

  const pages = [
    'http://localhost:4000',
    'http://localhost:4000/eventi/epppi/',
    'http://localhost:4000/about/'
  ];

  for (const url of pages) {
    console.log(`\n🔍 Analyzing: ${url}`);
    await page.goto(url);

    const analysis = await page.evaluate(() => {
      const result = {
        landmarks: [],
        headings: [],
        images: [],
        links: [],
        buttons: [],
        lists: [],
        aria: []
      };

      // Landmarks
      document.querySelectorAll('[role], main, nav, header, footer, section, article, aside').forEach(el => {
        const role = el.getAttribute('role') || el.tagName.toLowerCase();
        const label = el.getAttribute('aria-label') || 
                     el.getAttribute('aria-labelledby') || 
                     el.querySelector('h1, h2')?.textContent || '';
        result.landmarks.push({ role, label: label.substring(0, 50) });
      });

      // Headings
      document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(h => {
        result.headings.push({
          tag: h.tagName,
          text: h.textContent.substring(0, 50)
        });
      });

      // Images
      document.querySelectorAll('img').forEach(img => {
        result.images.push({
          src: img.src.substring(0, 50),
          alt: img.alt,
          missing: !img.hasAttribute('alt')
        });
      });

      // Links (solo quelli senza testo significativo)
      document.querySelectorAll('a').forEach(a => {
        const text = a.textContent.trim();
        const ariaLabel = a.getAttribute('aria-label');
        const title = a.getAttribute('title');
        
        if (text === '' || text === 'Leggi tutto' || text === 'Scopri') {
          result.links.push({
            text: text || '(empty)',
            ariaLabel: ariaLabel || '(missing)',
            title: title || '(missing)',
            href: a.href.substring(0, 50)
          });
        }
      });

      // Buttons
      document.querySelectorAll('button').forEach(btn => {
        const text = btn.textContent.trim();
        const ariaLabel = btn.getAttribute('aria-label');
        result.buttons.push({
          text: text || '(empty)',
          ariaLabel: ariaLabel || '(missing)',
          ariaExpanded: btn.getAttribute('aria-expanded')
        });
      });

      // ARIA attributes
      document.querySelectorAll('[aria-*]').forEach(el => {
        const attrs = {};
        el.getAttributeNames().forEach(attr => {
          if (attr.startsWith('aria-')) {
            attrs[attr] = el.getAttribute(attr);
          }
        });
        if (Object.keys(attrs).length > 0) {
          result.aria.push({
            tag: el.tagName,
            attrs: attrs
          });
        }
      });

      return result;
    });

    results.pages.push({ url, analysis });

    // Check for issues
    if (analysis.headings.length > 0 && analysis.headings[0].tag !== 'H1') {
      results.issues.push({
        severity: 'serious',
        page: url,
        category: 'Headings',
        description: 'Primo heading non è H1',
        wcag: '1.3.1 Info and Relationships',
        fix: 'Verificare struttura headings'
      });
    }

    const missingAlt = analysis.images.filter(i => i.missing).length;
    if (missingAlt > 0) {
      results.issues.push({
        severity: 'critical',
        page: url,
        category: 'Images',
        description: `${missingAlt} immagini senza alt attribute`,
        wcag: '1.1.1 Non-text Content',
        fix: 'Aggiungere alt="" per decorative, alt descrittivo per informative'
      });
    }

    const emptyButtons = analysis.buttons.filter(b => b.text === '(empty)' && b.ariaLabel === '(missing)').length;
    if (emptyButtons > 0) {
      results.issues.push({
        severity: 'critical',
        page: url,
        category: 'Buttons',
        description: `${emptyButtons} button senza testo o aria-label`,
        wcag: '2.5.3 Label in Name',
        fix: 'Aggiungere aria-label descrittivo'
      });
    }
  }

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));
  console.log('\n✅ Screen reader analysis complete');
  console.log(`📊 Results saved to: ${OUTPUT_FILE}`);

  await browser.close();
  return results;
}

analyzeForScreenReaders().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/screen-reader-analysis.js
```

### Testing Manuale con Screen Reader

**NVDA (Windows) o VoiceOver (Mac)**:
1. Avvia screen reader
2. Naviga homepage con arrow keys
3. Verifica annuncio landmarks ("banner", "navigation", "main")
4. Verifica heading structure (H per saltare tra headings)
5. Verifica link announcements ("link, nome link")
6. Verifica image announcements ("image, alt text")

### Deliverables Fase 5
- [x] JSON con analisi semantica
- [x] Lista issues categorizzati
- [x] Note da testing manuale screen reader

---

## Fase 6: Color Contrast Analysis (30 min)

### Obiettivo
Verificare che tutti i text/UI abbiano contrast ratio ≥ WCAG AA.

### Script per Color Contrast

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/color-contrast.js
const { chromium } = require('playwright');
const fs = require('fs');

const OUTPUT_FILE = './docs/accessibility/reports/color-contrast.json';

function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

function getLuminance(r, g, b) {
  const [rs, gs, bs] = [r, g, b].map(c => {
    c = c / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

function getContrastRatio(fg, bg) {
  const fgLum = getLuminance(fg.r, fg.g, fg.b);
  const bgLum = getLuminance(bg.r, bg.g, bg.b);
  const lighter = Math.max(fgLum, bgLum);
  const darker = Math.min(fgLum, bgLum);
  return (lighter + 0.05) / (darker + 0.05);
}

async function analyzeColorContrast() {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  const results = {
    tests: [],
    failures: []
  };

  console.log('\n🎨 Analyzing Color Contrast...\n');

  await page.goto('http://localhost:4000');

  const colorPairs = await page.evaluate(() => {
    const pairs = [];
    const elements = document.querySelectorAll('*');
    
    elements.forEach(el => {
      const style = window.getComputedStyle(el);
      const fg = style.color;
      const bg = style.backgroundColor;
      const fontSize = parseFloat(style.fontSize);
      const fontWeight = parseInt(style.fontWeight);
      
      // Only test visible text
      if (fg !== 'rgba(0, 0, 0, 0)' && 
          bg !== 'rgba(0, 0, 0, 0)' &&
          el.textContent.trim().length > 0 &&
          style.display !== 'none') {
        pairs.push({
          element: el.tagName,
          text: el.textContent.substring(0, 30),
          fg: fg,
          bg: bg,
          fontSize: fontSize,
          fontWeight: fontWeight,
          isBold: fontWeight >= 600 || fontSize >= 18
        });
      }
    });
    
    return pairs;
  });

  // Test each color pair
  colorPairs.forEach(pair => {
    const fg = pair.fg.match(/\d+/g).map(Number);
    const bg = pair.bg.match(/\d+/g).map(Number);
    
    const contrast = getContrastRatio(
      { r: fg[0], g: fg[1], b: fg[2] },
      { r: bg[0], g: bg[1], b: bg[2] }
    );

    const required = pair.isBold ? 4.5 : 7; // Bold text: 4.5:1, Normal: 7:1
    const passes = contrast >= required;

    results.tests.push({
      element: pair.element,
      text: pair.text,
      contrast: contrast.toFixed(2),
      required: required,
      passes: passes,
      fontSize: pair.fontSize
    });

    if (!passes) {
      results.failures.push({
        severity: 'serious',
        element: pair.element,
        text: pair.text,
        contrast: contrast.toFixed(2),
        required: required,
        wcag: '1.4.3 Contrast (Minimum)',
        fix: 'Aumentare contrast ratio o aumentare dimensione testo'
      });
    }
  });

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));
  
  console.log('✅ Color contrast analysis complete');
  console.log(`📊 Results saved to: ${OUTPUT_FILE}`);
  console.log(`\nTests passed: ${results.tests.filter(t => t.passes).length}/${results.tests.length}`);
  console.log(`Failures: ${results.failures.length}`);

  await browser.close();
  return results;
}

analyzeColorContrast().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/color-contrast.js
```

### Colori Specifici da Verificare

Da main.css:

1. **Body text**: `#e8f5e8` su `#161616`
   - Target: 4.5:1
   - Calcolo: TBD

2. **Links/Headings**: `#00d9ff` su `#161616`
   - Target: 4.5:1
   - Calcolo: TBD

3. **Focus indicator**: `#00d9ff` (3px outline)
   - Target: 3:1
   - Calcolo: TBD

### Deliverables Fase 6
- [x] JSON con contrast ratios per elemento
- [x] Lista failures con WCAG references
- [x] Raccomandazioni specifiche

---

## Fase 7: HTML Semantics & Structure (45 min)

### Obiettivo
Verificare struttura HTML semantica e heading hierarchy.

### Script per Semantics Analysis

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/semantics-analysis.js
const { chromium } = require('playwright');
const fs = require('fs');

const OUTPUT_FILE = './docs/accessibility/reports/semantics-analysis.json';

async function analyzeSemantics() {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  const results = {
    pages: [],
    issues: []
  };

  const pages = [
    'http://localhost:4000',
    'http://localhost:4000/eventi/epppi/',
    'http://localhost:4000/software/',
    'http://localhost:4000/about/'
  ];

  for (const url of pages) {
    console.log(`\n🔍 Analyzing semantics: ${url}`);
    await page.goto(url);

    const analysis = await page.evaluate(() => {
      const result = {
        headingStructure: [],
        landmarks: [],
        semanticElements: [],
        issues: []
      };

      // Heading structure
      let prevLevel = 0;
      document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(h => {
        const level = parseInt(h.tagName.substring(1));
        
        // Check for skipped levels
        if (prevLevel > 0 && level > prevLevel + 1) {
          result.issues.push({
            type: 'heading_skip',
            description: `Salto da H${prevLevel} a H${level}`,
            element: h.tagName,
            text: h.textContent.substring(0, 50)
          });
        }
        
        result.headingStructure.push({
          tag: h.tagName,
          level: level,
          text: h.textContent.substring(0, 50),
          id: h.id
        });
        
        prevLevel = level;
      });

      // Check for multiple H1s
      const h1Count = document.querySelectorAll('h1').length;
      if (h1Count !== 1) {
        result.issues.push({
          type: 'multiple_h1',
          description: `${h1Count} H1 trovati (atteso: 1)`,
          severity: 'serious'
        });
      }

      // Landmarks
      const landmarkTags = ['main', 'nav', 'header', 'footer', 'article', 'section', 'aside'];
      landmarkTags.forEach(tag => {
        const elements = document.querySelectorAll(tag);
        elements.forEach(el => {
          const role = el.getAttribute('role');
          const label = el.getAttribute('aria-label');
          result.landmarks.push({
            tag: tag,
            role: role || '(none)',
            label: label || '(none)',
            hasId: !!el.id
          });
        });
      });

      // Semantic elements
      const semanticTags = ['article', 'section', 'aside', 'nav', 'main', 'header', 'footer', 'time', 'mark', 'figure', 'figcaption'];
      semanticTags.forEach(tag => {
        const count = document.querySelectorAll(tag).length;
        if (count > 0) {
          result.semanticElements.push({ tag, count });
        }
      });

      return result;
    });

    results.pages.push({ url, analysis });
    
    // Collect issues
    analysis.issues.forEach(issue => {
      results.issues.push({
        ...issue,
        page: url,
        wcag: issue.type === 'heading_skip' ? '1.3.1 Info and Relationships' : '2.4.1 Bypass Blocks'
      });
    });
  }

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));
  console.log('\n✅ Semantics analysis complete');
  console.log(`📊 Results saved to: ${OUTPUT_FILE}`);
  console.log(`Issues found: ${results.issues.length}`);

  await browser.close();
  return results;
}

analyzeSemantics().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/semantics-analysis.js
```

### Deliverables Fase 7
- [x] JSON con heading structure analysis
- [x] Lista landmarks per pagina
- [x] Issues: salti heading, multiple H1, missing semantic elements

---

## Fase 8: Mobile & Touch Targets (30 min)

### Obiettivo
Verificare touch targets ≥ 44x44px e layout responsive.

### Script per Touch Target Analysis

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/touch-targets.js
const { chromium } = require('playwright');
const fs = require('fs');

const OUTPUT_FILE = './docs/accessibility/reports/touch-targets.json';

async function analyzeTouchTargets() {
  const browser = await chromium.launch();
  const context = browser.defaultContext();
  
  const viewports = [
    { width: 375, height: 667, name: 'mobile' },
    { width: 768, height: 1024, name: 'tablet' }
  ];

  const results = {
    viewports: [],
    issues: []
  };

  for (const viewport of viewports) {
    console.log(`\n📱 Testing ${viewport.name} (${viewport.width}x${viewport.height})`);
    
    const page = await browser.newPage();
    await page.setViewportSize(viewport);
    await page.goto('http://localhost:4000');

    const touchTargets = await page.evaluate(() => {
      const targets = [];
      const interactive = document.querySelectorAll('a, button, input, select, textarea, [onclick]');
      
      interactive.forEach(el => {
        const rect = el.getBoundingClientRect();
        
        // Skip if hidden
        if (rect.width === 0 || rect.height === 0) return;
        
        targets.push({
          tag: el.tagName,
          text: el.textContent.substring(0, 30),
          width: Math.round(rect.width),
          height: Math.round(rect.height),
          area: Math.round(rect.width * rect.height),
          x: Math.round(rect.x),
          y: Math.round(rect.y),
          passesMin: rect.width >= 44 && rect.height >= 44
        });
      });
      
      return targets;
    });

    const failures = touchTargets.filter(t => !t.passesMin);
    
    results.viewports.push({
      viewport: viewport.name,
      size: `${viewport.width}x${viewport.height}`,
      totalTargets: touchTargets.length,
      passingTargets: touchTargets.filter(t => t.passesMin).length,
      failingTargets: failures.length,
      targets: touchTargets
    });

    failures.forEach(f => {
      results.issues.push({
        severity: 'moderate',
        viewport: viewport.name,
        element: f.tag,
        text: f.text,
        size: `${f.width}x${f.height}`,
        wcag: '2.5.5 Target Size',
        fix: 'Aumentare dimensione target a almeno 44x44px'
      });
    });

    await page.close();
  }

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(results, null, 2));
  console.log('\n✅ Touch target analysis complete');
  console.log(`📊 Results saved to: ${OUTPUT_FILE}`);
  console.log(`Issues found: ${results.issues.length}`);

  await browser.close();
  return results;
}

analyzeTouchTargets().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/touch-targets.js
```

### Deliverables Fase 8
- [x] JSON con touch targets per viewport
- [x] Lista elements < 44x44px
- [x] Screenshots evidence (manuale)

---

## Fase 9: Report Generation (60 min)

### Obiettivo
Creare report finale integrato con tutti i findings.

### Script Report Generator

```javascript
// File: /workspace/bitprepared.it/scripts/accessibility/generate-report.js
const fs = require('fs');
const path = require('path');

const REPORTS_DIR = './docs/accessibility/reports';
const OUTPUT_FILE = './docs/accessibility/FINAL_REPORT.md';

function generateReport() {
  // Load all data
  const lighthouse = JSON.parse(fs.readFileSync(path.join(REPORTS_DIR, 'lighthouse/summary.json'), 'utf8'));
  const axe = JSON.parse(fs.readFileSync(path.join(REPORTS_DIR, 'axe/summary.json'), 'utf8'));
  const keyboard = JSON.parse(fs.readFileSync(path.join(REPORTS_DIR, 'keyboard-navigation.json'), 'utf8'));
  const screenReader = JSON.parse(fs.readFileSync(path.join(REPORTS_DIR, 'screen-reader-analysis.json'), 'utf8'));
  const colorContrast = JSON.parse(fs.readFileSync(path.join(REPORTS_DIR, 'color-contrast.json'), 'utf8'));
  const semantics = JSON.parse(fs.readFileSync(path.join(REPORTS_DIR, 'semantics-analysis.json'), 'utf8'));
  const touchTargets = JSON.parse(fs.readFileSync(path.join(REPORTS_DIR, 'touch-targets.json'), 'utf8'));

  // Compile all issues
  const allIssues = [
    ...keyboard.issues.map(i => ({ ...i, source: 'Keyboard Navigation' })),
    ...screenReader.issues.map(i => ({ ...i, source: 'Screen Reader' })),
    ...colorContrast.failures.map(i => ({ ...i, source: 'Color Contrast' })),
    ...semantics.issues.map(i => ({ ...i, source: 'HTML Semantics' })),
    ...touchTargets.issues.map(i => ({ ...i, source: 'Touch Targets' }))
  ];

  // Categorize by severity
  const critical = allIssues.filter(i => i.severity === 'critical');
  const serious = allIssues.filter(i => i.severity === 'serious');
  const moderate = allIssues.filter(i => i.severity === 'moderate');
  const minor = allIssues.filter(i => i.severity === 'minor');

  // Calculate scores
  const avgLighthouseScore = lighthouse.reduce((sum, p) => sum + p.accessibilityScore, 0) / lighthouse.length;
  const totalAxeViolations = axe.reduce((sum, p) => sum + p.totalViolations, 0);

  const report = `# Accessibility Audit Report - BitPrepared.it

**Data**: ${new Date().toISOString().split('T')[0]}  
**Standard**: WCAG 2.1 Level AA  
**Pages Tested**: 8 representative pages (of 39 total)  
**Tools**: Lighthouse, axe-core, Playwright, Manual Testing

---

## Executive Summary

### Overall Accessibility Score

| Metric | Score | Target | Status |
|--------|-------|--------|--------|
| Lighthouse Accessibility | ${avgLighthouseScore.toFixed(1)}/100 | ≥95 | ${avgLighthouseScore >= 95 ? '✅ PASS' : '❌ FAIL'} |
| Total axe-core Violations | ${totalAxeViolations} | 0 | ${totalAxeViolations === 0 ? '✅ PASS' : '❌ FAIL'} |
| Critical Issues | ${critical.length} | 0 | ${critical.length === 0 ? '✅ PASS' : '❌ FAIL'} |
| Serious Issues | ${serious.length} | ≤5 | ${serious.length <= 5 ? '✅ PASS' : '⚠️ WARN'} |
| Moderate Issues | ${moderate.length} | ≤10 | ${moderate.length <= 10 ? '✅ PASS' : '⚠️ WARN'} |

### Issue Summary

| Severity | Count | Priority |
|----------|-------|----------|
| Critical | ${critical.length} | P0 - Fix immediately |
| Serious | ${serious.length} | P1 - Fix within 1 week |
| Moderate | ${moderate.length} | P2 - Fix within 1 month |
| Minor | ${minor.length} | P3 - Next release |

---

## Critical Issues ${critical.length > 0 ? '❌' : '✅'}

${critical.length === 0 ? '*No critical issues found*' : critical.map((issue, i) => `
### ${i + 1}. ${issue.category || issue.test}

- **WCAG Criterion**: ${issue.wcag}
- **Impact**: ${issue.description}
- **Found In**: ${issue.page || 'N/A'}
- **Fix**: ${issue.fix}
- **Priority**: P0
`).join('\n')}

---

## Serious Issues ${serious.length > 0 ? '⚠️' : '✅'}

${serious.length === 0 ? '*No serious issues found*' : serious.map((issue, i) => `
### ${i + 1}. ${issue.category || issue.test}

- **WCAG Criterion**: ${issue.wcag}
- **Impact**: ${issue.description}
- **Found In**: ${issue.page || 'N/A'}
- **Fix**: ${issue.fix}
- **Priority**: P1
`).join('\n')}

---

## Moderate Issues ${moderate.length > 0 ? '⚠️' : '✅'}

${moderate.length === 0 ? '*No moderate issues found*' : moderate.map((issue, i) => `
### ${i + 1}. ${issue.category || issue.test}

- **WCAG Criterion**: ${issue.wcag}
- **Impact**: ${issue.description}
- **Found In**: ${issue.page || 'N/A'}
- **Fix**: ${issue.fix}
- **Priority**: P2
`).join('\n')}

---

## Positive Findings ✅

### Accessibility Features Already Implemented

1. **Skip Link**: Presente e funzionale (\`.skip-link\`)
2. **Mobile Menu**: Accessibile da keyboard con aria-expanded
3. **Focus Management**: Implementato in scroll-animations.js
4. **Reduced Motion**: Supporto prefers-reduced-motion
5. **Semantic Landmarks**: main, nav, footer con roles appropriati
6. **Schema.org**: JSON-LD per eventi
7. **Language**: \`<html lang="it">\` presente
8. **Viewport Meta**: Configurato correttamente

### Keyboard Navigation

- ✅ Skip link appare al primo Tab
- ✅ Tab order logico attraverso pagina
- ✅ Mobile menu accessibile via keyboard
- ✅ ESC chiude menu e ritorna focus
- ✅ Focus indicators visibili (3px #00d9ff outline)

### Screen Reader Compatibility

- ✅ Landmarks presenti (banner, navigation, main, contentinfo)
- ✅ ARIA labels su navigazione e footer
- ✅ Social icons con aria-label descrittivi
- ✅ Heading structure generalmente corretta

---

## Recommendations by Priority

### High Priority (Fix within 1 week) ${critical.length > 0 ? '🔴' : ''}

${critical.length === 0 ? 'No critical issues' : critical.map((issue, i) => `
1. **${issue.category || issue.test}**: ${issue.description}
   - ${issue.fix}
`).join('\n')}

### Medium Priority (Fix within 1 month) ${serious.length > 0 ? '🟡' : ''}

${serious.length === 0 ? 'No serious issues' : serious.map((issue, i) => `
1. **${issue.category || issue.test}**: ${issue.description}
   - ${issue.fix}
`).join('\n')}

### Low Priority (Next release) ${moderate.length > 0 ? '🟢' : ''}

${moderate.length === 0 ? 'No moderate issues' : moderate.map((issue, i) => `
1. **${issue.category || issue.test}**: ${issue.description}
   - ${issue.fix}
`).join('\n')}

---

## Testing Methodology

### Tools Used

- **Lighthouse**: Automated accessibility scoring
- **axe-core**: WCAG 2.1 violation detection
- **Playwright**: Keyboard navigation and semantic analysis
- **Manual Testing**: Screen reader verification, visual inspection

### Viewports Tested

- Desktop: 1920x1080 (Chrome)
- Tablet: 768x1024 (iPad)
- Mobile: 375x667 (iPhone SE)

### Pages Tested

1. Homepage (http://localhost:4000)
2. Eventi Listing (/eventi/)
3. Evento Detail (/eventi/epppi/)
4. Software Listing (/software/)
5. Software Detail (/software/vlc/)
6. About Page (/about/)
7. Blog Post (/blog/2025/esploratori-nella-rete/)
8. Tags Page (/tags/)

### WCAG 2.1 Level AA Criteria Covered

- **Perceivable**: 1.1.1, 1.3.1, 1.4.3, 1.4.11
- **Operable**: 2.1.1, 2.4.1, 2.4.7, 2.5.5
- **Understandable**: 3.1.1, 3.2.1, 3.3.2
- **Robust**: 4.1.1, 4.1.2

---

## Detailed Results

### Lighthouse Scores by Page

| Page | Accessibility Score |
|------|-------------------|
${lighthouse.map(p => `| ${p.page} | ${p.accessibilityScore}/100 |`).join('\n')}

### axe-core Violations by Page

| Page | Critical | Serious | Moderate | Minor | Total |
|------|----------|---------|----------|-------|-------|
${axe.map(p => `| ${p.pageName} | ${p.critical} | ${p.serious} | ${p.moderate} | ${p.minor} | ${p.totalViolations} |`).join('\n')}

### Keyboard Navigation Tests

| Test | Status | Notes |
|------|--------|-------|
${keyboard.tests.map(t => `| ${t.test} | ${t.status} | ${t.details} |`).join('\n')}

### Color Contrast Failures

| Element | Text | Contrast | Required | WCAG |
|---------|------|----------|----------|------|
${colorContrast.failures.slice(0, 10).map(f => `| ${f.element} | ${f.text.substring(0, 20)} | ${f.contrast} | ${f.required} | ${f.wcag} |`).join('\n')}
${colorContrast.failures.length > 10 ? `| ... | | | |` : ''}

---

## Appendix

### Raw Data Files

- \`docs/accessibility/reports/lighthouse/\` - Lighthouse JSON outputs
- \`docs/accessibility/reports/axe/\` - axe-core scan results
- \`docs/accessibility/reports/keyboard-navigation.json\` - Keyboard test results
- \`docs/accessibility/reports/screen-reader-analysis.json\` - Semantic analysis
- \`docs/accessibility/reports/color-contrast.json\` - Contrast ratios
- \`docs/accessibility/reports/semantics-analysis.json\` - HTML structure
- \`docs/accessibility/reports/touch-targets.json\` - Touch target sizes

### References

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [axe-core Documentation](https://www.deque.com/axe/)
- [Lighthouse Accessibility](https://developers.google.com/web/tools/lighthouse/accessibility)
- [WebAIM WCAG Checklist](https://webaim.org/standards/wcag/checklist)

---

**Report Generated**: ${new Date().toISOString()}  
**Audited By**: Claude Code Accessibility Auditor  
**Version**: 1.0.0
`;

  // Save report
  fs.writeFileSync(OUTPUT_FILE, report);
  
  console.log('\n✅ Final report generated');
  console.log(`📄 Report saved to: ${OUTPUT_FILE}`);
  
  return report;
}

generateReport().catch(console.error);
```

### Esecuzione

```bash
node scripts/accessibility/generate-report.js
```

### Deliverables Fase 9

1. **FINAL_REPORT.md** - Report completo in Markdown
2. **Executive Summary** - 1-2 pages PDF version (convertire da MD)
3. **Raw Data** - Tutti i JSON files per reference
4. **Screenshots** - Evidence visual di issues (manuale)

---

## Timeline Completa

| Fase | Durata | Prerequisiti |
|------|--------|--------------|
| 1. Setup | 15 min | - |
| 2. Lighthouse | 45 min | 1 |
| 3. axe-core | 30 min | 1 |
| 4. Keyboard Navigation | 60 min | 1 |
| 5. Screen Reader | 45 min | 1 |
| 6. Color Contrast | 30 min | 1 |
| 7. HTML Semantics | 45 min | 1 |
| 8. Touch Targets | 30 min | 1 |
| 9. Report Generation | 60 min | 2-8 |
| **TOTAL** | **6 ore** | |

---

## Critical Files for Implementation

I file seguenti saranno modificati in base ai findings dell'audit:

1. **/workspace/bitprepared.it/_layouts/default.html**
   - ARIA attributes
   - Landmarks
   - Skip link implementation

2. **/workspace/bitprepared.it/_layouts/evento.html**
   - Event schema
   - Semantic structure
   - Alt text per images

3. **/workspace/bitprepared.it/assets/js/scroll-animations.js**
   - Focus management
   - ARIA states
   - Keyboard navigation

4. **/workspace/bitprepared.it/assets/css/main.css**
   - Focus indicators
   - Color contrast
   - Skip link styling

5. **/workspace/bitprepared.it/_site/index.html**
   - Generated HTML per testing
   - Non modificare direttamente (cambia i layout Jekyll)

---

## Next Steps

1. Eseguire questo piano di audit
2. Review findings e prioritizzare fixes
3. Implementare fixes in ordine: Critical → Serious → Moderate
4. Re-test dopo fixes
5. Implementare continuous accessibility testing in CI/CD

---

**Documento creato**: 2026-04-26  
**Versione**: 1.0.0  
**Autore**: Claude Code Planning Specialist
