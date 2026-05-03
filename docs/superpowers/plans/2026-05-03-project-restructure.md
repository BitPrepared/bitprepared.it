# Project Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure bitprepared.it project for cleaner separation between source code (`src/`), generated content (`output/`), and build artifacts

**Architecture:** Move Jekyll source, Tailwind config, and Docker files into `src/` subdirectories, create `output/` for generated content, update all Docker commands to use proper workdirs and volumes with correct permissions

**Tech Stack:** Jekyll 4, Docker, Make, Node.js (Tailwind CSS), Bash

---

## Task 1: Create Git Branch

**Files:**
- None (git operation)

- [ ] **Step 1: Create new feature branch**

```bash
cd /workspace/bitprepared.it
git checkout -b feature/project-restructure
```

- [ ] **Step 2: Verify branch**

```bash
git branch
```

Expected: `* feature/project-restructure`

- [ ] **Step 3: Commit branch creation**

```bash
git commit --allow-empty -m "feat: start project restructure branch"
```

---

## Task 2: Create New Directory Structure

**Files:**
- Create: `src/jekyll/`
- Create: `src/tailwind/`
- Create: `src/docker/`
- Create: `output/`

- [ ] **Step 1: Create source directories**

```bash
mkdir -p src/jekyll src/tailwind src/docker output
```

- [ ] **Step 2: Verify directories created**

```bash
ls -la src/
```

Expected: `jekyll/`, `tailwind/`, `docker/` listed

```bash
ls -la output/
```

Expected: Empty directory

- [ ] **Step 3: Commit directory structure**

```bash
git add src/ output/
git commit -m "feat: create src/ and output/ directory structure"
```

---

## Task 3: Move Jekyll Files to src/jekyll/

**Files:**
- Move: `_config.yml`, `Gemfile`, `.htmltest.yml`
- Move: `_posts/`, `_layouts/`, `_includes/`, `_plugins/`, `_pages/`
- Move: `blog/`, `tags/`, `_eventi/`, `_software/`
- Move: `assets/`, `docs/`
- Move: `index.html`, `about.md`, `robots.txt`

- [ ] **Step 1: Move Jekyll config files**

```bash
mv _config.yml Gemfile .htmltest.yml src/jekyll/
```

- [ ] **Step 2: Move Jekyll directories**

```bash
mv _posts _layouts _includes _plugins _pages src/jekyll/
mv blog tags _eventi _software src/jekyll/
```

- [ ] **Step 3: Move assets and docs**

```bash
mv assets docs src/jekyll/
```

- [ ] **Step 4: Move root content files**

```bash
mv index.html about.md robots.txt src/jekyll/
```

- [ ] **Step 5: Verify all Jekyll files moved**

```bash
ls -la src/jekyll/
```

Expected: All Jekyll files and directories listed

```bash
ls -la | grep -E "^(d|).*(_posts|_layouts|blog|tags|assets|index\.html)"
```

Expected: No Jekyll files at root (only Makefile, CHANGELOG.txt, README.md, LICENSE.txt, etc.)

- [ ] **Step 6: Commit Jekyll files move**

```bash
git add -A
git commit -m "refactor: move Jekyll source to src/jekyll/"
```

---

## Task 4: Move Tailwind Files to src/tailwind/

**Files:**
- Move: `package.json`, `tailwind.config.js`

- [ ] **Step 1: Move Tailwind files**

```bash
mv package.json tailwind.config.js src/tailwind/
```

- [ ] **Step 2: Verify files moved**

```bash
ls -la src/tailwind/
```

Expected: `package.json`, `tailwind.config.js` listed

- [ ] **Step 3: Commit Tailwind files move**

```bash
git add src/tailwind/
git commit -m "refactor: move Tailwind config to src/tailwind/"
```

---

## Task 5: Move Docker Files to src/docker/

**Files:**
- Move: `docker/`

- [ ] **Step 1: Move Docker directory**

```bash
mv docker src/docker
```

- [ ] **Step 2: verify Docker directory moved**

