JEKYLL_VERSION ?= 4
PORT ?= 4000
STATIC_PORT ?= 8000
PROJECT_PATH ?= /workspace/bitprepared.it
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
GEM_VOLUME = bitprepared-gems

.PHONY: serve serve-static build clean install install-gems help open validate-graphics compare-graphics visual-baseline visual-clean docker-build-visual docker-build-a11y workflow generate-blog-post check-links accessibility-audit accessibility-quick accessibility-full accessibility-analyze accessibility-score accessibility-clean accessibility-purge _check-a11y-serve _check-servers _start-servers _check-serve _start-serve

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Target disponibili:"
	@echo "  serve            - Avvia server di sviluppo (porta 4000, Docker)"
	@echo "  serve-static     - Avvia server statico (porta 8000, Python)"
	@echo "  open             - Apri sito locale nel browser (http://localhost:4000/)"
	@echo "  build            - Genera sito statico"
	@echo "  clean            - Rimuove _site/"
	@echo "  install          - Installa dipendenze bundle (Docker, locale)"
	@echo "  install-gems     - Installa gemme in volume persistente (una tantum)"
	@echo "  validate-graphics- Valida grafica serve vs serve-static (Docker)"
	@echo "  compare-graphics - Confronta solo screenshot esistenti (veloce)"
	@echo "  visual-baseline  - Crea baseline immagini (richiede make serve attivo)"
	@echo "  visual-clean      - Rimuovi screenshot temp"
	@echo "  docker-build-visual- Build immagine Docker visual regression"
	@echo "  workflow         - Mostra guida workflow sviluppo"
	@echo "  generate-blog-post- Genera blog post da file evento"
	@echo "  check-links      - Verifica link broken nel sito (htmltest)"
	@echo "  accessibility-audit- Audit accessibilità completo (Lighthouse + axe, Docker)"
	@echo "  accessibility-quick - Quick check accessibilità (Lighthouse solo homepage)"
		@echo "  accessibility-analyze - Analizza report esistenti e genera summary"
		@echo "  accessibility-score - Mostra score rapidi (Lighthouse + axe violations)"
		@echo "  accessibility-clean  - Rimuovi report accessibilità"
		@echo "  accessibility-purge  - Rimuovi report + Docker image a11y"
	@echo "  accessibility-full- Audit completo tutte le pagine (8 pagine rappresentative)"
	@echo "  help             - Mostra questo messaggio"
	@echo ""
	@echo "Opzioni:"
	@echo "  VIEWPORTS='desktop,mobile' make validate-graphics - Test solo viewport specifici"

serve:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		jekyll serve --config _config.yml,_config_dev.yml --force_polling

serve-static: build
	@echo "Server statico avviato su http://localhost:$(STATIC_PORT)/"
	@cd _site && python3 -m http.server $(STATIC_PORT)

build:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e JEKYLL_ENV=production \
		-e BUNDLE_PATH=/usr/local/bundle \
		$(DOCKER_IMAGE) \
		jekyll build

clean:
	rm -rf _site .jekyll-cache

install:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		$(DOCKER_IMAGE) \
		bundle install

install-gems:
	@echo "💎 Installazione gemme nel volume persistente $(GEM_VOLUME)..."
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		$(DOCKER_IMAGE) \
		bundle install
	@echo ""
	@echo "✅ Gemme installate nel volume Docker '$(GEM_VOLUME)'"
	@echo "   Questo volume persiste tra le esecuzioni e non richiede re-installazione"

open:
	@echo "Apertura sito locale: http://localhost:$(PORT)/"
	@xdg-open http://localhost:$(PORT)/

