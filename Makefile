.PHONY: help build up down restart logs stats clean secret

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker-compose build

up: ## Start MTProxy in detached mode
	docker-compose up -d
	@echo ""
	@echo "Waiting for container to start..."
	@sleep 3
	@echo ""
	@echo "Getting connection information..."
	@docker-compose logs | tail -20

down: ## Stop and remove MTProxy container
	docker-compose down

restart: ## Restart MTProxy
	docker-compose restart
	@sleep 2
	@docker-compose logs --tail=20

logs: ## Follow MTProxy logs
	docker-compose logs -f

stats: ## Show proxy statistics URL
	@echo "Statistics available at:"
	@echo "http://$$(curl -s https://api.ipify.org):8888/stats"

secret: ## Generate a new random secret
	@echo "Generated secret:"
	@head -c 16 /dev/urandom | xxd -ps
	@echo ""
	@echo "Add this to docker-compose.yml under environment:"
	@echo "- SECRET=<generated_secret>"

clean: ## Remove containers, volumes, and data
	docker-compose down -v
	rm -rf data/
	@echo "Cleaned up MTProxy data"

status: ## Show MTProxy container status
	@docker-compose ps

rebuild: ## Rebuild and restart MTProxy
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@sleep 3
	@docker-compose logs --tail=20

install: build up ## Initial installation - build and start

update: ## Update MTProxy to latest version
	docker-compose down
	docker-compose build --pull --no-cache
	docker-compose up -d
	@sleep 3
	@docker-compose logs --tail=20
