JEKYLL_VERSION ?= 4
PORT ?= 4000
STATIC_PORT ?= 8000
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
NODE_MODULES_VOLUME = bitprepared-node-modules
VENDOR_VOLUME = bitprepared-vendor
CACHE_VOLUME = bitprepared-jekyll-cache
POLLING ?= 0
A11Y_PAGE ?= full

.PHONY: serve serve-bg serve-static serve-static-bg build build-css clean install install-gems help open validate-graphics compare-graphics visual-baseline visual-clean docker-build-visual docker-build-a11y workflow generate-blog-post check-links accessibility-audit accessibility-analyze accessibility-clean accessibility-purge stop-servers stop-serve stop-static version-validate version-bump version-show release

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Target disponibili:"
	@echo "  serve            - Avvia server di sviluppo (porta 4000, Docker)"
	@echo "  serve-bg         - Avvia Jekyll in background (per CI/CD)"
	@echo "  serve-static     - Avvia server statico (porta 8000, Python)"
	@echo "  serve-static-bg  - Avvia server statico in background (per CI/CD)"
	@echo "  stop-servers     - Ferma tutti i server background"
	@echo "  open             - Apri sito locale nel browser (http://localhost:4000/)"
	@echo "  build            - Genera sito statico"
	@echo "  build-css        - Genera Tailwind CSS localmente (Docker)"
	@echo "  clean            - Rimuove output/_site/"
	@echo "  install          - Installa dipendenze bundle (Docker, locale)"
	@echo "  install-gems     - Installa gemme in volume persistente (una tantum)"
	@echo "  validate-graphics- Valida grafica serve vs serve-static (Docker)"
	@echo "  compare-graphics - Confronta solo screenshot esistenti (veloce)"
	@echo "  visual-baseline  - Crea baseline immagini (autonomous, avvia server in background)"
	@echo "  visual-clean      - Rimuovi screenshot temp"
	@echo "  docker-build-visual- Build immagine Docker visual regression"
	@echo "  workflow         - Mostra guida workflow sviluppo"
	@echo "  generate-blog-post- Genera blog post da file evento"
	@echo "  check-links      - Verifica link broken nel sito (htmltest)"
	@echo "  accessibility-audit- Audit accessibilità + auto-analyze (default: full 8 pagine, usa A11Y_PAGE=index per solo homepage)"
		@echo "  accessibility-analyze - Analizza report, genera summary.md e mostra score di tutte le pagine"
		@echo "  accessibility-clean  - Rimuovi report accessibilità"
		@echo "  accessibility-purge  - Rimuovi report + Docker image a11y"
	@echo "  release          - Crea PR release (valida CHANGELOG, bump versione, crea branch+PR)"
	@echo "  version-validate - Valida CHANGELOG.txt"
	@echo "  version-bump     - Bump versione in CHANGELOG.txt (interactive)"
	@echo "  version-show     - Mostra versione corrente e git tags"
	@echo "  help             - Mostra questo messaggio"
	@echo ""
	@echo "Opzioni:"
	@echo "  POLLING=1 make serve - Abilita force_polling per live reload"
	@echo "  A11Y_PAGE=index make accessibility-audit - Test solo homepage invece di full (8 pagine)"
	@echo "  VIEWPORTS='desktop,mobile' make validate-graphics - Test solo viewport specifici"

serve:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--mount type=bind,source=${PWD}/output,target=/workspace/output \
		--volume="$(VENDOR_VOLUME):/usr/local/bundle" \
		--volume="$(CACHE_VOLUME):/workspace/.jekyll-cache" \
		-e BUNDLE_PATH=/usr/local/bundle \
		-e GEM_HOME=/usr/local/bundle \
		-w /workspace/jekyll \
		-e JEKYLL_PATH=/workspace/jekyll \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		bundle exec jekyll serve --host 0.0.0.0 --port 4000 --config _config.yml,_config_dev.yml $(if $(filter 1,$(POLLING)),--force_polling,)

serve-static: build
	@echo "Server statico avviato su http://localhost:$(STATIC_PORT)/"
	@cd output/_site && python3 -m http.server $(STATIC_PORT)

.PHONY: serve-bg serve-static-bg stop-servers stop-serve stop-static

