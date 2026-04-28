#!/usr/bin/env bash
# scripts/lint.sh — run yamllint and ansible-lint over the repo
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# yamllint over playbooks and inventory.example
if command -v yamllint >/dev/null 2>&1; then
  echo "==> yamllint"
  yamllint playbooks/ inventory.example/ requirements.yml || true
else
  echo "yamllint not installed — skipping (pip install yamllint)"
fi

# ansible-lint over playbooks
if command -v ansible-lint >/dev/null 2>&1; then
  echo "==> ansible-lint"
  ansible-lint playbooks/ -x risky-shell-pipe,no-changed-when || true
else
  echo "ansible-lint not installed — skipping (pip install ansible-lint)"
fi