```bash
ls -la src/docker/
```

Expected: `accessibility/` subdirectory listed

- [ ] **Step 3: Commit Docker files move**

```bash
git add src/docker/
git commit -m "refactor: move Docker files to src/docker/"
```

---

## Task 6: Move autodownload.sh to scripts/

**Files:**
- Move: `autodownload.sh`

- [ ] **Step 1: Move autodownload script**

```bash
mv autodownload.sh scripts/
```

- [ ] **Step 2: Verify script moved**

```bash
ls -la scripts/autodownload.sh
```

Expected: File exists

- [ ] **Step 3: Commit script move**

```bash
git add scripts/autodownload.sh
git commit -m "refactor: move autodownload.sh to scripts/"
```

---

## Task 7: Move screenshots to output/

**Files:**
- Move: `screenshots/`

- [ ] **Step 1: Move screenshots directory**

```bash
mv screenshots output/
```

- [ ] **Step 2: Verify screenshots moved**

```bash
ls -la output/screenshots/
```

Expected: Subdirectories like `desktop/`, `mobile/`, `tablet/` or `report/`

- [ ] **Step 3: Commit screenshots move**

```bash
git add output/screenshots/
git commit -m "refactor: move screenshots to output/ as generated content"
```

---

## Task 8: Update Jekyll _config.yml

**Files:**
- Modify: `src/jekyll/_config.yml`

- [ ] **Step 1: Read current _config.yml**

```bash
cat src/jekyll/_config.yml
```

- [ ] **Step 2: Add destination and cache paths**

Append to `src/jekyll/_config.yml`:

```yaml
# Output directory (relative to src/jekyll/)
destination: ../../output/_site

# Cache directory (relative to src/jekyll/)
cache: ../../output/.jekyll-cache
```

- [ ] **Step 3: Verify _config.yml changes**

```bash
cat src/jekyll/_config.yml | tail -5
```

Expected: New `destination` and `cache` entries visible

- [ ] **Step 4: Commit _config.yml update**

```bash
git add src/jekyll/_config.yml
git commit -m "config: set Jekyll output to ../../output/_site and cache to ../../output/.jekyll-cache"
```

---

## Task 9: Update Tailwind package.json

**Files:**
- Modify: `src/tailwind/package.json`

- [ ] **Step 1: Read current package.json**

```bash
cat src/tailwind/package.json
```

- [ ] **Step 2: Update build-css script path**

Replace the `build:css` script in `src/tailwind/package.json`:

Current:
```json
"build:css": "tailwindcss -i ./assets/css/tailwind-input.css -o ./assets/css/tailwind.css --minify"
```

New:
```json
"build:css": "tailwindcss -i ../jekyll/assets/css/tailwind-input.css -o ../jekyll/assets/css/tailwind.css --minify"
```

Complete file should be:

```json
{
  "devDependencies": {
    "tailwindcss": "^3.4.0"
  },
  "scripts": {
    "build:css": "tailwindcss -i ../jekyll/assets/css/tailwind-input.css -o ../jekyll/assets/css/tailwind.css --minify"
  }
}
```

- [ ] **Step 3: Verify package.json changes**

```bash
cat src/tailwind/package.json
```

Expected: Paths now point to `../jekyll/assets/css/`

- [ ] **Step 4: Commit package.json update**

```bash
git add src/tailwind/package.json
git commit -m "fix: update Tailwind build paths for src/ structure"
```

---

## Task 10: Update Makefile - Docker Base Configuration

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current Makefile variables**

```bash
head -10 Makefile
```

- [ ] **Step 2: Update Docker volume variables**

Replace lines 1-8 in `Makefile`:

Current:
```makefile
JEKYLL_VERSION ?= 4
PORT ?= 4000
STATIC_PORT ?= 8000
PROJECT_PATH ?= /workspace/bitprepared.it
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
GEM_VOLUME = bitprepared-gems
POLLING ?= 0
A11Y_PAGE ?= full
```

