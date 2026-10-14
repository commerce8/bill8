# SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
# SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
# SPDX-FileCopyrightText: Copyright Contributors to the Bill8
# SPDX-License-Identifier: Apache-2.0

# Makefile — bill8/ vertical group (RS §4.4)
#
# Group build in DAG order: the bill8-sdk facade first, then the services.
# NO docker-compose here — the platform group (../sentin8/) owns the dev
# infra (PostgreSQL 18 + Valkey, §2.2.1); this vertical's services consume
# it over localhost. Each child repo is independent; its own `cargo build`
# is self-sufficient — this file is convenience.

SHELL := /bin/bash
CARGO ?= cargo

SERVICES := billing ledger payments reporting risk webhooks
APPS := admin checkout merchant portal

.PHONY: help build build-sdk build-services test status enroll

help: ## Show this help
	@echo "bill8/ vertical group"
	@grep -E '^[a-z-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

build: build-sdk build-services ## Build the group in DAG order

build-sdk: ## Build the bill8 facade workspace (services depend on this)
	@cd bill8-sdk && $(CARGO) build

build-services: build-sdk ## Build every bill8 service repo
	@for s in $(SERVICES); do \
		echo "=== bill8-$$s ==="; \
		(cd bill8-$$s && $(CARGO) build) || exit 1; \
	done

test: ## Run the SDK facade tests + per-service suites
	@cd bill8-sdk && $(CARGO) test
	@for s in $(SERVICES); do (cd bill8-$$s && $(CARGO) test) || true; done

enroll: ## Enroll every bill8 repo (composable registration, RS §6)
	@cd ../sentin8/sentin8-cli && $(CARGO) run --bin sentin8-cli -- vertical enroll \
		$(patsubst %,../../bill8/bill8-%,$(SERVICES)) \
		$(patsubst %,../../bill8/bill8-%,$(APPS))

status: ## Per-repo HEADs
	@for d in */; do \
		[ -d "$$d/.git" ] || continue; \
		printf "%-22s %s\n" "$$d" "$$(git -C $$d log --oneline -1 2>/dev/null | head -c 60)"; \
	done
