SHELL := /bin/sh

SKILLS_DIR ?= skills
CODEX_HOME ?= $(HOME)/.codex
INSTALL_DIR ?= $(CODEX_HOME)/skills
INCLUDE_SYSTEM ?= 0

VALIDATOR := python3 $(SKILLS_DIR)/.system/skill-creator/scripts/quick_validate.py

.PHONY: list
list:
	@find "$(SKILLS_DIR)" -maxdepth 2 -name SKILL.md -print | sed 's,/SKILL.md$$,,g' | sort

.PHONY: validate
validate:
	@set -eu; \
	if [ ! -f "$(SKILLS_DIR)/.system/skill-creator/scripts/quick_validate.py" ]; then \
		echo "validator not found: $(SKILLS_DIR)/.system/skill-creator/scripts/quick_validate.py" >&2; \
		exit 1; \
	fi; \
	find "$(SKILLS_DIR)" -maxdepth 2 -name SKILL.md -print | sed 's,/SKILL.md$$,,g' | sort | while read -r d; do \
		echo "Validating $$d"; \
		$(VALIDATOR) "$$d"; \
	done

.PHONY: format
format:
	@set -eu; \
	if ! command -v markdownlint >/dev/null 2>&1; then \
		echo "markdownlint not found in PATH" >&2; \
		exit 1; \
	fi; \
	markdownlint $$(find . -name '*.md' -type f \
		-not -path './.git/*' \
		-not -path './.serena/*' \
		-not -path './skills/.system/*') --disable MD013

.PHONY: install
install:
	@set -eu; \
	mkdir -p "$(INSTALL_DIR)"; \
	find "$(SKILLS_DIR)" -maxdepth 1 -mindepth 1 -type d -print | while read -r d; do \
		base=$$(basename "$$d"); \
		if [ "$$base" = ".system" ] && [ "$(INCLUDE_SYSTEM)" != "1" ]; then \
			continue; \
		fi; \
		if [ "$$base" = ".system" ]; then \
			find "$$d" -maxdepth 1 -mindepth 1 -type d -print | while read -r sd; do \
				if [ -f "$$sd/SKILL.md" ]; then \
					name=$$(basename "$$sd"); \
					echo "Installing $$sd -> $(INSTALL_DIR)/$$name"; \
					rsync -a "$$sd/" "$(INSTALL_DIR)/$$name/"; \
				fi; \
			done; \
			continue; \
		fi; \
		if [ -f "$$d/SKILL.md" ]; then \
			echo "Installing $$d -> $(INSTALL_DIR)/$$base"; \
			rsync -a "$$d/" "$(INSTALL_DIR)/$$base/"; \
		fi; \
	done
