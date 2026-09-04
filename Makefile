export AWS_ACCESS_KEY_ID ?= test
export AWS_SECRET_ACCESS_KEY ?= test
export AWS_DEFAULT_REGION=us-east-1
APPSYNC_URL = http://localhost:4566/graphql
SHELL := /bin/bash

usage:       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

install:     ## Install dependencies
	@test -e node_modules || yarn install
	@which lstk || npm install -g @localstack/lstk
	@test -e .venv || (python3 -m venv .venv; source .venv/bin/activate; pip install -r requirements.txt)

run:         ## Deploy the app locally and run an AppSync GraphQL test invocation
	./run.sh

start:		## Start LocalStack
	@test -n "${LOCALSTACK_AUTH_TOKEN}" || (echo "LOCALSTACK_AUTH_TOKEN is not set. Find your token at https://app.localstack.cloud/workspace/auth-token"; exit 1)
	@LOCALSTACK_AUTH_TOKEN=$(LOCALSTACK_AUTH_TOKEN) lstk start --non-interactive

stop:
	@echo
	lstk stop
ready:
	@echo Waiting on the LocalStack container...
	@lstk status && echo Localstack is ready to use! || (echo Gave up waiting on LocalStack, exiting. && exit 1)

logs:
	@lstk logs > logs.txt

test-ci:
	make start install ready run; return_code=`echo $$?`;\
	make logs; make stop; exit $$return_code;

.PHONY: usage install start run stop ready logs test-ci