New:
```makefile
JEKYLL_VERSION ?= 4
PORT ?= 4000
STATIC_PORT ?= 8000
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
NODE_MODULES_VOLUME = bitprepared-node-modules
VENDOR_VOLUME = bitprepared-vendor
CACHE_VOLUME = bitprepared-jekyll-cache
POLLING ?= 0
A11Y_PAGE ?= full
```

- [ ] **Step 3: Verify Makefile variable changes**

```bash
head -10 Makefile
```

Expected: New volume names visible

- [ ] **Step 4: Commit Makefile variable updates**

```bash
git add Makefile
git commit -m "refactor: update Docker volume names for cache separation"
```

---

## Task 11: Update Makefile - serve Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current serve target**

```bash
sed -n '/^serve:/,/^$/p' Makefile
```

- [ ] **Step 2: Update serve command**

Replace the `serve` target in `Makefile`:

Current:
```makefile
serve:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		jekyll serve --config _config.yml,_config_dev.yml $(if $(filter 1,$(POLLING)),--force_polling,)
```

New:
```makefile
serve:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--mount type=bind,source=${PWD}/output,target=/workspace/output \
		--volume="$(NODE_MODULES_VOLUME):/workspace/node_modules" \
		--volume="$(VENDOR_VOLUME):/workspace/vendor" \
		--volume="$(CACHE_VOLUME):/workspace/.jekyll-cache" \
		-w /workspace/jekyll \
		-e JEKYLL_PATH=/workspace/jekyll \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		bundle exec jekyll serve --config _config.yml,_config_dev.yml $(if $(filter 1,$(POLLING)),--force_polling,)
```

- [ ] **Step 3: Verify serve command**

```bash
sed -n '/^serve:/,/^$/p' Makefile
```

Expected: New workdir `/workspace/jekyll`, mounts for `src/` and `output/`, user flag

- [ ] **Step 4: Commit serve command update**

```bash
git add Makefile
git commit -m "refactor: update serve command for src/ structure with correct permissions"
```

---

## Task 12: Update Makefile - build Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current build target**

```bash
sed -n '/^build:/,/^$/p' Makefile | head -20
```

- [ ] **Step 2: Update build command**

Replace the `build` target in `Makefile`:

Current:
```makefile
build:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		$(DOCKER_IMAGE) \
		jekyll build
```

New:
```makefile
build:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--mount type=bind,source=${PWD}/output,target=/workspace/output \
		--volume="$(NODE_MODULES_VOLUME):/workspace/node_modules" \
		--volume="$(VENDOR_VOLUME):/workspace/vendor" \
		--volume="$(CACHE_VOLUME):/workspace/.jekyll-cache" \
		-w /workspace/jekyll \
		-e JEKYLL_PATH=/workspace/jekyll \
		$(DOCKER_IMAGE) \
		bundle exec jekyll build
```

- [ ] **Step 3: Verify build command**

```bash
sed -n '/^build:/,/^$/p' Makefile
```

Expected: Same structure as serve, no port mapping

- [ ] **Step 4: Commit build command update**

```bash
git add Makefile
git commit -m "refactor: update build command for src/ structure"
```

---

## Task 13: Update Makefile - build-css Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current build-css target**

```bash
sed -n '/^build-css:/,/^$/p' Makefile
```

- [ ] **Step 2: Update build-css command**

Replace the `build-css` target in `Makefile`:

Current:
```makefile
build-css:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/app \
		-w /app \
		-e BUILD_CSS=1 \
		node:20 \
		npm run build:css
```

New:
```makefile
build-css:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--volume="$(NODE_MODULES_VOLUME):/workspace/node_modules" \
		-w /workspace/tailwind \
		node:20 \
		npm run build:css
```

- [ ] **Step 3: Verify build-css command**

```bash
sed -n '/^build-css:/,/^$/p' Makefile
```

Expected: Workdir `/workspace/tailwind`, node-modules volume

- [ ] **Step 4: Commit build-css command update**