# Avvia Jekyll serve in background (scrive PID)
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
		--volume="$(VENDOR_VOLUME):/usr/local/bundle" \
		--volume="$(CACHE_VOLUME):/workspace/.jekyll-cache" \
		-e BUNDLE_PATH=/usr/local/bundle \
		-e GEM_HOME=/usr/local/bundle \
		-w /workspace/jekyll \
		-e JEKYLL_PATH=/workspace/jekyll \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		bundle exec jekyll serve --config _config.yml,_config_dev.yml --host 0.0.0.0 > /dev/null
	@docker ps -q -f name=bitprepared-jekyll-$(PORT) > .jekyll_serve.pid
	@echo "⏳ Attendo avvio server..."
	@for i in $$(seq 1 30); do \
		if curl -f -s -o /dev/null http://localhost:$(PORT); then \
			echo "✅ Jekyll pronto su http://localhost:$(PORT)"; \
			exit 0; \
		fi; \
		sleep 1; \
	done; \
	echo "❌ Timeout avvio Jekyll"; exit 1

# Avvia server statico in background (scrive PID)
serve-static-bg: build
	@echo "🚀 Avvio server statico in background..."
	@echo "⏳ Fermo eventuale server statico esistente..."
	@if [ -f .static_serve.pid ]; then \
		pid=$$(cat .static_serve.pid); \
		if kill -0 $$pid 2>/dev/null; then \
			echo "🛑 Fermo vecchio server statico (PID: $$pid)"; \
			kill $$pid 2>/dev/null || true; \
			sleep 1; \
		fi; \
		rm -f .static_serve.pid; \
	fi
	@echo "⏳ Avvio nuovo server..."
	@(python3 -m http.server $(STATIC_PORT) --directory output/_site > /tmp/static_server.log 2>&1 & echo $$! > .static_serve.pid); \
	echo "📝 PID salvato: $$(cat .static_serve.pid 2>/dev/null || echo 'N/A')"; \
	echo "📝 Processo esiste: $$(ps -p $$(cat .static_serve.pid 2>/dev/null) >/dev/null 2>&1 && echo 'SI' || echo 'NO')"; \
	echo "📝 Directory servita: output/_site"; \
	echo "📝 Index exists: $$(test -f output/_site/index.html && echo 'SI' || echo 'NO')"; \
	for i in $$(seq 1 30); do \
		if curl -f -s -o /dev/null http://localhost:$(STATIC_PORT); then \
			echo "✅ Server statico pronto su http://localhost:$(STATIC_PORT)"; \
			exit 0; \
		fi; \
		echo "⏳ Tentativo $$i/30..."; \
		sleep 1; \
	done; \
	echo "❌ Timeout avvio server statico"; \
	echo "📝 Log errore:"; \
	cat /tmp/static_server.log 2>/dev/null || echo "Nessun log"; \
	exit 1

# Ferma entrambi i server
stop-servers: stop-serve stop-static

# Ferma Jekyll
stop-serve:
	@echo "🛑 Fermo Jekyll..."
	@docker stop bitprepared-jekyll-$(PORT) 2>/dev/null || true
	@docker rm bitprepared-jekyll-$(PORT) 2>/dev/null || true
	@if [ -f .jekyll_serve.pid ]; then \
		pid=$$(cat .jekyll_serve.pid); \
		docker stop $$pid 2>/dev/null || true; \
		docker rm $$pid 2>/dev/null || true; \
		rm -f .jekyll_serve.pid; \
	fi
	@echo "✅ Jekyll fermato"

# Ferma server statico
stop-static:
	@if [ -f .static_serve.pid ]; then \
		echo "🛑 Fermo server statico..."; \
		kill $$(cat .static_serve.pid) 2>/dev/null || true; \
		rm -f .static_serve.pid; \
		echo "✅ Server statico fermato"; \
	fi

build:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--mount type=bind,source=${PWD}/output,target=/workspace/output \
		--volume="$(VENDOR_VOLUME):/usr/local/bundle" \
		--volume="$(CACHE_VOLUME):/workspace/.jekyll-cache" \
		-e BUNDLE_PATH=/usr/local/bundle \
		-e GEM_HOME=/usr/local/bundle \
		-w /workspace/jekyll \
		-e JEKYLL_PATH=/workspace/jekyll \
		-e JEKYLL_ENV=production \
		$(DOCKER_IMAGE) \
		bundle exec jekyll build
	@cp src/jekyll/robots.txt output/_site/

