# CMS-DX: the same commands as every DX repo (`make help`).
# `make setup` once, then `make dev` runs Strapi on this machine, with SQLite by
# default. To run the whole DX stack, in Docker or not, use infra.dx.

IMAGE ?= dx-cms:local

.DEFAULT_GOAL := help
.PHONY: help setup dev build node-version

help: ## List the commands
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  %-10s %s\n", $$1, $$2}'

setup: node-version ## Install dependencies, create .env
	yarn install
	@[ -f .env ] || { cp .env.example .env && echo "Created .env from .env.example"; }

dev: ## Run Strapi on http://localhost:1337 (admin at /admin), reloading on changes
	@[ -f .env ] || { echo "No .env yet: run make setup." >&2; exit 1; }
	yarn develop

build: ## Build the Docker image, as CI does
	docker build -t $(IMAGE) .

node-version:
	@want="$$(cut -d. -f1 .nvmrc)"; have="$$(node --version 2>/dev/null | sed 's/^v//; s/\..*//')"; \
	[ "$$want" = "$$have" ] || echo "Note: this repo uses Node $$(cat .nvmrc) (.nvmrc) and you have $$(node --version 2>/dev/null || echo none). Run: nvm use"