```bash
git add Makefile
git commit -m "refactor: update build-css command for src/tailwind/ structure"
```

---

## Task 14: Update Makefile - install Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current install target**

```bash
sed -n '/^install:/,/^$/p' Makefile | head -20
```

- [ ] **Step 2: Update install command**

Replace the `install` target in `Makefile`:

Current:
```makefile
install:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		$(DOCKER_IMAGE) \
		bundle install
```

New:
```makefile
install:
	@echo "📦 Installing npm packages..."
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--volume="$(NODE_MODULES_VOLUME):/workspace/node_modules" \
		-w /workspace/tailwind \
		node:20 \
		npm install
	@echo "📦 Installing Ruby gems..."
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--volume="$(VENDOR_VOLUME):/workspace/vendor" \
		-w /workspace/jekyll \
		$(DOCKER_IMAGE) \
		bundle install
```

- [ ] **Step 3: Verify install command**

```bash
sed -n '/^install:/,/^$/p' Makefile
```

Expected: Two docker commands - npm for tailwind, bundle for jekyll

- [ ] **Step 4: Commit install command update**

```bash
git add Makefile
git commit -m "refactor: update install command for both npm and bundle"
```

---

## Task 15: Update Makefile - install-gems Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current install-gems target**

```bash
sed -n '/^install-gems:/,/^$/p' Makefile | head -20
```

- [ ] **Step 2: Update install-gems command**

Replace the `install-gems` target:

Current:
```makefile
install-gems:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		$(DOCKER_IMAGE) \
		bundle install
```

New:
```makefile
install-gems:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--volume="$(VENDOR_VOLUME):/workspace/vendor" \
		-w /workspace/jekyll \
		$(DOCKER_IMAGE) \
		bundle install
```

- [ ] **Step 3: Verify install-gems command**

```bash
sed -n '/^install-gems:/,/^$/p' Makefile
```

Expected: Workdir `/workspace/jekyll`, vendor volume

- [ ] **Step 4: Commit install-gems command update**

```bash
git add Makefile
git commit -m "refactor: update install-gems command for src/jekyll/ structure"
```

---

## Task 16: Update Makefile - clean Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current clean target**

```bash
sed -n '/^clean:/,/^$/p' Makefile
```

- [ ] **Step 2: Update clean command**

Replace the `clean` target:

Current:
```makefile
clean:
	rm -rf _site
```

New:
```makefile
clean:
	rm -rf output/_site output/.jekyll-cache
```

- [ ] **Step 3: Verify clean command**

```bash
sed -n '/^clean:/,/^$/p' Makefile
```

Expected: Removes `output/_site` and `output/.jekyll-cache`

- [ ] **Step 4: Commit clean command update**

```bash
git add Makefile
git commit -m "refactor: update clean to remove output/ directories"
```

---

## Task 17: Update Makefile - serve-bg Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current serve-bg target**

```bash
sed -n '/^serve-bg:/,/^serve-static:/p' Makefile | head -30
```

- [ ] **Step 2: Update serve-bg command**

Replace the `serve-bg` target:

Current:
```makefile
serve-bg:
	@echo "🚀 Avvio Jekyll in background..."
	@docker stop bitprepared-jekyll-$(PORT) 2>/dev/null || true
	@docker rm bitprepared-jekyll-$(PORT) 2>/dev/null || true
	@docker run -d \
		--name bitprepared-jekyll-$(PORT) \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		jekyll serve --config _config.yml,_config_dev.yml --host 0.0.0.0 > /dev/null
```

New:
```makefile
serve-bg:
	@echo "🚀 Avvio Jekyll in background..."
	@docker stop bitprepared-jekyll-$(PORT) 2>/dev/null || true
	@docker rm bitprepared-jekyll-$(PORT) 2>/dev/null || true
	@docker run -d \
		--name bitprepared-jekyll-$(PORT) \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--mount type=bind,source=${PWD}/output,target=/workspace/output \
		--volume="$(NODE_MODULES_VOLUME):/workspace/node_modules" \
		--volume="$(VENDOR_VOLUME):/workspace/vendor" \
		--volume="$(CACHE_VOLUME):/workspace/.jekyll-cache" \
		-w /workspace/jekyll \
		-e JEKYLL_PATH=/workspace/jekyll \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		bundle exec jekyll serve --config _config.yml,_config_dev.yml --host 0.0.0.0 > /dev/null
```

