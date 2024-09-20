SHELL := /usr/bin/env bash
POETRY_OK := $(shell type -P poetry)
POETRY_PATH := $(shell poetry env info --path)
POETRY_REQUIRED := $(shell cat .poetry-version)
PYTHON_OK := $(shell type -P python)
PYTHON_VERSION ?= $(shell python -V | cut -d' ' -f2 | cut -d'.' -f1,2')
PYTHON_REQUIRED := $(shell cat .python-version | cut -d'.' -f1,2')
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
POETRY_VIRTUALENVS_IN_PROJECT ?= true

TELEMETRY_INTERNAL_BASE_ACCOUNT_ID := 634456480543

help: ## The help text you're reading
	@grep --no-filename -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

clean: ## Clean the environment
	@poetry run task clean
.PHONY: clean

check_poetry: check_python ## Check Poetry installation
    ifeq ('$(POETRY_OK)','')
	    $(error package 'poetry' not found!)
    else
	    @echo Found `poetry --version`
    endif
.PHONY: check_poetry

check_python: ## Check Python installation
    ifeq ('$(PYTHON_OK)','')
	    $(error python interpreter: 'python' not found!)
    else
	    @echo Found Python
    endif
    ifneq ('$(PYTHON_REQUIRED)','$(PYTHON_VERSION)')
	    $(error incorrect version of python found: '${PYTHON_VERSION}'. Expected '${PYTHON_REQUIRED}'!)
    else
	    @echo Found `python --version`
    endif
.PHONY: check_python

reset: ## Teardown tooling
	rm $(POETRY_PATH) -r
.PHONY: reset

setup: check_poetry ## Setup virtualenv & dependencies using poetry and set-up the git hook scripts
	@export POETRY_VIRTUALENVS_IN_PROJECT=$(POETRY_VIRTUALENVS_IN_PROJECT) && poetry run pip install --upgrade pip
	@poetry install --no-root
	@poetry run pre-commit install

bandit: setup ## Run bandit against python code
	@poetry run task bandit
.PHONY: bandit

black: setup ## Run black against python code
	@poetry run task black
.PHONY: black

cut_release: ## Cut release
	@poetry run task cut_release
.PHONY: cut_release

safety: setup ## Run Safety
	@poetry run task safety
.PHONY: safety

test: setup ## Run functional and unit tests
	@poetry run task test
.PHONY: test

prepare_release: ## Runs prepare release
	@poetry run task prepare_release
.PHONY: prepare_release

verify: ## Run task verify
	@poetry run task verify
.PHONY: verify