validate-graphics: docker-build-visual
	@echo "🔍 Avvio validazione grafica in Docker..."
	@echo ""
	@echo "📡 Verifica server..."
	@$(MAKE) --no-print-directory _check-servers || $(MAKE) --no-print-directory _start-servers
	@mkdir -p screenshots/serve screenshots/static screenshots/diff screenshots/report
	@chmod -R 777 screenshots/
	docker run --rm --init \
		--mount type=bind,source=${PWD},target=/app \
		--add-host=host.docker.internal:host-gateway \
		--user $(shell id -u):$(shell id -g) \
		--entrypoint="" \
		-e HOST_IP=host.docker.internal \
		-e VIEWPORTS="${VIEWPORTS}" \
		bitprepared-visual-regression:latest \
		sh -c 'cd /app/scripts/visual-regression && node capture.js && node compare.js'

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

.PHONY: _check-servers _start-servers
_check-servers:
	@echo -n "  ● Serve (4000): "
	@curl -f -s -o /dev/null http://localhost:4000 && echo "✅" || (echo "❌"; exit 1)
	@echo -n "  ● Static (8000): "
	@curl -f -s -o /dev/null http://localhost:8000 && echo "✅" || (echo "❌"; exit 1)
	@echo ""

_start-servers:
	@echo ""
	@echo "⚠️  Server non attivi. Avvia in terminali separati:"
	@echo "   Terminal 1: make serve"
	@echo "   Terminal 2: cd _site && python3 -m http.server 8000"
	@echo ""
	@read -p "Premi ENTER quando server sono pronti..."
	@$(MAKE) --no-print-directory _check-servers

visual-baseline: docker-build-visual
	@echo "📸 Creazione baseline images..."
	@echo ""
	@echo "📡 Verifica server..."
	@$(MAKE) --no-print-directory _check-serve || $(MAKE) --no-print-directory _start-serve
	@mkdir -p tests/visual-baseline/desktop tests/visual-baseline/mobile tests/visual-baseline/tablet
	docker run --rm --init \
		--mount type=bind,source=${PWD},target=/app \
		--add-host=host.docker.internal:host-gateway \
		-e HOST_IP=host.docker.internal \
		--user $(shell id -u):$(shell id -g) \
		--entrypoint="" \
		bitprepared-visual-regression:latest \
		node /app/scripts/visual-regression/create-baseline.js

.PHONY: _check-serve _start-serve
_check-serve:
	@echo -n "  ● Serve (4000): "
	@curl -f -s -o /dev/null http://localhost:4000 && echo "✅" || (echo "❌"; exit 1)
	@echo ""

_start-serve:
	@echo ""
	@echo "⚠️  Server non attivo. Avvia in un terminale separato:"
	@echo "   Terminal 1: make serve"
	@echo ""
	@read -p "Premi ENTER quando server è pronto..."
	@$(MAKE) --no-print-directory _check-serve
	@echo "✅ Baseline creata in tests/visual-baseline/"
	@echo "📝 Commit now: git add tests/visual-baseline/ && git commit -m 'Add visual baseline'"

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
		--mount type=bind,source=${PWD}/_site,target=/test \
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
.PHONY: docker-build-a11y _check-a11y-serve
docker-build-a11y:
	@echo "🐳 Building accessibility Docker image..."
	docker build -t bitprepared-a11y:latest -f docker/accessibility/Dockerfile .

_check-a11y-serve:
	@echo -n "  ● Jekyll Serve (4000): "
	@curl -f -s -o /dev/null http://localhost:4000 && echo "✅" || (echo "❌"; echo ""; echo "⚠️  Server not running. Start with: make serve"; exit 1)

accessibility-audit: docker-build-a11y _check-a11y-serve
	@echo "🔍 Running accessibility audit..."
	@echo ""
	@mkdir -p docs/accessibility/reports
	docker run --rm --init \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/docs/accessibility/reports,target=/app/reports \
		--add-host=host.docker.internal:host-gateway \
		-e SITE_URL=http://host.docker.internal:4000 \
		bitprepared-a11y:latest \
		bash /app/scripts/accessibility-audit.sh
	@echo ""
	@echo "✅ Audit complete! Reports saved to docs/accessibility/reports/"
	@echo "📋 View JSON: cat docs/accessibility/reports/lighthouse/homepage.report.json"