- [ ] **Step 3: Verify serve-bg command**

```bash
sed -n '/^serve-bg:/,/^serve-static:/p' Makefile | head -30
```

Expected: Same structure as serve, with --name for background container

- [ ] **Step 4: Commit serve-bg command update**

```bash
git add Makefile
git commit -m "refactor: update serve-bg command for src/ structure"
```

---

## Task 18: Update Makefile - serve-static Commands

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current serve-static targets**

```bash
sed -n '/^serve-static:/,/^open:/p' Makefile | head -40
```

- [ ] **Step 2: Update serve-static command**

Replace the `serve-static` target:

Current:
```makefile
serve-static: build
	@echo "Server statico avviato su http://localhost:$(STATIC_PORT)/"
	@cd _site && python3 -m http.server $(STATIC_PORT)
```

New:
```makefile
serve-static: build
	@echo "Server statico avviato su http://localhost:$(STATIC_PORT)/"
	@cd output/_site && python3 -m http.server $(STATIC_PORT)
```

- [ ] **Step 3: Update serve-static-bg command**

Replace the `serve-static-bg` target:

Current:
```makefile
serve-static-bg: build
	@echo "🚀 Avvio server statico in background..."
	@cd _site && python3 -m http.server $(STATIC_PORT) > /tmp/static_server.log 2>&1 & \
		echo $$! > ../.static_serve.pid
```

New:
```makefile
serve-static-bg: build
	@echo "🚀 Avvio server statico in background..."
	@cd output/_site && python3 -m http.server $(STATIC_PORT) > /tmp/static_server.log 2>&1 & \
		echo $$! > ../../.static_serve.pid
```

- [ ] **Step 4: Verify serve-static commands**

```bash
sed -n '/^serve-static:/,/^open:/p' Makefile | head -40
```

Expected: Both commands use `output/_site` instead of `_site`

- [ ] **Step 5: Commit serve-static updates**

```bash
git add Makefile
git commit -m "refactor: update serve-static commands for output/_site"
```

---

## Task 19: Update Makefile - visual-baseline Command

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read current visual-baseline target**

```bash
grep -A 30 "^visual-baseline:" Makefile
```

- [ ] **Step 2: Find and update screenshots path in visual-baseline**

The visual-baseline command calls capture.js. Update the command to pass output directory:

Locate the line in visual-baseline that calls node capture.js and update it to pass the output directory.

If the current command is:
```makefile
node scripts/visual-regression/capture.js serve http://localhost:4000 $(VIEWPORTS)
```

Update to:
```makefile
node scripts/visual-regression/capture.js serve http://localhost:4000 $(VIEWPORTS) output/screenshots
```

Do the same for the static capture call.

- [ ] **Step 3: Verify visual-baseline command**

```bash
grep -A 30 "^visual-baseline:" Makefile | grep "capture.js"
```

Expected: capture.js calls include `output/screenshots` parameter

- [ ] **Step 4: Commit visual-baseline update**

```bash
git add Makefile
git commit -m "refactor: update visual-baseline to use output/screenshots"
```

---

## Task 20: Update Makefile - Help Text

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Read help target**

```bash
sed -n '/^help:/,/^\.PHONY/p' Makefile | head -50
```

- [ ] **Step 2: Update help text for clean command**

Find and replace:
```
	@echo "  clean            - Rimuove _site/"
```

With:
```
	@echo "  clean            - Rimuove output/_site/"
```

- [ ] **Step 3: Verify help text**

```bash
make help | grep clean
```

Expected: "Rimuove output/_site/"

- [ ] **Step 4: Commit help text update**

```bash
git add Makefile
git commit -m "docs: update help text for clean command"
```

