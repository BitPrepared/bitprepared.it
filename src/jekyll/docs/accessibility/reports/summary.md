# Accessibility Audit Summary

Generated: Fri May  1 11:35:57 AM CEST 2026

## Lighthouse: about

## Lighthouse Score

**Overall:** 100%

### Failed Audits:

### Passed Audits (sample):
- Total passed: 22

## Lighthouse: blog-post

## Lighthouse Score

**Overall:** 100%

### Failed Audits:

### Passed Audits (sample):
- Total passed: 25

## Lighthouse: eventi-listing

## Lighthouse Score

**Overall:** 98%

### Failed Audits:
- **Heading elements are not in a sequentially-descending order**
  Properly ordered headings that do not skip levels convey the semantic structure of the page, making it easier to navigate and understand when using assistive technologies. [Learn more about heading order](https://dequeuniversity.com/rules/axe/4.10/heading-order).
  **Affected elements:**
  1. `div.percorso-timeline > article.percorso-tappa > div.tappa-card > h3.text-green-900`
     Path: `1,HTML,1,BODY,5,MAIN,3,MAIN,0,DIV,4,DIV,0,ARTICLE,3,DIV,0,H3`

### Passed Audits (sample):
- Total passed: 23

## Lighthouse: evento-detail

## Lighthouse Score

**Overall:** 100%

### Failed Audits:

### Passed Audits (sample):
- Total passed: 25

## Lighthouse: homepage

## Lighthouse Score

**Overall:** 100%

### Failed Audits:

### Passed Audits (sample):
- Total passed: 24

## Lighthouse: software-detail

## Lighthouse Score

**Overall:** 100%

### Failed Audits:

### Passed Audits (sample):
- Total passed: 21

## Lighthouse: software-listing

## Lighthouse Score

**Overall:** 100%

### Failed Audits:

### Passed Audits (sample):
- Total passed: 24

## Lighthouse: tags

## Lighthouse Score

**Overall:** 100%

### Failed Audits:

### Passed Audits (sample):
- Total passed: 22

## axe-core Violations: about

## axe-core Violations

**Total Violations:** 3

### Critical Issues:
None
### Serious Issues:
None

## Quick Fixes

### Top Priority Actions


## axe-core Violations: blog-post

## axe-core Violations

**Total Violations:** 3

### Critical Issues:
None
### Serious Issues:
None

## Quick Fixes

### Top Priority Actions


## axe-core Violations: eventi-listing

## axe-core Violations

**Total Violations:** 4

### Critical Issues:
None
### Serious Issues:
None

## Quick Fixes

### Top Priority Actions


## axe-core Violations: evento-detail

## axe-core Violations

**Total Violations:** 0


## Quick Fixes

### Top Priority Actions


## axe-core Violations: homepage

## axe-core Violations

**Total Violations:** 0


## Quick Fixes

### Top Priority Actions


## axe-core Violations: software-detail

## axe-core Violations

**Total Violations:** 2

### Critical Issues:
None
### Serious Issues:
- **color-contrast**
  Ensures the contrast between foreground and background colors meets WCAG 2 AA minimum contrast ratio thresholds
  Nodes: 2


## Quick Fixes

### Top Priority Actions

1. **Ensures the contrast between foreground and background colors meets WCAG 2 AA minimum contrast ratio thresholds**
   - Violation: color-contrast
   - Impact: serious
   - Help: https://dequeuniversity.com/rules/axe/4.8/color-contrast?application=axeAPI
   - Sample target: p


## axe-core Violations: software-listing

## axe-core Violations

**Total Violations:** 3

### Critical Issues:
None
### Serious Issues:
None

## Quick Fixes

### Top Priority Actions


## axe-core Violations: tags

## axe-core Violations

**Total Violations:** 4

### Critical Issues:
None
### Serious Issues:
- **color-contrast**
  Ensures the contrast between foreground and background colors meets WCAG 2 AA minimum contrast ratio thresholds
  Nodes: 10


## Quick Fixes

### Top Priority Actions

1. **Ensures the contrast between foreground and background colors meets WCAG 2 AA minimum contrast ratio thresholds**
   - Violation: color-contrast
   - Impact: serious
   - Help: https://dequeuniversity.com/rules/axe/4.8/color-contrast?application=axeAPI
   - Sample target: a[data-tag="bitprepared"]


## Files Analyzed
**Lighthouse reports:** 8
- `docs/accessibility/reports/lighthouse/about.json`
- `docs/accessibility/reports/lighthouse/blog-post.json`
- `docs/accessibility/reports/lighthouse/eventi-listing.json`
- `docs/accessibility/reports/lighthouse/evento-detail.json`
- `docs/accessibility/reports/lighthouse/homepage.json`
- `docs/accessibility/reports/lighthouse/software-detail.json`
- `docs/accessibility/reports/lighthouse/software-listing.json`
- `docs/accessibility/reports/lighthouse/tags.json`

**axe-core reports:** 8
- `docs/accessibility/reports/axe/about.json`
- `docs/accessibility/reports/axe/blog-post.json`
- `docs/accessibility/reports/axe/eventi-listing.json`
- `docs/accessibility/reports/axe/evento-detail.json`
- `docs/accessibility/reports/axe/homepage.json`
- `docs/accessibility/reports/axe/software-detail.json`
- `docs/accessibility/reports/axe/software-listing.json`
- `docs/accessibility/reports/axe/tags.json`
