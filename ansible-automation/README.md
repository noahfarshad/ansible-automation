# ansible-automation

> Self-contained Ansible automation for **essential.coach** infrastructure.
> Build Linux and Windows VMs end-to-end. Configure them with any of 350
> bundled roles. One `git clone` gives you everything.

This repo bundles:

- **350 production-tested roles** in `roles/` — packages, services,
  configuration, identity, networking, monitoring, and more
- **Ready-to-run playbooks** in `playbooks/` — paved-path orchestration
  for the most common build patterns
- **Worked-example inventory** in `inventory.example/` — copy, customize, run

You don't write Ansible from scratch. You fill in your inventory and
run the playbooks. The roles do the heavy lifting.

---

## What you can do

| Goal | Run | Time |
|------|-----|------|
| Stand up a Linux web server end-to-end | `make linux-web HOST=web01.example.coach` | ~15 min |
| Stand up a Linux DB server end-to-end | `make linux-db HOST=db01.example.coach` | ~15 min |
| Stand up a Windows server (joined to AD) | `make windows HOST=win01.example.coach` | ~25 min |
| Install standard software on existing Windows | `make windows-software HOST=win01.example.coach` | ~10 min |
| Build everything in your inventory | `make site` | varies |

You can also use any of the 350 roles directly in your own custom playbooks —
see [`docs/EXTENDING.md`](docs/EXTENDING.md) and the per-role `README.md` files
under `roles/<rolename>/`.

---

## Quick start

```bash
# 1. Clone (this gives you all 350 roles immediately)
git clone https://github.com/noahfarshad/ansible-automation.git
cd ansible-automation

# 2. One-time setup: install required collections, copy inventory.example -> inventory
./scripts/setup.sh

# 3. Edit your inventory + secrets
$EDITOR inventory/hosts                                # add your real hosts
$EDITOR inventory/group_vars/all/main.yml              # set your domain, etc.
ansible-vault edit inventory/group_vars/all/vault.yml  # set passwords

# 4. Build a host
make linux-web HOST=web01.example.coach
```

Each step is documented in detail in **[`docs/QUICKSTART.md`](docs/QUICKSTART.md)**.

---

## Repository layout

```
ansible-automation/
├── ansible.cfg                 # Ansible config (points at roles/, inventory/)
├── Makefile                    # Targets: linux-web, windows, site, lint, ...
├── requirements.yml            # Galaxy collections (no role lib — it's bundled)
│
├── roles/                      # ★ 350 ROLES — the full library, in-tree
│   ├── install_apache/
│   ├── configure_winrm/
│   ├── join_windows_active_directory/
│   ├── install_db/
│   ├── configure_volumes/
│   ├── ...                     # see docs/ROLE_INVENTORY.md for the full list
│   └── ...
│
├── playbooks/
│   ├── linux/
│   │   ├── build_linux_vm.yml          # Create vSphere VM + Linux baseline
│   │   ├── configure_webserver.yml     # Apache + cert + firewall
│   │   ├── configure_dbserver.yml      # PostgreSQL + tuning + backups
│   │   └── configure_appserver.yml     # WebLogic / app-tier baseline
│   ├── windows/
│   │   ├── build_windows_vm.yml        # Create VM + WinRM + AD join
│   │   ├── install_software.yml        # 7zip / Chrome / VS Code / ...
│   │   └── configure_baseline.yml      # GPO link, time, features
│   ├── examples/                       # Reference playbooks (don't run blind)
│   └── site.yml                        # Top-level orchestrator
│
├── inventory.example/                  # Copy this to inventory/, customize
│   ├── hosts                            # Inventory file (groups + hosts)
│   ├── group_vars/
│   │   ├── all/main.yml                # Variables that apply to every host
│   │   ├── all/vault.yml.example       # Encrypted-secrets template
│   │   ├── linux/main.yml              # Linux-specific defaults
│   │   ├── windows/main.yml            # Windows-specific defaults
│   │   ├── webservers/main.yml         # Apache / web-tier
│   │   ├── dbservers/main.yml          # DB-tier
│   │   └── appservers/main.yml         # App-tier
│   └── host_vars/
│       ├── web01.example.coach.yml     # Per-host overrides
│       └── win01.example.coach.yml
│
├── collections/                        # Galaxy collections (gitignored)
├── scripts/
│   ├── setup.sh                        # First-time setup (interactive)
│   ├── lint.sh                         # ansible-lint + yamllint
│   └── new_host.sh                     # Generate a host_vars stub
└── docs/                               # Detailed docs
    ├── QUICKSTART.md
    ├── INVENTORY.md
    ├── VARIABLES.md
    ├── LINUX_VM.md
    ├── WINDOWS_VM.md
    ├── SECRETS.md
    ├── TROUBLESHOOTING.md
    ├── EXTENDING.md
    └── ROLE_INVENTORY.md               # full list of bundled roles by category
```

---

## Documentation

| File | What it covers |
|------|----------------|
| [`docs/QUICKSTART.md`](docs/QUICKSTART.md) | Step-by-step from clone → first VM built |
| [`docs/INVENTORY.md`](docs/INVENTORY.md) | How to write your inventory; what every group means |
| [`docs/VARIABLES.md`](docs/VARIABLES.md) | Every variable you can set, where to set it, what it does |
| [`docs/LINUX_VM.md`](docs/LINUX_VM.md) | What `make linux-*` does and how to customize |
| [`docs/WINDOWS_VM.md`](docs/WINDOWS_VM.md) | What `make windows*` does and how to customize |
| [`docs/SECRETS.md`](docs/SECRETS.md) | Vault setup; what secrets you need; how to encrypt |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Common errors and fixes |
| [`docs/EXTENDING.md`](docs/EXTENDING.md) | Add a playbook / host group / role |
| [`docs/ROLE_INVENTORY.md`](docs/ROLE_INVENTORY.md) | All 350 bundled roles by category |

---

## Requirements on your workstation

- **Ansible 2.16+** (we recommend `ansible-core` from pip)
- **Python 3.10+**
- **`sshpass`** (for first-time SSH to fresh Linux hosts)
- **`pywinrm`** (for Windows hosts) — `pip install pywinrm`
- **`pyvmomi`** (for vSphere VM creation) — `pip install pyvmomi`
- **A vSphere/vCenter you can reach** with permissions to create VMs
- **A vault password** to decrypt secrets (you'll set this in step 2)

`./scripts/setup.sh` checks all of these and tells you what's missing.

---

## Why bundled, not Galaxy-installed?

Two reasons:

1. **One clone, ready to run.** No extra `ansible-galaxy install` step,
   no need for clone access to multiple repos, no version-skew between
   the playbooks and the role library.
2. **The roles are versioned alongside the playbooks that use them.** A
   change to a role and the playbook that calls it lands in the same PR,
   the same commit, the same tag.

The trade-off is repo size (~25 MB) — fine for a working tool.

If you want to use these roles in a different consumer repo, copy the
ones you need into that repo's `roles/` directory, or fork this one.

---

## Privacy & IP

- This repo contains **no customer-identifying material** — placeholders use
  `example.coach`. You replace those with your environment's values in
  `inventory/`.
- `inventory/` is in `.gitignore` — your real hosts and secrets never land
  in the repo. Only `inventory.example/` is committed.

---

## Contributing

Bugs in playbooks or docs → PR against this repo.
Bugs or improvements in roles → also PR against this repo (the roles live
in `roles/`).