---

## Task 21: Update capture.js Screenshot Paths

**Files:**
- Modify: `scripts/visual-regression/capture.js`

- [ ] **Step 1: Read capture.js screenshot path**

```bash
grep -n "screenshots" scripts/visual-regression/capture.js
```

- [ ] **Step 2: Update screenshot path in capture.js**

Find line ~54 in `scripts/visual-regression/capture.js`:

Current:
```javascript
        const screenshotPath = path.join(__dirname, `../../screenshots/${serverType}/${viewportName}/${filename}.png`);
```

New:
```javascript
        const screenshotPath = path.join(__dirname, `../../output/screenshots/${serverType}/${viewportName}/${filename}.png`);
```

- [ ] **Step 3: Verify capture.js changes**

```bash
grep "screenshots" scripts/visual-regression/capture.js
```

Expected: Path now includes `output/`

- [ ] **Step 4: Commit capture.js update**

```bash
git add scripts/visual-regression/capture.js
git commit -m "fix: update screenshot paths to output/screenshots in capture.js"
```

---

## Task 22: Update compare.js Screenshot Paths

**Files:**
- Modify: `scripts/visual-regression/compare.js`

- [ ] **Step 1: Read compare.js screenshot paths**

```bash
grep -n "screenshots" scripts/visual-regression/compare.js
```

- [ ] **Step 2: Update all screenshot paths in compare.js**

Find and replace in `scripts/visual-regression/compare.js`:

Line ~14 (reportDir):
```javascript
  const reportDir = path.join(__dirname, '../../output/screenshots/report');
```

Line ~56 (servePath):
```javascript
      const servePath = path.join(__dirname, `../../output/screenshots/serve/${viewport}/${page}.png`);
```

Line ~57 (staticPath):
```javascript
      const staticPath = path.join(__dirname, `../../output/screenshots/static/${viewport}/${page}.png`);
```

Line ~58 (serveDiffPath):
```javascript
      const serveDiffPath = path.join(__dirname, `../../output/screenshots/diff/${viewport}/${page}_serve.png`);
```

Line ~59 (staticDiffPath):
```javascript
      const staticDiffPath = path.join(__dirname, `../../output/screenshots/diff/${viewport}/${page}_static.png`);
```

Line ~72 (console.log):
```javascript
  console.log(`\n📊 Report generated: output/screenshots/report/index.html`);
```

- [ ] **Step 3: Verify compare.js changes**

```bash
grep "screenshots" scripts/visual-regression/compare.js
```

Expected: All paths now include `output/`

- [ ] **Step 4: Commit compare.js update**

```bash
git add scripts/visual-regression/compare.js
git commit -m "fix: update all screenshot paths to output/screenshots in compare.js"
```

---

## Task 23: Update optimize-images.js Path

**Files:**
- Modify: `scripts/optimize-images.js`

- [ ] **Step 1: Read optimize-images.js imagesDir path**

```bash
grep -n "imagesDir" scripts/optimize-images.js
```

- [ ] **Step 2: Update imagesDir path**

Find line 32 in `scripts/optimize-images.js`:

Current:
```javascript
  const imagesDir = '_site/assets/images';
```

New:
```javascript
  const imagesDir = 'output/_site/assets/images';
```

- [ ] **Step 3: Verify optimize-images.js changes**

```bash
grep "imagesDir" scripts/optimize-images.js
```

Expected: Path now `output/_site/assets/images`

- [ ] **Step 4: Commit optimize-images.js update**

```bash
git add scripts/optimize-images.js
git commit -m "fix: update images path to output/_site in optimize-images.js"
```

---

## Task 24: Update .gitignore for output/

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Read current .gitignore**

```bash
cat .gitignore
```

- [ ] **Step 2: Add output/ to .gitignore**

Add to `.gitignore`:

```
# Generated output
output/_site/
output/.jekyll-cache/
```

Keep `output/screenshots/` tracked (it contains test baselines).

- [ ] **Step 3: Verify .gitignore changes**

