# Color Contrast Analysis - BitPrepared.it
**Data:** 2026-04-26
**Standard:** WCAG 2.1 AA (4.5:1 per testo normale, 3:1 per grande testo)

---

## CSS Variables (scout-tech.css)

```css
:root {
  --color-primary: #0a3d0a;      /* Verde scuro */
  --color-secondary: #1a7f1a;    /* Verde medio */
  --color-accent: #00d9ff;       /* Ciano */
  --color-dark: #0a1f0a;         /* Verde molto scuro */
  --color-light: #e8f5e8;        /* Bianco verdino */
  --color-white: #ffffff;        /* Bianco puro */
  --color-text: #1a1a1a;         /* Grigio scuro */
  --color-text-muted: #666666;   /* Grigio medio */
}
```

---

## Color Pairs da Verificare

### 1. Body Text
| Elemento | Foreground | Background | Expected Ratio | Status |
|----------|-----------|------------|----------------|--------|
| Body text | #e8f5e8 | #161616 | > 4.5:1 | ⚠️ DA VERIFICARE |
| Navbar links | #e8f5e8 | rgba(10, 31, 10, 0.95) | > 4.5:1 | ⚠️ DA VERIFICARE |

### 2. Buttons
| Elemento | Foreground | Background | Expected Ratio | Status |
|----------|-----------|------------|----------------|--------|
| Green buttons | #ffffff | #1a7f1a | > 4.5:1 | ⚠️ DA VERIFICARE |
| Event buttons | #ffffff | #1a7f1a | > 4.5:1 | ⚠️ DA VERIFICARE |
| Card buttons | #ffffff | #1a7f1a | > 4.5:1 | ⚠️ DA VERIFICARE |
| CTA buttons | #000000 | #00d9ff | > 4.5:1 | ✅ LIKELY PASS (alto contrasto) |

### 3. Card Headings
| Elemento | Foreground | Background | Expected Ratio | Status |
|----------|-----------|------------|----------------|--------|
| Card headings | #0a3d0a | #ffffff | > 4.5:1 | ⚠️ DA VERIFICARE |
| Hero title | #e8f5e8 | [hero background image] | > 3:1 | ⚠️ DA VERIFICARE (con overlay) |

### 4. Other Text
| Elemento | Foreground | Background | Expected Ratio | Status |
|----------|-----------|------------|----------------|--------|
| Muted text | #666666 | #ffffff | > 4.5:1 | ⚠️ DA VERIFICARE |
| Footer copy | #e8f5e8 | #0a1f0a | > 4.5:1 | ⚠️ DA VERIFICARE |

---

## Manual Verification Required

### Tool Online da Usare:
1. **WebAIM Contrast Checker:** https://webaim.org/resources/contrastchecker/
2. **Colour Contrast Analyser (CCA):** https://www.tpgi.com/color-contrast-checker/

### Procedure:
1. Per ogni coppia foreground/background, inserire i valori hex nel tool
2. Verificare che il ratio sia ≥ 4.5:1 per testo normale
3. Verificare che il ratio sia ≥ 3:1 per testo grande (18px+ o bold 14px+)
4. Documentare risultati in tabella sopra

### Fix Sezioni con Contrast Fallito:
Se ratio < 4.5:1, modificare foreground/background:
- Leggerizzare foreground (aggiungere luminosità)
- Scure background (ridurre luminosità)
- Oppure aggiungere ombra/sfondo per aumentare contrasto

---

## Priority Analysis

### HIGH Priority (Testo normale su sfondo):
- Body text: #e8f5e8 on #161616
- Navbar links: #e8f5e8 on rgba(10, 31, 10, 0.95)
- Card headings: #0a3d0a on #ffffff
- Muted text: #666666 on #ffffff

### MEDIUM Priority (Buttons):
- Green buttons: #ffffff on #1a7f1a
- Card buttons: #ffffff on #1a7f1a

### LOW Priority (Testo grande/decorativo):
- Hero title: #e8f5e8 su hero image con overlay
- Footer copy: #e8f5e8 on #0a1f0a

---

## Recommended Actions

### 1. Testare TUTTE le coppie di colori (15 min)
Usare WebAIM Contrast Checker per verificare ogni coppia

### 2. Fix colori che non passano (30 min)
Se necessario, aggiornare CSS variables o specifiche regole CSS

### 3. Verificare overlay hero section (10 min)
Assicurarsi che testo su hero background image sia leggibile con overlay

---

**Status:** ANALISI IN CORSO - Verifica manuale richiesta
**Prossimo step:** Testing con WebAIM tool per conferma numerica contrast ratios