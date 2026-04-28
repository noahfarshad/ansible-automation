# inventory.example/

This directory is the **template** for your real inventory. The setup
script (`./scripts/setup.sh`) copies this whole tree to `inventory/`,
which is in `.gitignore` so your real hosts and secrets never end up
in the repo.

## What's here

| File | Purpose |
|------|---------|
| `hosts` | The inventory file — lists hosts and groups |
| `group_vars/all/main.yml` | Variables that apply to **every** host |
| `group_vars/all/vault.yml.example` | Template for secrets (rename, edit, encrypt) |
| `group_vars/linux/main.yml` | Linux-only defaults (used by `[linux]` group) |
| `group_vars/windows/main.yml` | Windows-only defaults |
| `group_vars/webservers/main.yml` | Web-tier defaults (Apache config, etc.) |
| `group_vars/dbservers/main.yml` | DB-tier defaults |
| `group_vars/appservers/main.yml` | App-tier defaults |
| `host_vars/<hostname>.yml` | Per-host overrides (one file per host) |

## Variable precedence

Lowest priority → highest priority (later wins):

1. `roles/<role>/defaults/main.yml` — role's own defaults
2. `group_vars/all/main.yml` — environment-wide
3. `group_vars/<group>/main.yml` — group-specific (linux, windows, webservers, ...)
4. `host_vars/<hostname>.yml` — per-host overrides
5. `--extra-vars` on the command line — highest

## Adding a new host

```bash
# 1. Generate a host_vars stub
make new-host NAME=web03.example.coach OS=linux

# 2. Add the hostname to inventory/hosts under the right group
$EDITOR inventory/hosts
#   [webservers]
#   web03.example.coach   <- add this

# 3. Edit the host_vars stub to set its IP, vSphere details, etc.
$EDITOR inventory/host_vars/web03.example.coach.yml
```

See **[`docs/INVENTORY.md`](../docs/INVENTORY.md)** for full reference.