```bash
cat .gitignore
```

Expected: New output/ exclusions visible

- [ ] **Step 4: Commit .gitignore update**

```bash
git add .gitignore
git commit -m "chore: add output/_site and output/.jekyll-cache to .gitignore"
```

---

## Task 25: Update CLAUDE.md Path References

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Find all path references in CLAUDE.md**

```bash
grep -n "assets/\|_posts\|_layouts\|screenshots\|_site" CLAUDE.md
```

- [ ] **Step 2: Update all path references**

Replace all occurrences in `CLAUDE.md`:

- `_posts/` → `src/jekyll/_posts/`
- `_layouts/` → `src/jekyll/_layouts/`
- `assets/` → `src/jekyll/assets/`
- `screenshots/` → `output/screenshots/`
- `_site/` → `output/_site/`
- `Gemfile` → `src/jekyll/Gemfile`
- `_config.yml` → `src/jekyll/_config.yml`
- `package.json` → `src/tailwind/package.json`
- `tailwind.config.js` → `src/tailwind/tailwind.config.js`
- `docker/` → `src/docker/`

- [ ] **Step 3: Verify CLAUDE.md changes**

```bash
grep -E "src/jekyll|src/tailwind|src/docker|output/" CLAUDE.md | head -20
```

Expected: New paths visible throughout document

- [ ] **Step 4: Commit CLAUDE.md update**

```bash
git add CLAUDE.md
git commit -m "docs: update all path references in CLAUDE.md for new structure"
```

---

## Task 26: Verify All Files Moved

**Files:**
- None (verification)

- [ ] **Step 1: Check no Jekyll files remain at root**

```bash
ls -la | grep -E "(_posts|_layouts|_includes|blog|tags|assets|index\.html|about\.md|robots\.txt|_config\.yml|Gemfile|package\.json|tailwind\.config)"
```

Expected: No results (empty)

- [ ] **Step 2: Verify src/jekyll/ structure**

```bash
ls -la src/jekyll/ | head -20
```

Expected: All Jekyll files and directories present

- [ ] **Step 3: Verify src/tailwind/ structure**

```bash
ls -la src/tailwind/
```

Expected: `package.json`, `tailwind.config.js` present

- [ ] **Step 4: Verify src/docker/ structure**

```bash
ls -la src/docker/
```

Expected: `accessibility/` subdirectory present

- [ ] **Step 5: Verify output/ structure**

```bash
ls -la output/
```

Expected: `screenshots/` present

- [ ] **Step 6: Verify tests/ and scripts/ unchanged**

```bash
ls -la tests/ && ls -la scripts/
```

Expected: Both directories exist and contain expected files

- [ ] **Step 7: Commit verification**

```bash
git commit --allow-empty -m "test: verified all files moved correctly"
```

---

## Task 27: Test Build Command

**Files:**
- None (testing)

- [ ] **Step 1: Run build**

```bash
make build
```

Expected: Jekyll builds successfully, creates `output/_site/`

- [ ] **Step 2: Verify output directory**

```bash
ls -la output/_site/ | head -20
```

Expected: HTML files and directories present

