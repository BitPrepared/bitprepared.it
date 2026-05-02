# Visual Regression Screenshot Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Unify screenshot capture logic between baseline creation and validation to eliminate size discrepancies

**Architecture:** Extract common screenshot logic into shared module, modify both scripts to use it

**Tech Stack:** Node.js, Playwright Chromium, Jekyll

---

## File Structure

```
scripts/visual-regression/
├── screenshot-utils.js       # CREATE: Shared screenshot functions
├── create-baseline.js         # MODIFY: Use shared screenshot logic
└── capture.js                 # MODIFY: Use shared screenshot logic
```

---

## Task 1: Create Shared Screenshot Utilities Module

**Files:**
- Create: `scripts/visual-regression/screenshot-utils.js`

- [ ] **Step 1: Create screenshot-utils.js with waitForImages function**

```javascript
const waitForImages = async (page, timeout = 3000) => {
  await page.evaluate((imageTimeout) => {
    const images = Array.from(document.querySelectorAll('img'));
    return Promise.all(images.map(img => {
      if (img.complete && img.naturalHeight > 0) return;
      return new Promise(resolve => {
        img.addEventListener('load', resolve);
        img.addEventListener('error', resolve);
        setTimeout(resolve, imageTimeout);
      });
    }));
  }, timeout);
};
```

- [ ] **Step 2: Add generateFilename function**

```javascript
const generateFilename = (url) => {
  return url
    .replace(/^\//, '')
    .replace(/\/$/, '')
    .replace(/\//g, '_')
    .replace(/#/g, '_hash_')
    || 'index';
};
```

- [ ] **Step 3: Add captureScreenshot function**

```javascript
const captureScreenshot = async (page, url, path) => {
  await page.goto(url, {
    waitUntil: 'networkidle',
    timeout: 30000
  });

  await waitForImages(page);
  await page.waitForTimeout(500); // Extra delay for stable rendering

  await page.screenshot({
    path: path,
    fullPage: true
  });
};
```

- [ ] **Step 4: Export functions**

```javascript
module.exports = { waitForImages, generateFilename, captureScreenshot };
```

- [ ] **Step 5: Commit shared module**

```bash
git add scripts/visual-regression/screenshot-utils.js
git commit -m "feat: add shared screenshot utilities module

- Extract common screenshot logic into reusable module
- waitForImages: handles lazy loading with configurable timeout
- generateFilename: converts URLs to consistent filenames
- captureScreenshot: unified screenshot capture workflow"
```

---

## Task 2: Modify create-baseline.js to Use Shared Module

**Files:**
- Modify: `scripts/visual-regression/create-baseline.js`

- [ ] **Step 1: Add import for screenshot-utils at top of file**

```javascript
const { captureScreenshot, generateFilename } = require('./screenshot-utils');
```

- [ ] **Step 2: Remove inline wait logic (lines 109-124)**

Delete the entire if/else block:
```javascript
// Homepage: wait for images to load (lazy loading issue)
if (pageUrl === '/' || pageUrl === '') {
  await page.evaluate(() => {
    const images = Array.from(document.querySelectorAll('img[loading="lazy"]'));
    images.forEach(img => img.loading = 'eager');
  });
  await page.waitForTimeout(500);
} else if (pageUrl.includes('/tags/#')) {
  await page.waitForTimeout(500);
} else {
  await page.waitForSelector('[data-visual-regression-marker="ready"]', {
    timeout: 2000
  }).catch(() => {});
}
```

Replace with nothing - delete these 16 lines.

- [ ] **Step 3: Replace page.goto() and screenshot with captureScreenshot call**

Find this code:
```javascript
await page.goto(fullUrl, {
  waitUntil: 'networkidle',
  timeout: 30000
});

// [inline wait logic to be removed]

const filename = pageUrl.replace(/^\//, '').replace(/\/$/, '').replace(/\//g, '_') || 'index';
const baselinePath = path.join(baselineBaseFolder, viewportName, `${filename}.png`);

// ... directory creation code ...

await page.screenshot({
  path: baselinePath,
  fullPage: true
});
```

Replace with:
```javascript
const filename = generateFilename(pageUrl);
const baselinePath = path.join(baselineBaseFolder, viewportName, `${filename}.png`);

const dir = path.dirname(baselinePath);
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

await captureScreenshot(page, fullUrl, baselinePath);
```

- [ ] **Step 4: Commit create-baseline.js modifications**

```bash
git add scripts/visual-regression/create-baseline.js
git commit -m "refactor: use shared screenshot utilities in baseline creation

- Removed inline wait logic, now uses screenshot-utils
- Simplified code with shared captureScreenshot() function
- Ensures consistent screenshot capture across all visual regression"
```

---

## Task 3: Modify capture.js to Use Shared Module

**Files:**
- Modify: `scripts/visual-regression/capture.js`

- [ ] **Step 1: Add import for screenshot-utils at top of file**

