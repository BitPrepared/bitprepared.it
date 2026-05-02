# Visual Regression Screenshot Unification Design

> **Status:** APPROVED
> **Date:** 2026-05-02

## Problem Statement

Visual regression testing has inconsistent screenshot sizes between baseline creation and validation:
- `make visual-baseline` uses one logic (create-baseline.js)
- `make validate-graphics` uses different logic (capture.js)
- Result: Different page heights → false positives

**Root Cause**: Three separate implementations exist:
1. `create-baseline.js` - Homepage: eager loading, hash pages: timeout, others: marker wait
2. `capture.js` - All pages: uniform wait for lazy images
3. `compare.js` - Only compares, doesn't capture

## Solution

Extract common screenshot logic into shared module.

## Architecture

### New Module: `screenshot-utils.js`

**Location**: `scripts/visual-regression/screenshot-utils.js`

**Exports**:
- `waitForImages(page, timeout = 3000)` - Wait for lazy images to load
- `generateFilename(url)` - Convert URL to filename
- `captureScreenshot(page, url, path)` - Full capture workflow

### Modified Files

**`create-baseline.js`**:
- Remove inline wait logic (lines 109-124)
- Import from `screenshot-utils.js`
- Use shared captureScreenshot()

**`capture.js`**:
- Extract wait logic into shared module
- Import and use shared functions

### Implementation Details

**waitForImages()**:
- Selects all `img` elements
- Waits for load/error with configurable timeout
- Checks `img.complete && img.naturalHeight > 0`
- Returns Promise when all images resolved

**generateFilename()**:
- Normalizes URL: remove leading/trailing slashes, convert / to _, # to _hash_
- Returns 'index' for root path

**captureScreenshot()**:
- Navigates to URL with networkidle wait
- Calls waitForImages()
- Extra 500ms delay for stable rendering
- Takes fullPage screenshot

## Success Criteria

- ✅ Both baseline and validation use identical screenshot logic
- ✅ No more size discrepancies from different loading strategies
- ✅ Single source of truth for image wait logic
- ✅ Easy to debug with centralized logging

## Implementation Notes

- Timeout default 3000ms per image
- Extra 500ms global delay after images
- Full page capture (not viewport only)
- Error handling in calling functions

## Testing Strategy

1. Create baseline with new unified logic
2. Run validation immediately after
3. Verify identical sizes for all pages
4. Test on problematic pages: /eventi/, /eventi/epppi/, /eventi/campo-eg/

**Important**: Docker/make commands must be executed by user, not in implementation.
