PROJECT_DIR = $(shell pwd)

.ONESHELL:
.SHELL := /bin/bash

ENV_FILE = $(PROJECT_DIR)/.env

ifneq ("$(wildcard $(ENV_FILE))","")
	include .env
	export
endif

WORKSPACE ?= default
IMAGE ?= banzaicloud/pipeline-installer
TTAG=$(shell cat ./VERSION)

.PHONY: list
list: ## List all make targets
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

.PHONY: help
.DEFAULT_GOAL := help
help:
	@grep -h -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: terraform-provider-yami
terraform-provider-yami: ## Install yami terraform provider
	mkdir -p .terraform/plugins/darwin_amd64/
	@ if [ ! -f .terraform/plugins/darwin_amd64/terraform-provider-yami ] ; \
	then \
	curl -sL https://banzaicloud.com/downloads/terraform-provider-yami/0.0.5/terraform-provider-yami_0.0.5_darwin_amd64.tar.gz -o - | tar -xzf - --directory .terraform/plugins/darwin_amd64/; \
	fi;

.PHONY: terraform-init
terraform-init: terraform-provider-yami ## Run terraform init
	terraform init

.PHONY: terraform-plan
terraform-plan: terraform-init ## Run terraform plan
	@echo "\nYour selected workspace is '${WORKSPACE}'\n"
	terraform apply -var workdir=${HOME}/.banzai/pipeline/${WORKSPACE} -target=null_resource.preapply_hook -auto-approve
	terraform plan -var workdir=${HOME}/.banzai/pipeline/${WORKSPACE}

.PHONY: terraform-apply
terraform-apply: terraform-init ## Run terraform apply
	@echo "\nYour selected workspace is '${WORKSPACE}'\n"
	terraform apply -var workdir=${HOME}/.banzai/pipeline/${WORKSPACE} -target=null_resource.preapply_hook -auto-approve
	terraform apply -var workdir=${HOME}/.banzai/pipeline/${WORKSPACE}

db-init-postgresql: ## Initialize PostgreSQL DataBase
	@echo "\nYour selected workspace is '${WORKSPACE}'\n"

shell: ## Run Local end connect to shell
	@echo "\nYour selected workspace is '${WORKSPACE}'\nCureent DIR ${PROJECT_DIR}\n"
	docker run --rm --net=host --user=502 -ti -v ${HOME}/.banzai/pipeline/${WORKSPACE}:/workspace -v ${PROJECT_DIR}:/terraform -e KUBECONFIG docker.io/banzaicloud/pipeline-installer:latest sh