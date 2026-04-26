# Accessibility Testing - BitPrepared.it

Automated accessibility testing setup using Docker, Lighthouse, and axe-core.

## Quick Start

```bash
# Terminal 1: Start Jekyll server
make serve

# Terminal 2: Run accessibility audit
make accessibility-audit
```

## Requirements

- **Docker** - Required for running accessibility tools in isolated environment
- **Jekyll server** running on port 4000

## Available Commands

### `make docker-build-a11y`
Builds the Docker image with accessibility tools (auto-run by other commands).

**Image includes:**
- Node.js 20
- Lighthouse (Google's auditing tool)
- Playwright (browser automation)
- Chromium browser
- axe-core (injected via CDN)

### `make accessibility-audit`
Runs complete accessibility audit on homepage using:
- **Lighthouse** - Full accessibility scan
- **axe-core** - WCAG 2.1 AA compliance check

**Output:**
- `docs/accessibility/reports/lighthouse/homepage.json` - Lighthouse results
- `docs/accessibility/reports/axe/homepage.json` - Violations

**Time:** ~2 minutes

### `make accessibility-quick`
Quick check using Lighthouse on homepage only.

**Output:**
- `docs/accessibility/reports/lighthouse/quick-check.json`

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

View results:
```bash
cat docs/accessibility/reports/lighthouse/homepage.json | jq '.categories.accessibility.score'
```

### axe-core Violations

Violations categorized by severity:
- **Critical**: Blocks users completely
- **Serious**: Barriers to access
- **Moderate**: Minor difficulties
- **Minor**: Cosmetic issues

View violations:
```bash
cat docs/accessibility/reports/axe/homepage.json | jq '.violations | length'
```

## Workflow Integration

### Before Committing

```bash
# Quick check
make accessibility-quick

# View score
cat docs/accessibility/reports/lighthouse/quick-check.json | jq '.categories.accessibility.score'
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

## Docker Container

The `bitprepared-a11y:latest` image runs in complete isolation:
- **No host pollution** - All tools inside container
- **Reproducible** - Same environment every time
- **Easy cleanup** - `docker rmi bitprepared-a11y:latest`

## Architecture

```
Docker Container (bitprepared-a11y)
├── Node.js 20
├── Lighthouse (CLI)
├── Playwright (browser automation)
├── Chromium (headless browser)
└── Scripts
    ├── accessibility-audit.js (single page)
    └── accessibility-full-audit.js (multi-page)
```

## Known Limitations

### Automated Tools Can't Detect

1. **Keyboard navigation flow** - Test manually
2. **Screen reader announcements** - Test with NVDA/VoiceOver
3. **Meaningful alt text** - Review descriptions
4. **Form error messages** - Test with invalid input
5. **Custom ARIA widgets** - Verify behavior

### Excluded Checks

- Social media links (allowed 404s)
- Anchor links with hashes

## Troubleshooting

### "Connection refused" or "Server not running"

**Problem:** Jekyll server not running

**Solution:** Start server in another terminal:
```bash
make serve
```

### "Cannot connect to Docker daemon"

**Problem:** Docker not running

**Solution:** Start Docker daemon:
```bash
sudo systemctl start docker  # Linux
# Or start Docker Desktop on macOS/Windows
```

### Docker build fails

**Problem:** Network issues or missing dependencies

**Solution:** Rebuild from scratch:
```bash
docker rmi bitprepared-a11y:latest
make docker-build-a11y
```

### Reports not generated

**Problem:** Permission issues or container errors

**Solution:** Fix directory permissions:
```bash
chmod -R 755 docs/accessibility/reports/
```

### "host.docker.internal" not working

**Problem:** Docker networking issue on Linux

**Solution:** Use `--network=host` (add to docker run commands in Makefile)

## Additional Resources

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [Lighthouse Accessibility Documentation](https://developer.chrome.com/docs/lighthouse/accessibility/)
- [axe-core Documentation](https://www.deque.com/axe/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

## Next Steps

After running automated tests:

1. **Review reports** - Check JSON files or use jq for summaries
2. **Prioritize issues** - Fix critical first, then major
3. **Manual testing** - Keyboard navigation, screen readers
4. **Implement fixes** - Update Jekyll templates/CSS
5. **Re-test** - Verify improvements with `make accessibility-audit`
6. **Document** - Update this README with learnings

## File Structure

```
docker/accessibility/
├── Dockerfile              # Container definition (Node.js 20)
└── scripts/
    ├── accessibility-audit.js       # Single page audit
    └── accessibility-full-audit.js  # Multi-page audit

docs/accessibility/
├── README.md              # This file
└── reports/
    ├── lighthouse/        # Lighthouse results (JSON)
    └── axe/              # axe-core results (JSON)
```

## Environment Variables

- `SITE_URL` - Target URL to audit (default: `http://host.docker.internal:4000`)
- `CHROME_PATH` - Path to Chrome binary (auto-detected in container)

## Analyzing Reports

### Quick Summary

```bash
make accessibility-analyze
```

Generates a markdown summary with:
- Lighthouse score
- Failed audits
- axe-core violations
- Top priority fixes

### Quick Score Check

```bash
make accessibility-score
```

Shows:
- Lighthouse accessibility percentage
- Number of axe-core violations

### Manual Analysis with jq

**Lighthouse score:**
```bash
cat docs/accessibility/reports/lighthouse/homepage | jq '.categories.accessibility.score * 100'
```

**Failed audits:**
```bash
cat docs/accessibility/reports/lighthouse/homepage | jq '.audits | to_entries[] | select(.value.score == 0) | {id: .key, title: .value.title}'
```

**axe-core violations by impact:**
```bash
cat docs/accessibility/reports/axe/homepage.json | jq '.violations | group_by(.impact) | map({impact: .[0].impact, count: length})'
```

**Critical violations only:**
```bash
cat docs/accessibility/reports/axe/homepage.json | jq '.violations[] | select(.impact == "critical") | {id, description, nodes: (.nodes | length)}'
```

**Violations with URLs:**
```bash
cat docs/accessibility/reports/axe/homepage.json | jq '.violations[] | {id: .id, impact: .impact, help: .helpUrl}'
```

### Full Report Analysis

```bash
# Generate comprehensive markdown report
./scripts/analyze-a11y-reports.sh docs/accessibility/reports > accessibility-summary.md

# View in browser (if you have markdown viewer)
cat accessibility-summary.md
```

### Example Output

```
## Lighthouse Score
**Overall:** 96%

### Failed Audits:
- **Images do not have [alt] attributes**
  - Decorative images should have alt="" 
- **Links do not have a discernible name**
  - Links must have text content or aria-label

## axe-core Violations
**Total Violations:** 3

### Critical Issues:
- **color-contrast** (impact: critical)
  - Elements must have sufficient color contrast
  - Nodes affected: 5

### Quick Fixes
1. **Fix low contrast text**
   - Violation: color-contrast
   - Help: https://dequeuniversity.com/rules/axe/4.8/color-contrast
```

## Troubleshooting Reports

### "No report found"

Run audit first:
```bash
make accessibility-audit
```

### "Cannot parse JSON"

Check file exists:
```bash
ls -la docs/accessibility/reports/lighthouse/
ls -la docs/accessibility/reports/axe/
```

### Large file size

Normal - reports contain full DOM snapshots:
```bash
# Check sizes
du -h docs/accessibility/reports/*/*
```
