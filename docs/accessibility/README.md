# Accessibility Testing - BitPrepared.it

Automated accessibility testing setup using Docker, Lighthouse, and axe-core.

## Quick Start

```bash
# Terminal 1: Start Jekyll server
make serve

# Terminal 2: Run accessibility audit
make accessibility-audit
```

## Available Commands

### `make accessibility-audit`
Runs complete accessibility audit on homepage using:
- **Lighthouse** - Full accessibility scan with HTML report
- **axe-core** - WCAG 2.1 AA compliance check

**Output:**
- `docs/accessibility/reports/lighthouse/homepage.report.html` - Visual report
- `docs/accessibility/reports/lighthouse/homepage.report.json` - Raw data
- `docs/accessibility/reports/axe/homepage.json` - Violations

**Time:** ~2 minutes

### `make accessibility-quick`
Quick check using Lighthouse on homepage only.

**Output:**
- `docs/accessibility/reports/lighthouse/quick-check.report.html`

**Time:** ~1 minute

### `make accessibility-full`
Comprehensive audit testing 8 representative pages:
- Homepage
- Eventi listing + detail
- Software listing + detail
- About page
- Blog post
- Tags page

**Output:**
- JSON reports for all 8 pages
- Summary with accessibility scores

**Time:** ~8-10 minutes

### `make docker-build-a11y`
Builds the Docker image with accessibility tools (auto-run by other commands).

## What Gets Tested

### WCAG 2.1 Level AA Compliance

- **Perceivable**: Color contrast, text alternatives, adaptability
- **Operable**: Keyboard navigation, timing, seizures
- **Understandable**: Readable, predictable, input assistance
- **Robust**: Compatible with assistive technologies

### Specific Checks

1. **Automated (Lighthouse + axe)**
   - Color contrast ratios
   - Image alt text
   - Link purpose
   - Labels on form controls
   - ARIA attributes
   - HTML semantics

2. **Manual Required**
   - Keyboard navigation flow
   - Screen reader announcements
   - Focus management
   - Touch target sizes (mobile)

## Interpreting Results

### Lighthouse Score

- **90-100**: Good accessibility
- **70-89**: Needs improvement
- **< 70**: Significant issues

### axe-core Violations

Violations categorized by severity:
- **Critical**: Blocks users completely
- **Serious**: Barriers to access
- **Moderate**: Minor difficulties
- **Minor**: Cosmetic issues

## Docker Container

The `bitprepared-a11y:latest` image includes:

- **Node.js 18** - Runtime
- **Chromium** - Headless browser
- **Lighthouse** - Google's auditing tool
- **axe-core** - Deque's accessibility engine
- **Pa11y** - Accessibility testing toolkit

## Workflow Integration

### Before Committing

```bash
# Quick check
make accessibility-quick

# Review report
xdg-open docs/accessibility/reports/lighthouse/quick-check.report.html
```

### Before Major Release

```bash
# Full audit
make accessibility-full

# Review all reports
ls docs/accessibility/reports/
```

### Continuous Monitoring

Consider integrating into CI/CD pipeline:

```yaml
# .github/workflows/accessibility.yml
- name: Accessibility Audit
  run: make accessibility-quick
```

## Known Limitations

### Automated Tools Can't Detect

1. **Keyboard navigation flow** - Test manually
2. **Screen reader announcements** - Test with NVDA/VoiceOver
3. **Meaningful alt text** - Review descriptions
4. **Form error messages** - Test with invalid input
5. **Custom ARIA widgets** - Verify behavior

### Excluded Checks

- `color-contrast` in axe (handled by Lighthouse)
- Social media links (allowed 404s)
- Anchor links with hashes

## Troubleshooting

### "Connection refused" error

**Problem:** Jekyll server not running

**Solution:** Start server in another terminal:
```bash
make serve
```

### Docker build fails

**Problem:** Network or dependencies issue

**Solution:** Rebuild from scratch:
```bash`
docker rmi bitprepared-a11y:latest
make docker-build-a11y
```

### Reports not generated

**Problem:** Permission issues

**Solution:** Fix directory permissions:
```bash
chmod -R 755 docs/accessibility/reports/
```

## Additional Resources

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [Lighthouse Accessibility Documentation](https://developer.chrome.com/docs/lighthouse/accessibility/)
- [axe-core Documentation](https://www.deque.com/axe/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

## Next Steps

After running automated tests:

1. **Review reports** - Open HTML reports in browser
2. **Prioritize issues** - Fix critical first, then major
3. **Manual testing** - Keyboard navigation, screen readers
4. **Implement fixes** - Update Jekyll templates/CSS
5. **Re-test** - Verify improvements with `make accessibility-audit`
6. **Document** - Update this README with learnings

## File Structure

```
docker/accessibility/
├── Dockerfile              # Container definition
└── scripts/
    ├── accessibility-audit.sh       # Single page audit
    └── accessibility-full-audit.sh  # Multi-page audit

docs/accessibility/
├── README.md              # This file
└── reports/
    ├── lighthouse/        # Lighthouse results
    └── axe/              # axe-core results
```