build-css:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--volume="$(NODE_MODULES_VOLUME):/workspace/node_modules" \
		-w /workspace/tailwind \
		node:20 \
		npm run build:css

clean:
	rm -rf output/_site output/.jekyll-cache output/screenshots output/accessibility
	rm -rf src/.jekyll-cache src/node_modules src/output src/vendor
	rm -rf .jekyll-cache node_modules vendor _site

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
		--volume="$(VENDOR_VOLUME):/usr/local/bundle" \
		-e GEM_HOME=/usr/local/bundle \
		-w /workspace/jekyll \
		$(DOCKER_IMAGE) \
		bundle install --no-cache

install-gems:
	docker run --rm -it \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/src,target=/workspace \
		--volume="$(VENDOR_VOLUME):/usr/local/bundle" \
		-e GEM_HOME=/usr/local/bundle \
		-w /workspace/jekyll \
		$(DOCKER_IMAGE) \
		bundle install --no-cache

open:
	@echo "Apertura sito locale: http://localhost:$(PORT)/"
	@xdg-open http://localhost:$(PORT)/

validate-graphics: docker-build-visual
	@echo "🔍 Avvio validazione grafica in Docker..."
	@echo ""
	@$(MAKE) --no-print-directory serve-bg
	@if [ "$(BASELINE_VERSION)" != "" ] && [ "$(BASELINE_VERSION)" != "latest" ]; then \
		echo "📂 Baseline specificata: $(BASELINE_VERSION)"; \
	fi
	@$(MAKE) --no-print-directory serve-static-bg
	@mkdir -p screenshots/serve screenshots/static screenshots/diff screenshots/report
	@chmod -R 777 screenshots/
	@echo "📸 Eseguo capture..."
	@(docker run --rm --init \
		--mount type=bind,source=${PWD},target=/app \
		--add-host=host.docker.internal:host-gateway \
		--user $(shell id -u):$(shell id -g) \
		--entrypoint="" \
		-e HOST_IP=host.docker.internal \
		-e BASELINE_VERSION="$(BASELINE_VERSION)" \
		-e VIEWPORTS="${VIEWPORTS}" \
		bitprepared-visual-regression:latest \
		sh -c 'cd /app/scripts/visual-regression && node capture.js && node compare.js'; \
	ret=$$?; \
	$(MAKE) --no-print-directory stop-servers; \
	exit $$ret)
	@echo "✅ Validazione completata"

compare-graphics: docker-build-visual
	@echo "📊 Confronto screenshot esistenti (no capture)..."
	@echo ""
	@mkdir -p screenshots/diff screenshots/report
	docker run --rm --init \
		--mount type=bind,source=${PWD},target=/app \
		--user $(shell id -u):$(shell id -g) \
		--entrypoint="" \
		bitprepared-visual-regression:latest \
		node /app/scripts/visual-regression/compare.js

visual-baseline: docker-build-visual
	@echo "📸 Creazione baseline images..."
	@echo ""
	@$(MAKE) --no-print-directory serve-bg
	@mkdir -p tests/visual-baseline
	@(docker run --rm --init \
		--mount type=bind,source=${PWD},target=/app \
		--add-host=host.docker.internal:host-gateway \
		-e HOST_IP=host.docker.internal \
		--user $(shell id -u):$(shell id -g) \
		--entrypoint="" \
		bitprepared-visual-regression:latest \
		node /app/scripts/visual-regression/create-baseline.js; \
	ret=$$?; \
	$(MAKE) --no-print-directory stop-serve; \
	exit $$ret)
	@echo "✅ Baseline creata in tests/visual-baseline/$$(date +%Y.%m)/"
	@echo "📝 Commit now: git add tests/visual-baseline/ && git commit -m 'Add baseline $$(date +%Y.%m)'"

visual-clean:
	@echo "🧹 Rimozione screenshots..."
	@rm -rf screenshots/
	@echo "✅ Screenshots rimossi"

docker-build-visual:
	@echo "🐳 Building visual regression Docker image..."
	docker build -t bitprepared-visual-regression:latest -f scripts/visual-regression/Dockerfile .

workflow:
	@echo "📋 Workflow Sviluppo BitPrepared"
	@echo ""
	@cat docs/WORKFLOW.md

