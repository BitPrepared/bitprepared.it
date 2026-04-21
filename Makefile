JEKYLL_VERSION ?= 3
PORT ?= 4000
STATIC_PORT ?= 8000
PROJECT_PATH ?= /workspace/bitprepared.it
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)

.PHONY: serve serve-static build clean install help open validate-graphics visual-baseline visual-clean docker-build-visual workflow

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Target disponibili:"
	@echo "  serve            - Avvia server di sviluppo (porta 4000, Docker)"
	@echo "  serve-static     - Avvia server statico (porta 8000, Python)"
	@echo "  open             - Apri sito locale nel browser (http://localhost:4000/)"
	@echo "  build            - Genera sito statico"
	@echo "  clean            - Rimuove _site/"
	@echo "  install          - Installa dipendenze bundle (Docker)"
	@echo "  validate-graphics- Valida grafica serve vs serve-static (Docker)"
	@echo "  visual-baseline  - Crea baseline immagini (richiede make serve attivo)"
	@echo "  visual-clean      - Rimuovi screenshot temp"
	@echo "  docker-build-visual- Build immagine Docker visual regression"
	@echo "  workflow         - Mostra guida workflow sviluppo"
	@echo "  help             - Mostra questo messaggio"

serve:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="${PWD}/vendor/bundle:/usr/local/bundle:Z" \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		jekyll serve --config _config.yml,_config_dev.yml

serve-static: build
	@echo "Server statico avviato su http://localhost:$(STATIC_PORT)/"
	@cd _site && python3 -m http.server $(STATIC_PORT)

build:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="${PWD}/vendor/bundle:/usr/local/bundle:Z" \
		-e JEKYLL_ENV=production \
		$(DOCKER_IMAGE) \
		jekyll build

clean:
	rm -rf _site .jekyll-cache

install:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="${PWD}/vendor/bundle:/usr/local/bundle:Z" \
		$(DOCKER_IMAGE) \
		bundle install

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
		bitprepared-visual-regression:latest \
		node /app/scripts/visual-regression/create-baseline.js
	@echo "✅ Baseline creata in tests/visual-baseline/"
	@echo "📝 Commit now: git add tests/visual-baseline/ && git commit -m 'Add visual baseline'"

visual-clean:
	@rm -rf screenshots/
	@echo "🧹 Screenshots temp rimossi"

docker-build-visual:
	@echo "🐳 Building visual regression Docker image..."
	docker build -t bitprepared-visual-regression:latest -f scripts/visual-regression/Dockerfile .

workflow:
	@echo "📋 Workflow Sviluppo BitPrepared"
	@echo ""
	@cat docs/WORKFLOW.md