accessibility-quick: docker-build-a11y _check-a11y-serve
	@echo "🚀 Quick accessibility check (Lighthouse only)..."
	@echo ""
	@mkdir -p docs/accessibility/reports/lighthouse
	docker run --rm --init \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/docs/accessibility/reports,target=/app/reports \
		--add-host=host.docker.internal:host-gateway \
		-e SITE_URL=http://host.docker.internal:4000 \
		bitprepared-a11y:latest \
		sh -c "npx -y lighthouse \$$SITE_URL --only-categories=accessibility --output=json --output-path=/app/reports/lighthouse/quick-check --chrome-flags='--headless --no-sandbox --disable-gpu' --quiet"
	@echo ""
	@echo "✅ Quick check complete! Report saved to docs/accessibility/reports/lighthouse/quick-check.json"

accessibility-full: docker-build-a11y _check-a11y-serve
	@echo "🔍 Full accessibility audit (all pages)..."
	@echo "⏱️  This will test 8 pages and may take several minutes..."
	@echo ""
	@mkdir -p docs/accessibility/reports
	docker run --rm --init \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,source=${PWD}/docs/accessibility/reports,target=/app/reports \
		--add-host=host.docker.internal:host-gateway \
		-e SITE_URL=http://host.docker.internal:4000 \
		bitprepared-a11y:latest \
		bash /app/scripts/accessibility-full-audit.sh
	@echo ""
	@echo "✅ Full audit complete! Reports saved to docs/accessibility/reports/"
	@echo "📋 Summary:"
	@echo "  - Lighthouse: docs/accessibility/reports/lighthouse/*.report.json"
	@echo "  - axe-core: docs/accessibility/reports/axe/*.json"

# Analyze accessibility reports
.PHONY: accessibility-analyze
accessibility-analyze:
	@echo "📊 Analyzing accessibility reports..."
	@echo ""
	@./scripts/analyze-a11y-reports.sh docs/accessibility/reports

# Quick score check
.PHONY: accessibility-score
accessibility-score:
	@echo "📊 Lighthouse Accessibility Score:"
	@if [ -f docs/accessibility/reports/lighthouse/homepage ]; then \
		node -e "const fs=require('fs');const d=JSON.parse(fs.readFileSync('docs/accessibility/reports/lighthouse/homepage','utf8'));console.log((d.categories.accessibility.score*100).toFixed(0)+'%')"; \
	elif [ -f docs/accessibility/reports/lighthouse/homepage.json ]; then \
		cat docs/accessibility/reports/lighthouse/homepage.json | jq -r '(.categories.accessibility.score * 100 | floor | tostring) + "%"'; \
	else \
		echo "No report found. Run 'make accessibility-audit' first"; \
	fi
	@echo ""
	@echo "🪓 axe-core Violations:"
	@if [ -f docs/accessibility/reports/axe/homepage.json ]; then \
		cat docs/accessibility/reports/axe/homepage.json | jq '.violations | length'; \
	elif [ -f docs/accessibility/reports/axe/homepage ]; then \
		cat docs/accessibility/reports/axe/homepage | jq '.violations | length'; \
	else \
		echo "No report found"; \
	fi

# Clean accessibility reports
.PHONY: accessibility-clean
accessibility-clean:
	@echo "🧹 Cleaning accessibility reports..."
	@rm -rf docs/accessibility/reports/
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
	@if [ -f docs/accessibility/reports/lighthouse/homepage ]; then \
		./scripts/show-a11y-issues.sh docs/accessibility/reports/lighthouse/homepage; \
	elif [ -f docs/accessibility/reports/lighthouse/homepage.json ]; then \
		./scripts/show-a11y-issues.sh docs/accessibility/reports/lighthouse/homepage.json; \
	else \
		echo "No report found. Run 'make accessibility-audit' first"; \
	fi
