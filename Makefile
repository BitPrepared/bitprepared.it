JEKYLL_VERSION ?= 4
PORT ?= 4000
STATIC_PORT ?= 8000
PROJECT_PATH ?= /workspace/bitprepared.it
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)
GEM_VOLUME = bitprepared-gems

.PHONY: serve serve-static build clean install install-gems help open validate-graphics visual-baseline visual-clean docker-build-visual workflow generate-blog-post check-links

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
	@echo "  visual-baseline  - Crea baseline immagini (richiede make serve attivo)"
	@echo "  visual-clean      - Rimuovi screenshot temp"
	@echo "  docker-build-visual- Build immagine Docker visual regression"
	@echo "  workflow         - Mostra guida workflow sviluppo"
	@echo "  generate-blog-post- Genera blog post da file evento"
	@echo "  check-links      - Verifica link broken nel sito (htmltest)"
	@echo "  help             - Mostra questo messaggio"

serve:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="$(GEM_VOLUME):/usr/local/bundle" \
		-e BUNDLE_PATH=/usr/local/bundle \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		jekyll serve --config _config.yml,_config_dev.yml

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
	@echo "⚠️  Richiede server attivi in terminali separati:"
	@echo "   Terminal 1: make serve"
	@echo "   Terminal 2: make serve-static"
	@echo ""
	@read -p "Premi ENTER quando server sono pronti..."
	@echo ""
	docker run --rm \
		--mount type=bind,source=${PWD},target=/app \
		--add-host=host.docker.internal:host-gateway \
		--user $(id -u):$(id -g) \
		bitprepared-visual-regression:latest

visual-baseline: docker-build-visual
	@echo "📸 Creazione baseline images..."
	@echo "⚠️  Assicurati che 'make serve' sia attivo su porta 4000"
	@echo "   In un altro terminale esegui: make serve"
	@echo ""
	@read -p "Premi ENTER quando server è pronto..."
	@echo ""
	docker run --rm \
		--mount type=bind,source=${PWD},target=/app \
		--add-host=host.docker.internal:host-gateway \
		-e HOST_IP=host.docker.internal \
		--user $(id -u):$(id -g) \
		--entrypoint="" \
		bitprepared-visual-regression:latest \
		sh -c 'cd /app/scripts/visual-regression && npm run create-baseline'
	@echo "✅ Baseline creata in tests/visual-baseline/"
	@echo "📝 Commit now: git add tests/visual-baseline/ && git commit -m 'Add visual baseline'"

visual-clean:
	@-rm -rf screenshots/ || true
	@echo "🧹 Screenshots temp rimossi (ignorati errori permessi)"

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