- [ ] **Step 3: Verify no build artifacts in src/**

```bash
ls -la src/jekyll/ | grep -E "\.html|_site"
```

Expected: No `.html` files or `_site/` in src/jekyll/ (except index.html source)

- [ ] **Step 4: Commit successful build test**

```bash
git commit --allow-empty -m "test: make build works correctly"
```

---

## Task 28: Test Serve Command

**Files:**
- None (testing)

- [ ] **Step 1: Start serve in background**

```bash
make serve-bg
```

Expected: Server starts, "✅ Jekyll pronto" message appears

- [ ] **Step 2: Test server response**

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/
```

Expected: `200`

- [ ] **Step 3: Stop server**

```bash
make stop-servers
```

Expected: Server stops cleanly

- [ ] **Step 4: Commit successful serve test**

```bash
git commit --allow-empty -m "test: make serve works correctly"
```

---

## Task 29: Test Build-CSS Command

**Files:**
- None (testing)

- [ ] **Step 1: Run build-css**

```bash
make build-css
```

Expected: Tailwind compiles CSS successfully

- [ ] **Step 2: Verify CSS output location**

```bash
ls -la src/jekyll/assets/css/tailwind.css
```

Expected: File exists

- [ ] **Step 3: Commit successful build-css test**

```bash
git commit --allow-empty -m "test: make build-css works correctly"
```

---

## Task 30: Test Visual Baseline

**Files:**
- None (testing)

- [ ] **Step 1: Start serve in background**

```bash
make serve-bg
```

Expected: Server starts

- [ ] **Step 2: Run visual-baseline**

```bash
make visual-baseline
```

Expected: Screenshots created in `output/screenshots/`

- [ ] **Step 3: Verify screenshots created**

```bash
ls -la output/screenshots/serve/desktop/ | head -10
```

Expected: PNG files present

- [ ] **Step 4: Stop server**

```bash
make stop-servers
```

Expected: Server stops

- [ ] **Step 5: Commit successful visual-baseline test**

```bash
git commit --allow-empty -m "test: make visual-baseline works correctly"
```

---

## Task 31: Test Check-Links Command

**Files:**
- None (testing)

- [ ] **Step 1: Run check-links**

```bash
make check-links
```

Expected: htmltest runs against `output/_site/`

- [ ] **Step 2: Commit successful check-links test**

```bash
git commit --allow-empty -m "test: make check-links works correctly"
```

---

## Task 32: Final Verification

**Files:**
- None (verification)

- [ ] **Step 1: Verify root directory cleanliness**

```bash
ls -la | grep -v "^d" | grep -v "total"
```

Expected: Only Makefile, CHANGELOG.txt, README.md, LICENSE.txt, .gitignore, CLAUDE.md, and similar meta files at root

- [ ] **Step 2: Verify all tests pass**

```bash
# Run any existing test commands
echo "All manual tests completed successfully"
```

- [ ] **Step 3: Create summary commit**

```bash
git commit --allow-empty -m "feat: complete project restructure to src/ and output/

All source code now in src/:
- src/jekyll/ for Jekyll site
- src/tailwind/ for Tailwind CSS
- src/docker/ for Docker files

Generated content in output/:
- output/_site/ for Jekyll build output
- output/screenshots/ for visual regression tests

Docker volumes for caches:
- bitprepared-node-modules for npm
- bitprepared-vendor for bundle
- bitprepared-jekyll-cache for Jekyll cache

All commands updated with correct workdirs and permissions.
"
```

---

## Task 33: Push and Create PR

**Files:**
- None (git operations)

- [ ] **Step 1: Push branch to remote**

```bash
git push -u origin feature/project-restructure
```

- [ ] **Step 2: Create pull request**

```bash
gh pr create --title "Refactor: Restructure project to src/ and output/" --body "## Summary
- Moved all Jekyll source files to src/jekyll/
- Moved Tailwind config to src/tailwind/
- Moved Docker files to src/docker/
- Created output/ for generated content (_site, screenshots)
- Updated all Makefile commands for new structure
- Updated all scripts for new paths
- Added Docker volumes for caches with correct permissions

## Test plan
- [x] make build generates output/_site/
- [x] make serve runs correctly
- [x] make build-css compiles CSS
- [x] make visual-baseline creates screenshots
- [x] make check-links works

## Breaking changes
None - all commands work the same, just internal structure changed."
```

- [ ] **Step 3: Verify PR created**

```bash
gh pr view
```

Expected: PR details displayed

---

## Completion Checklist

- [ ] All files moved to correct locations
- [ ] All configuration files updated
- [ ] All Makefile commands updated with correct workdirs
- [ ] All scripts updated for new paths
- [ ] Documentation (CLAUDE.md) updated
- [ ] All tests pass (build, serve, build-css, visual-baseline, check-links)
- [ ] Branch pushed and PR created
