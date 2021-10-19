SHELL := /bin/bash

.PHONY: all build plan prep apply apply1 apply2 destroy ask

all: plan ask apply

build:
	@cd jenkinscasc && \
		docker build -t jenkins-custom:0.2 . && \
		docker tag jenkins-custom:0.2 localhost:5000/jenkins-custom && \
		docker push localhost:5000/jenkins-custom

prep:
	@cd phase1 && terraform init
	@cd phase2 && terraform init

plan: prep
	@cd phase1 && terraform plan -out=tfplan
	@cd phase2 && terraform plan -out=tfplan

destroy: prep
	@cd phase2 && terraform destroy
	@cd phase1 && terraform destroy

apply: apply1 build apply2

apply1: prep
	@cd phase1 && terraform apply tfplan

apply2: prep
	@cd phase2 && terraform apply tfplan

ask:
	@printf "\n\nProceed with these plans? Only 'yes' will be accepted to proceed.\n"
	@read -p "Enter a value: " PROCEED ; \
	if [ $$PROCEED != "yes" ] ; then printf "\nAborting...\n" ; exit 1 ; fi
