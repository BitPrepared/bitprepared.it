JEKYLL_VERSION ?= 3
PORT ?= 4000
STATIC_PORT ?= 8000
PROJECT_PATH ?= /workspace/bitprepared.it
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)

.PHONY: serve serve-static build clean install help open validate-graphics visual-baseline visual-clean

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
	@echo "  validate-graphics- Valida grafica serve vs serve-static"
	@echo "  visual-baseline  - Crea baseline immagini per visual regression"
	@echo "  visual-clean      - Rimuovi screenshot temp"
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

validate-graphics:
	@echo "🔍 Avvio validazione grafica..."
	@if [ ! -d "scripts/visual-regression/node_modules" ]; then \
		echo "⚠️  Dipendenze non installate. Eseguire:"; \
		echo "   cd scripts/visual-regression && npm install"; \
		exit 1; \
	fi
	@cd scripts/visual-regression && npm test
	@echo "✅ Validazione completata - Report in screenshots/report/index.html"

visual-baseline:
	@echo "📸 Creazione baseline images..."
	@if [ ! -d "scripts/visual-regression/node_modules" ]; then \
		echo "⚠️  Dipendenze non installate. Eseguire:"; \
		echo "   cd scripts/visual-regression && npm install"; \
		exit 1; \
	fi
	@cd scripts/visual-regression && node create-baseline.js
	@echo "✅ Baseline creata in tests/visual-baseline/"
	@echo "📝 Commit now: git add tests/visual-baseline/ && git commit -m 'Add visual baseline'"

visual-clean:
	@rm -rf screenshots/
	@echo "🧹 Screenshots temp rimossi"
