JEKYLL_VERSION ?= 3
PORT ?= 4000
DOCKER_IMAGE = jekyll/jekyll:$(JEKYLL_VERSION)

.PHONY: serve build clean install help

help:
	@echo "Uso: make [target]"
	@echo ""
	@echo "Target disponibili:"
	@echo "  serve      - Avvia server di sviluppo (porta 4000)"
	@echo "  build      - Genera sito statico"
	@echo "  clean      - Rimuove _site/"
	@echo "  install    - Installa dipendenze bundle (Docker)"
	@echo "  help       - Mostra questo messaggio"

serve:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="${PWD}/vendor/bundle:/usr/local/bundle:Z" \
		-p $(PORT):4000 \
		$(DOCKER_IMAGE) \
		jekyll serve

build:
	docker run --rm -it \
		--mount type=bind,source=${PWD},target=/srv/jekyll \
		--volume="${PWD}/vendor/bundle:/usr/local/bundle:Z" \
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