generate-blog-post:
	@echo "📝 Generazione blog post da evento..."
	@read -p "Path file evento (es: _pages/eventi/epppi_rs.md): " event_path; \
	docker run --rm \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		$(DOCKER_IMAGE) \
		ruby /srv/jekyll/scripts/generate-blog-post.rb "$$event_path"
	@echo ""
	@echo "🚀 Apertura MarkText con il file generato..."
	@ls -t _posts/*.md 2>/dev/null | head -1 | xargs -r marktext 2>/dev/null &
	@echo ""
	@echo "📝 PROSSIMI PASSI:"
	@echo "1. Modifica il file in MarkText (sostituisci placeholder)"
	@echo "2. Verifica frontmatter e contenuti"
	@echo "3. Salva e chiudi MarkText"
	@echo "4. Git add e commit"

check-links: build
	@echo "🔍 Verifica link broken nel sito..."
	@echo ""
	@echo "⚠️  Filtro solo errori significativi (ignoro fonts, hash tags, ecc.)"
	@echo ""
	@docker run --rm \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/output/_site,target=/test \
		--mount type=bind,source=${PWD}/src/jekyll/.htmltest.yml,target=/.htmltest.yml \
		wjdp/htmltest \
		/test 2>&1 | \
		grep -v "Non-OK status: 404.*fonts.googleapis.com" | \
		grep -v "Non-OK status: 404.*fonts.gstatic.com" | \
		grep -v "hash does not exist" | \
		grep -v "empty hash" | \
		grep -v "x509.*could not validate certificate" | \
		grep -v "alt text empty" | \
		grep -v "^$$" | \
		grep -v "^htmltest started" | \
		grep -v "^========================================================================$$" | \
		grep -v "failed in.*" | \
		grep -v "errors in.*documents" || true
	@echo ""
	@echo "✅ Check completato!"
	@echo "📝 NOTA: Link ignorati automaticamente:"
	@echo "   - fonts.googleapis.com e fonts.gstatic.com (falsi positivi)"
	@echo "   - Link interni con hash (#tags)"
	@echo "   - Errori certificati SSL (siti esterni con problemi)"
	@echo "   - Alt text vuoto (accessibilità)"


# Accessibility Audit (Docker-based)
.PHONY: docker-build-a11y
docker-build-a11y:
	@echo "🐳 Building accessibility Docker image..."
	docker build -t bitprepared-a11y:latest -f src/docker/accessibility/Dockerfile .

accessibility-audit: docker-build-a11y
	@echo "🔍 Running accessibility audit..."
	@echo ""
	@$(MAKE) --no-print-directory serve-bg
	@mkdir -p output/accessibility/reports
	@(if [ "$(A11Y_PAGE)" = "index" ]; then \
		echo "📊 Testing homepage only..."; \
		docker run --rm --init \
			--user $(shell id -u):$(shell id -g) \
			--mount type=bind,source=${PWD}/output/accessibility/reports,target=/app/reports \
			--add-host=host.docker.internal:host-gateway \
			-e SITE_URL=http://host.docker.internal:4000 \
			bitprepared-a11y:latest \
			bash /app/scripts/accessibility-audit.sh; \
	else \
		echo "📊 Testing all pages (8 pages)..."; \
		echo "⏱️  This may take several minutes..."; \
		docker run --rm --init \
			--user $(shell id -u):$(shell id -g) \
			--mount type=bind,source=${PWD}/output/accessibility/reports,target=/app/reports \
			--add-host=host.docker.internal:host-gateway \
			-e SITE_URL=http://host.docker.internal:4000 \
			bitprepared-a11y:latest \
			bash /app/scripts/accessibility-full-audit.sh; \
	fi; \
	ret=$$?; \
	$(MAKE) --no-print-directory stop-serve; \
	exit $$ret)
	@echo ""
	@echo "✅ Audit complete! Reports saved to output/accessibility/reports/"
	@echo "📋 View JSON: cat output/accessibility/reports/lighthouse/homepage.report.json"
	@echo ""
	@$(MAKE) --no-print-directory accessibility-analyze


# Analyze accessibility reports and generate summary
accessibility-analyze:
	@echo "📊 Analyzing accessibility reports..."
	@echo ""
	@mkdir -p output/accessibility/reports
	@./scripts/analyze-a11y-reports.sh output/accessibility/reports > output/accessibility/reports/summary.md
	@echo "✅ Summary saved to output/accessibility/reports/summary.md"
	@echo ""
	@echo "📊 Quick Scores:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@for file in output/accessibility/reports/lighthouse/*.json output/accessibility/reports/lighthouse/*; do \
		if [ -f "$$file" ]; then \
			pagename=$$(basename "$$file" .json | sed 's/\.report$$//'); \
			score=$$(cat "$$file" | jq -r '.categories.accessibility.score * 100 | floor'); \
			echo "  ● Lighthouse ($$pagename): $$score%"; \
		fi; \
	done
	@for file in output/accessibility/reports/axe/*.json; do \
		if [ -f "$$file" ]; then \
			pagename=$$(basename "$$file" .json); \
			violations=$$(cat "$$file" | jq '.violations | length'); \
			echo "  ● axe-core ($$pagename): $$violations violations"; \
		fi; \
	done
	@echo ""
	@echo "📋 Full summary: cat output/accessibility/reports/summary.md"

# Clean accessibility reports
.PHONY: accessibility-clean
accessibility-clean:
	@echo "🧹 Cleaning accessibility reports..."
	@rm -rf output/accessibility/reports/
	@echo "✅ Accessibility reports removed"
	@echo "💡 Run 'make accessibility-audit' to regenerate"

# Clean all accessibility artifacts (reports + Docker image)
.PHONY: accessibility-purge
accessibility-purge: accessibility-clean
	@echo "🗑️  Removing accessibility Docker image..."
	@docker rmi bitprepared-a11y:latest 2>/dev/null || echo "Image not found or already removed"
	@echo "✅ All accessibility artifacts removed"

# Show specific accessibility issues with element locations
.PHONY: accessibility-issues
accessibility-issues:
	@echo "🔍 Showing accessibility issues with element locations..."
	@echo ""
	@if [ -f output/accessibility/reports/lighthouse/homepage ]; then \
		./scripts/show-a11y-issues.sh output/accessibility/reports/lighthouse/homepage; \
	elif [ -f output/accessibility/reports/lighthouse/homepage.json ]; then \
		./scripts/show-a11y-issues.sh output/accessibility/reports/lighthouse/homepage.json; \
	else \
		echo "No report found. Run 'make accessibility-audit' first"; \
	fi

# Semantic Versioning
.PHONY: version-validate version-bump version-show
version-validate:
	@echo "📋 Validating CHANGELOG..."
	@echo "   Release type: $${RELEASE_TYPE:-patch}"
	@chmod +x ./scripts/validate-changelog.sh
	@RELEASE_TYPE="${RELEASE_TYPE}" ./scripts/validate-changelog.sh

version-bump:
	@echo "🔖 Bumping version..."
	@read -p "Type (major/minor/patch): " type; \
	chmod +x ./scripts/bump-version.sh; \
	./scripts/bump-version.sh $$type

version-show:
	@echo "📌 Current version:"
	@grep -m 1 "^## \[" CHANGELOG.txt | sed 's/^## \[\([^]]*\)\].*/\1/'
	@echo ""
	@echo "📋 Git tags:"
	@git tag -l | tail -5

