#!/usr/bin/env bash
# scripts/setup.sh — first-time setup for ansible-automation
#
# What this script does:
#   1. Checks for required tools (ansible, python, ssh, sshpass, etc.)
#   2. Installs Galaxy collections from requirements.yml
#      (role library is bundled at ./roles — no install needed)
#   3. Copies inventory.example/ -> inventory/ if not already present
#   4. Walks you through setting a vault password
#   5. Prints a "next steps" summary
#
# Re-running this is safe — it only does steps that haven't been done.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# --- color helpers ---------------------------------------------------------
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
err()  { printf '  \033[31m✗\033[0m %s\n' "$*"; }
hdr()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
ask()  { printf '  \033[36m?\033[0m %s ' "$*"; }

# ---------------------------------------------------------------------------
# 1. Tool checks
# ---------------------------------------------------------------------------
hdr "Checking required tools..."

missing=0
need_tool() {
  local tool="$1"
  local how="$2"
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool"
  else
    err "$tool is not installed — install with: $how"
    missing=1
  fi
}

need_tool python3      "package manager (e.g. apt install python3)"
need_tool pip3         "package manager (e.g. apt install python3-pip)"
need_tool ansible      "pip3 install --user ansible-core"
need_tool ansible-playbook "pip3 install --user ansible-core"
need_tool ssh          "package manager (e.g. apt install openssh-client)"
need_tool git          "package manager (e.g. apt install git)"

# Optional but recommended
hdr "Checking optional tools..."
optional_tool() {
  local tool="$1"
  local why="$2"
  if command -v "$tool" >/dev/null 2>&1; then
    ok "$tool ($why)"
  else
    warn "$tool not found — you'll need this for: $why"
  fi
}
optional_tool sshpass    "first-time SSH password auth to fresh Linux hosts"
optional_tool ansible-lint "make lint"
optional_tool yamllint   "make lint"

# Python libraries
hdr "Checking Python libraries..."
check_pylib() {
  local mod="$1"
  local install="$2"
  local why="$3"
  if python3 -c "import $mod" 2>/dev/null; then
    ok "python3-$mod"
  else
    warn "python3 module '$mod' not installed (install with: pip3 install $install) — needed for: $why"
  fi
}
check_pylib pyVmomi  pyvmomi  "vSphere VM creation (community.vmware)"
check_pylib winrm    pywinrm  "Windows hosts (ansible.windows)"
check_pylib jmespath jmespath "json_query filter (used by some roles)"

if [ "$missing" -ne 0 ]; then
  err ""
  err "One or more required tools is missing. Install them and re-run."
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Install Galaxy collections
# ---------------------------------------------------------------------------
hdr "Installing Galaxy collections..."
mkdir -p collections
ansible-galaxy collection install -r requirements.yml -p collections >/dev/null
ok "collections installed"
ok "role library is bundled at ./roles (no install needed)"

# ---------------------------------------------------------------------------
# 3. Copy inventory.example/ -> inventory/
# ---------------------------------------------------------------------------
hdr "Inventory..."
if [ -d "inventory" ]; then
  ok "inventory/ already exists — leaving alone"
else
  cp -r inventory.example inventory
  ok "created inventory/ from inventory.example/"
  warn "edit inventory/hosts to list your real hosts"
  warn "edit inventory/group_vars/all/main.yml to set your domain etc."
fi

# ---------------------------------------------------------------------------
# 4. Vault password
# ---------------------------------------------------------------------------
hdr "Vault password..."
if [ -f ".vault_pass" ]; then
  ok ".vault_pass already exists — leaving alone"
else
  ask "Create a vault password file (.vault_pass) now? [y/N]"
  read -r reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    ask "Enter the password (will be saved to .vault_pass and gitignored):"
    read -rs pw
    echo
    if [ -z "$pw" ]; then
      warn "empty password — skipping"
    else
      printf '%s\n' "$pw" > .vault_pass
      chmod 600 .vault_pass
      ok ".vault_pass created (mode 600)"
    fi
  else
    warn "skipped — you'll be prompted with --ask-vault-pass on every run"
  fi
fi

# ---------------------------------------------------------------------------
# 5. Vault file
# ---------------------------------------------------------------------------
hdr "Vault file..."
VAULT_FILE="inventory/group_vars/all/vault.yml"
VAULT_EXAMPLE="inventory/group_vars/all/vault.yml.example"

if [ -f "$VAULT_FILE" ]; then
  ok "$VAULT_FILE already exists"
else
  if [ -f "$VAULT_EXAMPLE" ]; then
    cp "$VAULT_EXAMPLE" "$VAULT_FILE"
    ok "created $VAULT_FILE from example"
    warn "edit it ('make edit-vault') to set your real secrets"
    warn "then encrypt it: ansible-vault encrypt $VAULT_FILE"
  else
    warn "no vault.yml.example found — skipping"
  fi
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
hdr "Setup complete."
cat <<EOF

Next steps:
  1. Edit inventory/hosts to list your hosts:
       \$EDITOR inventory/hosts
  2. Set environment-wide variables:
       \$EDITOR inventory/group_vars/all/main.yml
  3. Add your secrets:
       make edit-vault
       (or: ansible-vault edit inventory/group_vars/all/vault.yml)
  4. Verify connectivity to a host:
       make ping HOST=foo.example.coach
  5. Build a Linux web server end-to-end:
       make linux-web HOST=foo.example.coach

Documentation:
  - docs/QUICKSTART.md      First-VM walkthrough
  - docs/INVENTORY.md       Inventory format reference
  - docs/VARIABLES.md       What every variable does
  - docs/SECRETS.md         Vault setup
  - make help               All available targets
EOF
