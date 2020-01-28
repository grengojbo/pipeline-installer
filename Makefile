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
TAG ?= $(shell cat ./VERSION)
BUILD_DATE ?= $(shell date +%FT%T%z)
HELM_VERSION ?= "3.0.2"
KUBERNETES_VERSION ?= "1.17.2"
VCS_REF ?= $(git rev-parse --short HEAD)

WORKDIR ?= "${HOME}/.banzai/pipeline/${WORKSPACE}"

.PHONY: list
list: ## List all make targets
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

.PHONY: help
.DEFAULT_GOAL := help
help:
	@grep -h -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: terraform-provider
terraform-provider: ## Install yami terraform provider
	@cp .terraform.d/plugins/terraform-provider-helm .terraform/plugins/linux_amd64/terraform-provider-helm_v0.10.4_x4
	@cp .terraform.d/plugins/terraform-provider-yami .terraform/plugins/linux_amd64/terraform-provider-yami

# #
# 	mkdir -p .terraform.d/plugins/
# 	mkdir -p .terraform/plugins/darwin_amd64/
# 	mkdir -p .terraform/plugins/linux_amd64/
# 	cp ../terraform-provider-helm/build/terraform-provider-helm_linux_amd64/terraform-provider-helm_v0.0.0 .terraform/plugins/linux_amd64/terraform-provider-helm_v0.10.4_x4
# 	cp ../terraform-provider-helm/build/terraform-provider-helm_linux_amd64/terraform-provider-helm_v0.0.0 .terraform.d/plugins/terraform-provider-helm
# 	@ if [ ! -f .terraform/plugins/darwin_amd64/terraform-provider-yami ] ; \
# 	then \
# 	curl -sL https://banzaicloud.com/downloads/terraform-provider-yami/0.0.5/terraform-provider-yami_0.0.5_darwin_amd64.tar.gz -o - | tar -xzf - --directory .terraform/plugins/darwin_amd64/; \
# 	fi;
# 	@ if [ ! -f .terraform/plugins/linux_amd64/terraform-provider-yami ] ; \
# 	then \
# 	curl -sL https://banzaicloud.com/downloads/terraform-provider-yami/0.0.5/terraform-provider-yami_0.0.5_linux_amd64.tar.gz -o - | tar -xzf - --directory .terraform/plugins/linux_amd64/; \
# 	fi; 

.PHONY: terraform-init
terraform-init: terraform-provider ## Run terraform init
	terraform init

.PHONY: terraform-plan
terraform-plan: terraform-init ## Run terraform plan
	@echo "\nYour selected workspace is '${WORKSPACE}'\n"
	terraform apply -var workdir=${WORKDIR} -target=null_resource.preapply_hook -auto-approve
	terraform plan -var workdir=${WORKDIR}

.PHONY: terraform-apply
terraform-apply: terraform-init ## Run terraform apply
	@echo "Your selected workspace is '${WORKSPACE}'"
	terraform apply -var workdir=${WORKDIR} -target=null_resource.preapply_hook -auto-approve
	terraform apply -var workdir=${WORKDIR}

db-init: ## Initialize PostgreSQL DataBase
	@echo "Your selected workspace is '${WORKSPACE}'"
	@#terraform apply -var workdir=${WORKDIR} -target=null_resource.preapply_hook -auto-approve
	@#terraform apply -var workdir=${WORKDIR} -target=local_file.postgres_anchore_sql -auto-approve
	@#terraform apply -var workdir=${WORKDIR} -target=local_file.postgres_cicd_sql -auto-approve
	@#terraform apply -var workdir=${WORKDIR} -target=local_file.postgres_dex_sql -auto-approve
	@#terraform apply -var workdir=${WORKDIR} -target=local_file.postgres_vault_sql -auto-approve
	@#terraform apply -var workdir=${WORKDIR} -target=local_file.postgres_pipeline_sql -auto-approve
	@terraform apply -var workdir=${WORKDIR} -target=null_resource.db_init_anchore -auto-approve
	@terraform apply -var workdir=${WORKDIR} -target=null_resource.db_init_cicd -auto-approve
	@terraform apply -var workdir=${WORKDIR} -target=null_resource.db_init_dex -auto-approve
	@terraform apply -var workdir=${WORKDIR} -target=null_resource.db_init_pipeline -auto-approve
	@terraform apply -var workdir=${WORKDIR} -target=null_resource.db_init_vault -auto-approve

db-destroy: ## Destroy PostgreSQL DataBase
	@echo "Your selected workspace is '${WORKSPACE}'"
	@terraform destroy -var workdir=${WORKDIR} -target=null_resource.db_init_pipeline -auto-approve

build: ## Build Docker image ${IMAGE}:${TAG}
	docker build --build-arg BUILD_DATE=${BUILD_DATE} --build-arg VCS_REF=${VCS_REF} \
		--build-arg HELM_VERSION=${HELM_VERSION} --build-arg KUBERNETES_VERSION=${KUBERNETES_VERSION} \
		-t ${IMAGE}:${TAG} .

pull: ## Docker image pull ${IMAGE}:${TAG}
	docker pull ${IMAGE}:${TAG}

shell:  ## Run Local end connect to shell
	@echo "\nYour selected workspace is '${WORKSPACE}'\nCureent DIR ${PROJECT_DIR}\n"
	docker run --rm --net=host --user=${UID} -ti -v ${HOME}/.banzai/pipeline/${WORKSPACE}:/workspace \
		-v ${PROJECT_DIR}:/terraform -e KUBECONFIG=/workspace/kubeconfig \
		-e WORKDIR=/workspace ${IMAGE}:${TAG} sh