```javascript
const { captureScreenshot, generateFilename } = require('./screenshot-utils');
```

- [ ] **Step 2: Remove inline waitForImages function (lines 91-104)**

Delete this entire function:
```javascript
// Wait for all images to load (handles lazy loading)
await page.evaluate(() => {
  const images = Array.from(document.querySelectorAll('img'));
  return Promise.all(images.map(img => {
    if (img.complete && img.naturalHeight > 0) return;
    return new Promise(resolve => {
      img.addEventListener('load', resolve);
      img.addEventListener('error', resolve);
      setTimeout(resolve, 3000);
    });
  }));
});
```

- [ ] **Step 3: Replace page.goto(), wait logic, and screenshot with captureScreenshot call**

Find this code:
```javascript
await page.goto(fullUrl, {
  waitUntil: 'networkidle',
  timeout: 30000
});

// Wait for all images to load (handles lazy loading)
await page.evaluate(() => {
  const images = Array.from(document.querySelectorAll('img'));
  return Promise.all(images.map(img => {
    if (img.complete && img.naturalHeight > 0) return;
    return new Promise(resolve => {
      img.addEventListener('load', resolve);
      img.addEventListener('error', resolve);
      setTimeout(resolve, 3000);
    });
  }));
});

// Extra delay for stable rendering
await page.waitForTimeout(500);

const filename = pageUrl.replace(/^\//, '').replace(/\/$/, '').replace(/\//g, '_') || 'index';
const screenshotPath = path.join(__dirname, `../../screenshots/${serverType}/${viewportName}/${filename}.png`);
```

Replace with:
```javascript
const filename = generateFilename(pageUrl);
const screenshotPath = path.join(__dirname, `../../screenshots/${serverType}/${viewportName}/${filename}.png`);

const dir = path.dirname(screenshotPath);
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}

await captureScreenshot(page, fullUrl, screenshotPath);
```

- [ ] **Step 4: Commit capture.js modifications**

```bash
git add scripts/visual-regression/capture.js
git commit -m "refactor: use shared screenshot utilities in validation capture

- Removed inline waitForImages function, now uses screenshot-utils
- Simplified code with shared captureScreenshot() function
- Ensures validation uses identical logic as baseline creation"
```

---

## Task 4: Update Docker Image (User Action Required)

**Files:**
- Modify: `scripts/visual-regression/Dockerfile` (if needed)

- [ ] **Step 1: Check if screenshot-utils.js needs to be copied in Dockerfile**

Run: `cat scripts/visual-regression/Dockerfile`

If screenshot-utils.js is not copied to Docker image, add COPY instruction.

- [ ] **Step 2: User rebuilds Docker image**

User executes:
```bash
make docker-build-visual
```

- [ ] **Step 3: Verify Docker image includes screenshot-utils.js**

User verifies by checking Docker image contents.

---

## Task 5: Testing and Validation

**Files:**
- Test: Manual testing by user

- [ ] **Step 1: User creates new baseline**

User executes:
```bash
make serve-bg
make visual-baseline
make stop-serve
```

- [ ] **Step 2: User validates against new baseline**

User executes:
```bash
make serve-bg
make validate-graphics
make stop-servers
```

- [ ] **Step 3: Verify identical sizes**

Check console output for size mismatches. All pages should show identical sizes.

- [ ] **Step 4: Test problematic pages specifically**

User checks these pages specifically:
- desktop/eventi/
- desktop/eventi_epppi/
- desktop/eventi_campo-eg/

All should show "✅ All tests PASSED".

- [ ] **Step 5: Commit successful implementation**

If tests pass:
```bash
git add docs/superpowers/plans/2026-05-02-visual-regression-unification.md
git commit -m "docs: complete visual regression unification

All tests passing:
✅ Baseline and validation use identical screenshot logic
✅ No size discrepancies
✅ Single source of truth for image wait logic"
```

---

## Testing Strategy

### Manual Testing (User executes)

```bash
# 1. Build site
make build

# 2. Create baseline
make serve-bg
make visual-baseline
make stop-serve

# 3. Validate immediately after
make serve-bg
make validate-graphics
make stop-servers

# 4. Check sizes are identical
# Should see: ✅ All tests PASSED
```

### Verification Points

1. **Code consistency**: Both scripts import same module
2. **Screenshot sizes**: Baseline and validation identical for all pages
3. **Problematic pages**: /eventi/, /eventi_epppi/, /eventi_campo-eg/ show no size difference
4. **No false positives**: All validation tests pass

---

## Next Steps

**Phase 3 Complete** ✅ with visual regression unification.

Success metrics:
- Zero size discrepancies between baseline and validation
- Single source of truth for screenshot capture
- Easy to debug and extend

---

**Piano**: 2026-05-02-visual-regression-unification.md
**Stato**: READY FOR IMPLEMENTATION
**Prerequisiti**: Node.js, Playwright, Docker (user executes)
**Dipendenze**: None new
