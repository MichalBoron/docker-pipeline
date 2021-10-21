SHELL := /bin/bash
TFBASEDIR := terraform/base
TFJENKINSDIR := terraform/jenkins

.PHONY: all build plan prep apply apply1 apply2 destroy ask

all: plan ask apply

build:
	@cd config && \
		docker build -t jenkins-custom:0.2 . && \
		docker tag jenkins-custom:0.2 localhost:5000/jenkins-custom && \
		docker push localhost:5000/jenkins-custom

prep:
	@cd $(TFBASEDIR) && terraform init
	@cd $(TFJENKINSDIR) && terraform init

plan: prep
	@cd $(TFBASEDIR) && terraform plan -out=tfplan
	@cd $(TFJENKINSDIR) && terraform plan -out=tfplan

destroy: prep
	@cd $(TFJENKINSDIR) && terraform destroy
	@cd $(TFBASEDIR) && terraform destroy

apply: apply1 build apply2

apply1: prep
	@cd $(TFBASEDIR) && terraform apply tfplan

apply2: prep
	@cd $(TFJENKINSDIR) && terraform apply tfplan

ask:
	@printf "\n\nProceed with these plans? Only 'yes' will be accepted to proceed.\n"
	@read -p "Enter a value: " PROCEED ; \
	if [ $$PROCEED != "yes" ] ; then printf "\nAborting...\n" ; exit 1 ; fi
