# Inventory Reference

This repo uses standard Ansible INI-format inventory. The file lives at
`inventory/hosts` (created from `inventory.example/hosts` by setup).

## File structure

```
inventory/
├── hosts                            # Lists hosts in groups
├── group_vars/
│   ├── all/main.yml                 # Vars for EVERY host
│   ├── all/vault.yml                # Encrypted secrets
│   ├── linux/main.yml               # Vars for [linux] group
│   ├── windows/main.yml             # Vars for [windows] group
│   ├── webservers/main.yml          # Vars for [webservers]
│   ├── dbservers/main.yml           # Vars for [dbservers]
│   └── appservers/main.yml          # Vars for [appservers]
└── host_vars/
    └── <hostname>.yml               # Per-host overrides
```

## Required groups

The playbooks here assume specific groups exist. **Do not rename them.**

| Group | Members | Used by |
|-------|---------|---------|
| `webservers` | Linux web hosts | `playbooks/linux/configure_webserver.yml` |
| `dbservers`  | Linux DB hosts  | `playbooks/linux/configure_dbserver.yml` |
| `appservers` | Linux app hosts | `playbooks/linux/configure_appserver.yml` |
| `windows`    | Windows hosts   | All `playbooks/windows/*.yml` |
| `linux`      | Children of webservers/dbservers/appservers | `playbooks/linux/build_linux_vm.yml` |
| `infrastructure` | Children of linux + windows | `playbooks/site.yml` (top-level) |

The `:children` rollups MUST be present:

```ini
[linux:children]
webservers
dbservers
appservers

[infrastructure:children]
linux
windows
```

## Adding a host

```bash
# 1. Generate a host_vars stub
make new-host NAME=app03.your.domain OS=linux

# 2. Add the hostname to inventory/hosts
$EDITOR inventory/hosts
# under the right group:
#   [appservers]
#   app03.your.domain

# 3. Edit the host_vars file to set vSphere placement, IP, etc.
$EDITOR inventory/host_vars/app03.your.domain.yml
```

## Adding a new group

If you want a new tier (e.g., `cache`):

1. Add the group to `inventory/hosts`:
   ```ini
   [cache]
   redis01.your.domain
   redis02.your.domain
   ```
2. Add it to the `[linux:children]` rollup if it's Linux:
   ```ini
   [linux:children]
   webservers
   dbservers
   appservers
   cache             <- new
   ```
3. Create `inventory/group_vars/cache/main.yml` with tier-specific defaults
4. Optionally create `playbooks/linux/configure_cache.yml` — see
   [EXTENDING.md](EXTENDING.md) for the pattern

## Variable precedence

Lowest priority → highest. Later wins.

1. `roles/<role>/defaults/main.yml` — role defaults
2. `inventory/group_vars/all/main.yml` — environment-wide
3. `inventory/group_vars/<group>/main.yml` — per-group
4. `inventory/host_vars/<host>.yml` — per-host
5. `--extra-vars 'foo=bar'` on the command line — highest

In practice:

- **Stuff every host needs** → `group_vars/all/main.yml`
- **Tier-wide config** → `group_vars/<tier>/main.yml`
- **Different on this one host** → `host_vars/<host>.yml`
- **Secrets** → `group_vars/all/vault.yml` (encrypted)

## Connection settings

### Linux (SSH)

Defaults are set in `inventory/hosts`:

```ini
[all:vars]
ansible_user=ansible
ansible_python_interpreter=/usr/bin/python3
```

Override per-host if needed:

```yaml
# host_vars/legacy01.your.domain.yml
ansible_user: rhel-old-admin
ansible_python_interpreter: /usr/bin/python2
```

### Windows (WinRM)

Set in `inventory/hosts`:

```ini
[windows:vars]
ansible_connection=winrm
ansible_port=5986
ansible_winrm_scheme=https
ansible_winrm_transport=ntlm
ansible_winrm_server_cert_validation=ignore
```

User and password come from `group_vars/windows/main.yml` and the vault.

## Real-world inventory examples

The `inventory.example/` tree models a typical 3-tier deployment:

- 2 web servers behind a load balancer
- 2 DB servers (primary + replica)
- 3 app servers
- 2 Windows servers (one app host, one file server)

Use it as a starting point. Delete what you don't need.
