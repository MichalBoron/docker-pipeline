SHELL := /bin/bash

TF_TASKS = prep plan apply destroy
TASKS = all help config ask destroyall $(TF_TASKS)
DIRS = base jenkins
.PHONY: $(TASKS) $(DIRS)

WORKDIR := terraform/base
RUN_ARGS := $(wordlist 3, $(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# For each argument define a target with a no-op rule
$(eval $(MAKECMDGOALS):;@:)

# By default run init, then: plan, ask, and apply for each
# terraform directory.
# Execute config target at the right time.
all: prep ## Automatically set up all components.
	$(MAKE) base
	$(MAKE) config
	$(MAKE) jenkins

destroyall: ## Destroy all components.
	$(MAKE) destroy jenkins
	$(MAKE) destroy base

# If a directory name was mentioned,
# execute commands in that context.
EXPLICIT_DIR := $(filter $(DIRS), $(MAKECMDGOALS))
ifneq ($(EXPLICIT_DIR),)
WORKDIR = terraform/$(EXPLICIT_DIR)
endif

# If executed as: make [dir_name]
# Example: make jenkins
# Then run plan, ask, and apply for that directory.
FIRST_ARG := $(firstword $(MAKECMDGOALS))
ifneq ($(filter $(DIRS), $(FIRST_ARG)),)
$(eval $(FIRST_ARG): plan ask apply)
endif

define ask =
@printf "\n\nProceed? Only 'yes' will be accepted to proceed.\n"
@read -p "Enter a value: " PROCEED ; \
if [ $$PROCEED != "yes" ] ; then printf "\nAborting...\n" ; exit 1 ; fi
endef

config: ## Configure jenkins image and push to repository.
	@cd config && \
		docker build -t jenkins-custom:0.2 . && \
		docker tag jenkins-custom:0.2 localhost:5000/jenkins-custom && \
		docker push localhost:5000/jenkins-custom

prep: ## Run terraform init in given subdirectory.
	@cd $(WORKDIR) && terraform init

plan: ## Run terraform plan in given subdirectory, output to file tfplan.
	@cd $(WORKDIR) && terraform plan -out=tfplan

apply: ## Run terraform apply (from file tfplan) in given subdirectory.
	@cd $(WORKDIR) && terraform apply tfplan

destroy:  ## Run terraform destroy in given subdirectory.
	@cd $(WORKDIR) && terraform destroy

ask:
	$(ask)

help: ## Prints help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