# Test: Verifica che inline CSS/JS siano stati rimossi
test-cleanup:
	@echo "Testing CSS/JS cleanup..."
	@echo "1. Checking for inline CSS styles..."
	@! grep -r 'style="color:' _site/index.html || { echo "❌ FAIL: Found inline color styles"; exit 1; }
	@echo "✅ PASS: No inline color styles in index.html"
	@echo "2. Checking for inline JavaScript..."
	@! grep -r '<script' _site/index.html | grep -v 'src=' | grep -v 'application/ld+json' || { echo "❌ FAIL: Found inline JavaScript"; exit 1; }
	@echo "✅ PASS: No inline JavaScript (except JSON-LD)"
	@echo "3. Checking edit-button-dev.js excluded from production..."
	@! grep -r 'edit-button-dev.js' _site/ || { echo "❌ FAIL: edit-button-dev.js found in production"; exit 1; }
	@echo "✅ PASS: edit-button-dev.js excluded from production"
	@echo ""
	@echo "✅ All cleanup tests passed!"


.PHONY: check-aria
check-aria:
	@echo "🔍 Checking ARIA tags..."
	@node scripts/check-aria.js

.PHONY: optimize-images
optimize-images:
	@echo "🖼️  Optimizing images..."
	@node scripts/optimize-images.js

