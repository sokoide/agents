SKILLS_DIR := skills
VALIDATE_SCRIPT := $(SKILLS_DIR)/.system/skill-creator/scripts/quick_validate.py
INSTALL_DEST := $(HOME)/.agents/skills

.PHONY: validate
validate:
	@for skill in $$(find $(SKILLS_DIR) -maxdepth 1 -mindepth 1 -type d ! -name ".*"); do \
		echo "Validating $$skill..."; \
		uv run --with PyYAML $(VALIDATE_SCRIPT) "$$skill"; \
	done

.PHONY: install
install:
	@echo "Installing skills to $(INSTALL_DEST)..."
	mkdir -p $(INSTALL_DEST)
	rsync -av --delete $(SKILLS_DIR)/ $(INSTALL_DEST)/
