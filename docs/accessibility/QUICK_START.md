# Quick Start - Accessibility Audit

## Overview

Questo guida ti permette di eseguire l'audit di accessibilità WCAG 2.1 su bitprepared.it.

## Prerequisites

- Node.js installed
- Jekyll server running
- MCP Playwright available

## Execution Steps

### 1. Setup (15 min)

```bash
# Navigate to project
cd /workspace/bitprepared.it

# Start Jekyll server
make serve

# In another terminal, create directories
mkdir -p docs/accessibility/reports/{lighthouse,axe}
mkdir -p scripts/accessibility

# Install tools
npm install -g lighthouse chrome-launcher
npm install playwright
```

### 2. Run All Tests (5 hours)

```bash
# Create all scripts from IMPLEMENTATION_PLAN.md
# Then execute in order:

# Phase 2: Lighthouse
node scripts/accessibility/lighthouse-audit.js

# Phase 3: axe-core
node scripts/accessibility/axe-scan.js

# Phase 4: Keyboard Navigation
node scripts/accessibility/keyboard-test.js

# Phase 5: Screen Reader Analysis
node scripts/accessibility/screen-reader-analysis.js

# Phase 6: Color Contrast
node scripts/accessibility/color-contrast.js

# Phase 7: HTML Semantics
node scripts/accessibility/semantics-analysis.js

# Phase 8: Touch Targets
node scripts/accessibility/touch-targets.js

# Phase 9: Generate Report
node scripts/accessibility/generate-report.js
```

### 3. Review Results

```bash
# Open final report
cat docs/accessibility/FINAL_REPORT.md

# Or convert to PDF if needed
pandoc docs/accessibility/FINAL_REPORT.md -o accessibility-report.pdf
```

## Expected Output

After completion, you'll have:

```
docs/accessibility/
├── FINAL_REPORT.md          # Complete audit report
├── IMPLEMENTATION_PLAN.md   # This plan
├── QUICK_START.md          # This file
└── reports/
    ├── lighthouse/         # Lighthouse JSON results
    ├── axe/               # axe-core scan results
    ├── keyboard-navigation.json
    ├── screen-reader-analysis.json
    ├── color-contrast.json
    ├── semantics-analysis.json
    └── touch-targets.json
```

## Key Pages Tested

1. Homepage: http://localhost:4000
2. Eventi: /eventi/
3. Evento Detail: /eventi/epppi/
4. Software: /software/
5. Software Detail: /software/vlc/
6. About: /about/
7. Blog: /blog/2025/esploratori-nella-rete/
8. Tags: /tags/

## Common Issues to Fix

Based on Phase 1 code review, expect to find:

1. **Color Contrast**: Verify `#00d9ff` on `#161616` meets 4.5:1
2. **Alt Text**: Check all images have alt attributes
3. **Focus Indicators**: Ensure all interactive elements have :focus styles
4. **Heading Structure**: Verify no skipped levels (h1 → h3)
5. **Touch Targets**: Check buttons/links ≥ 44x44px on mobile

## Timeline

- Setup: 15 min
- Automated Tests: 3 hours
- Manual Testing: 2 hours
- Report Generation: 1 hour
- **Total: 6 hours**

## Questions?

Refer to `IMPLEMENTATION_PLAN.md` for detailed methodology.
