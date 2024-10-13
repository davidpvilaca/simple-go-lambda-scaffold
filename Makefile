.DEFAULT_GOAL := prepare

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: prepare
prepare: ## Prepare the environment
	@make -s env
	@make -s up-docker
	@make -s install
	@make -s build
	@make -s up-infra

.PHONY: env
env: ## Create the .env file and export the variables
	@echo "Creating the .env file"
	@cp .env.example .env
	@eval $(egrep -v '^#' .env | xargs)

.PHONY: up-docker
up-docker: ## Start the docker containers
	@echo "Starting the docker containers"
	@docker compose up -d
	@echo "Docker containers started"

.PHONY: up-infra
up-infra: ## Start the infrastructure
	@echo "Starting the infrastructure"
	@cd infra && terraform init && terraform apply -auto-approve
	@echo "Infrastructure started"

.PHONY: install
install: ## Install the dependencies
	@echo "Installing the dependencies"
	@go mod download
	@echo "Dependencies installed"

.PHONY: build
build: ## Build the lambda
	@make -s build-generate-report
	@make -s build-unzip

.PHONY: build-generate-report
build-generate-report: ## Build the generate-report lambda
	@echo "Building the generate-report lambda"
	@GOOS=linux CGO_ENABLED=0 go build -o bin/generate-report cmd/generate-report/generate-report.go
	@zip -j bin/generate-report.zip bin/generate-report
	@echo "Lambda builded"

.PHONY: build-unzip`
build-unzip: ## Build the unzip lambda
	@echo "Building the unzip lambda"
	@GOOS=linux CGO_ENABLED=0 go build -o bin/unzip cmd/unzip/unzip.go
	@zip -j bin/unzip.zip bin/unzip
	@echo "Lambda builded"

.PHONY: run
run: ## Run lambda locally with name of the function in first argument
	@echo "Running the lambda locally"
	@aws --endpoint-url=http://localhost:4566 \
		lambda invoke --function-name $(function) \
		--payload file://infra/payloads/$(function).json \
		--output json output.json
	@echo "" >> output.json
	@echo "Lambda output:"
	@cat output.json

.PHONY: clean
clean: ## Clean the project
	@echo "Cleaning the project"
	@cd infra && terraform destroy -auto-approve
	@rm -rf bin
	@rm -rf output.json
	@rm -rf infra/terraform.tfstate
	@rm -rf infra/terraform.tfstate.backup
	@rm -rf infra/.terraform*
	@docker compose down
	@echo "Project cleaned"
