# ansible-automation Makefile
#
# Convenience wrapper around the most common ansible-playbook invocations.
# Run `make help` to see all targets.

# ---------------------------------------------------------------------------
# Configuration (override on the command line: make linux-web HOST=foo)
# ---------------------------------------------------------------------------
HOST                ?=
LIMIT               ?= $(HOST)
INVENTORY           ?= inventory/hosts
VAULT_PASSWORD_FILE ?= .vault_pass

# Common ansible-playbook flags
APB_FLAGS = -i $(INVENTORY) --diff
ifneq ($(wildcard $(VAULT_PASSWORD_FILE)),)
  APB_FLAGS += --vault-password-file $(VAULT_PASSWORD_FILE)
else
  APB_FLAGS += --ask-vault-pass
endif
ifneq ($(LIMIT),)
  APB_FLAGS += --limit $(LIMIT)
endif

# ---------------------------------------------------------------------------
# Help (default target)
# ---------------------------------------------------------------------------
.DEFAULT_GOAL := help
.PHONY: help
help:
	@echo "ansible-automation — common targets:"
	@echo ""
	@echo "  Setup"
	@echo "    make install           Install role library and Galaxy collections"
	@echo "    make setup             Run interactive first-time setup"
	@echo ""
	@echo "  Validation"
	@echo "    make lint              ansible-lint + yamllint over playbooks"
	@echo "    make syntax            ansible-playbook --syntax-check on every playbook"
	@echo "    make ping HOST=...     Verify connectivity to a host"
	@echo ""
	@echo "  Linux"
	@echo "    make linux HOST=...           Provision a generic Linux host"
	@echo "    make linux-web HOST=...       Provision a Linux web server"
	@echo "    make linux-db HOST=...        Provision a Linux database server"
	@echo "    make linux-app HOST=...       Provision a Linux app server"
	@echo ""
	@echo "  Windows"
	@echo "    make windows HOST=...                Provision a Windows server"
	@echo "    make windows-software HOST=...       Install standard software on Windows"
	@echo "    make windows-baseline HOST=...       Apply Windows baseline only"
	@echo ""
	@echo "  Top-level"
	@echo "    make site                     Run the full site.yml against everything"
	@echo "    make check                    Run site in --check mode (no changes)"
	@echo ""
	@echo "  Utilities"
	@echo "    make new-host NAME=foo OS=linux       Generate host_vars stub"
	@echo "    make encrypt FILE=path                ansible-vault encrypt FILE"
	@echo "    make edit-vault                       Edit vault.yml"
	@echo ""
	@echo "  Variables you can override on the command line:"
	@echo "    HOST=...      target host (sets LIMIT for you)"
	@echo "    LIMIT=...     pass a custom --limit (e.g. group name)"
	@echo "    INVENTORY=... path to inventory file (default inventory/hosts)"

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
.PHONY: install
install:
	ansible-galaxy collection install -r requirements.yml -p collections

.PHONY: setup
setup:
	./scripts/setup.sh

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
.PHONY: lint syntax ping
lint:
	./scripts/lint.sh

syntax:
	@for pb in $$(find playbooks -name '*.yml' -not -path '*/examples/*'); do \
	  echo "=== syntax-check: $$pb ==="; \
	  ansible-playbook -i $(INVENTORY) --syntax-check $$pb; \
	done

ping:
	@if [ -z "$(HOST)" ]; then echo "Usage: make ping HOST=hostname-or-group"; exit 1; fi
	ansible $(HOST) -i $(INVENTORY) -m ping

# ---------------------------------------------------------------------------
# Linux targets
# ---------------------------------------------------------------------------
.PHONY: linux linux-web linux-db linux-app
linux:
	@if [ -z "$(HOST)" ]; then echo "Usage: make linux HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/linux/build_linux_vm.yml

linux-web:
	@if [ -z "$(HOST)" ]; then echo "Usage: make linux-web HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/linux/build_linux_vm.yml
	ansible-playbook $(APB_FLAGS) playbooks/linux/configure_webserver.yml

linux-db:
	@if [ -z "$(HOST)" ]; then echo "Usage: make linux-db HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/linux/build_linux_vm.yml
	ansible-playbook $(APB_FLAGS) playbooks/linux/configure_dbserver.yml

linux-app:
	@if [ -z "$(HOST)" ]; then echo "Usage: make linux-app HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/linux/build_linux_vm.yml
	ansible-playbook $(APB_FLAGS) playbooks/linux/configure_appserver.yml

# ---------------------------------------------------------------------------
# Windows targets
# ---------------------------------------------------------------------------
.PHONY: windows windows-software windows-baseline
windows:
	@if [ -z "$(HOST)" ]; then echo "Usage: make windows HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/windows/build_windows_vm.yml
	ansible-playbook $(APB_FLAGS) playbooks/windows/configure_baseline.yml
	ansible-playbook $(APB_FLAGS) playbooks/windows/install_software.yml

windows-software:
	@if [ -z "$(HOST)" ]; then echo "Usage: make windows-software HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/windows/install_software.yml

windows-baseline:
	@if [ -z "$(HOST)" ]; then echo "Usage: make windows-baseline HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/windows/configure_baseline.yml

# ---------------------------------------------------------------------------
# Top-level
# ---------------------------------------------------------------------------
.PHONY: site check
site:
	ansible-playbook $(APB_FLAGS) playbooks/site.yml

check:
	ansible-playbook $(APB_FLAGS) --check playbooks/site.yml

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
.PHONY: new-host encrypt edit-vault
new-host:
	@if [ -z "$(NAME)" ] || [ -z "$(OS)" ]; then \
	  echo "Usage: make new-host NAME=hostname OS=linux|windows"; exit 1; \
	fi
	./scripts/new_host.sh $(NAME) $(OS)

encrypt:
	@if [ -z "$(FILE)" ]; then echo "Usage: make encrypt FILE=path/to/file"; exit 1; fi
	ansible-vault encrypt $(FILE)

edit-vault:
	ansible-vault edit inventory/group_vars/all/vault.yml