.PHONY: extract-critical
extract-critical:
	@echo "🎨 Extracting critical CSS..."
	@node scripts/extract-critical-css.js

# Release workflow
.PHONY: release
release:
	@echo "🚀 Starting release process..."
	@echo ""
	@echo "Step 1: Determining release type..."
	@read -p "Release type (major/minor/patch): " release_type; \
	LAST_VERSION=$$(grep "^## \[" CHANGELOG.txt | grep -v "^## \[Unreleased\]" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/'); \
	if [[ -z "$$LAST_VERSION" ]]; then \
		echo "⚠️  No previous version found, using 1.0.0"; \
		NEXT_VERSION="1.0.0"; \
	elif [[ "$$LAST_VERSION" == *"T"* ]]; then \
		echo "⚠️  Old timestamp format detected: $$LAST_VERSION"; \
		echo "🔄 Migrating to semantic versioning..."; \
		NEXT_VERSION="1.0.0"; \
	else \
		CURRENT_MAJOR=$$(echo "$$LAST_VERSION" | cut -d. -f1); \
		CURRENT_MINOR=$$(echo "$$LAST_VERSION" | cut -d. -f2); \
		CURRENT_PATCH=$$(echo "$$LAST_VERSION" | cut -d. -f3); \
		case "$$release_type" in \
			major) NEXT_VERSION=$$((CURRENT_MAJOR + 1)).0.0 ;; \
			minor) NEXT_VERSION=$$CURRENT_MAJOR.$$((CURRENT_MINOR + 1)).0 ;; \
			patch) NEXT_VERSION=$$CURRENT_MAJOR.$$CURRENT_MINOR.$$((CURRENT_PATCH + 1)) ;; \
			*) echo "❌ Invalid type. Use major, minor, or patch."; exit 1 ;; \
		esac; \
	fi; \
	echo "📌 Next version: $$NEXT_VERSION"; \
	BRANCH_NAME="chore/bump-version-$$NEXT_VERSION"; \
	echo "📌 Branch: $$BRANCH_NAME"; \
	echo ""; \
	echo "Step 2: Validating CHANGELOG for $$release_type release..."; \
	chmod +x ./scripts/validate-changelog.sh; \
	RELEASE_TYPE="$$release_type" ./scripts/validate-changelog.sh; \
	echo "✅ CHANGELOG valid"; \
	echo ""; \
	echo "Step 3: Checking if branch exists..."; \
	if git ls-remote --heads origin "$$BRANCH_NAME" | grep -q "$$BRANCH_NAME"; then \
		echo "❌ Branch '$$BRANCH_NAME' already exists on remote."; \
		echo "Delete it first: git push origin --delete $$BRANCH_NAME"; \
		exit 1; \
	fi; \
	echo "✅ Branch available"; \
	echo ""; \
	echo "Step 4: Bumping version in CHANGELOG..."; \
	chmod +x ./scripts/bump-version.sh; \
	./scripts/bump-version.sh $$release_type; \
	echo "✅ Version bumped"; \
	echo ""; \
	echo "Step 5: Creating branch and committing..."; \
	git checkout -b "$$BRANCH_NAME"; \
	git add CHANGELOG.txt; \
	git commit -m "chore: bump version to $$NEXT_VERSION"; \
	echo "✅ Committed"; \
	echo ""; \
	echo "Step 6: Pushing branch..."; \
	git push origin "$$BRANCH_NAME"; \
	echo "✅ Pushed"; \
	echo ""; \
	echo "Step 7: Creating PR..."; \
	gh pr create \
		--title "Release $$NEXT_VERSION - Version Bump" \
		--body "Automated version bump to $$NEXT_VERSION. **Release type: $$release_type**\n\n📋 After merging this PR:\n1. Go to Actions → 'Create Release' workflow\n2. Run workflow manually\n3. Artifacts will be built and attached to GitHub release" \
		--base master \
		--head "$$BRANCH_NAME" \
		--label "release:automated" \
		--label "release:$$release_type"; \
	echo ""; \
	echo "✅ Release PR created!"; \
	echo "🔗 View PR: gh pr view"; \
	echo ""; \
	echo "⏳ Next steps:"; \
	echo "   1. Merge this PR"; \
	echo "   2. Go to Actions → 'Create Release' workflow"; \
	echo "   3. Run workflow to build and create release"
