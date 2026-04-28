# Extending the repo

How to add a new playbook, host group, or role.

---

## Add a new host

Easiest path:

```bash
make new-host NAME=foo.your.domain OS=linux
$EDITOR inventory/host_vars/foo.your.domain.yml
$EDITOR inventory/hosts        # add foo.your.domain under the right group
```

That's it. The new host inherits all group defaults; override what's
different in its `host_vars/` file.

---

## Add a new tier (host group)

Say you want a `cache` tier for Redis hosts.

### 1. Add the group to `inventory.example/hosts`

```ini
[cache]
redis01.example.coach
redis02.example.coach

[linux:children]
webservers
dbservers
appservers
cache         <- add this
```

### 2. Create tier-wide defaults

```bash
mkdir -p inventory.example/group_vars/cache
$EDITOR inventory.example/group_vars/cache/main.yml
```

Pattern: tier-specific software, ports, and Splunk inputs.

```yaml
---
# group_vars/cache/main.yml

redis_listen_port:    6379
redis_max_memory:     "4gb"
redis_max_memory_policy: "allkeys-lru"
redis_password:       "{{ vault_redis_password }}"

firewall_open_tcp_ports:
  - 22
  - "{{ redis_listen_port }}"

splunk_forwarder_inputs:
  - path:        /var/log/redis/redis.log
    index:       "{{ splunk_index }}_cache"
    sourcetype:  redis
```

### 3. Create the tier-configuration playbook

Copy an existing one as a starting point:

```bash
cp playbooks/linux/configure_dbserver.yml playbooks/linux/configure_cache.yml
$EDITOR playbooks/linux/configure_cache.yml
```

Edit:

- Change `hosts: dbservers` → `hosts: cache`
- Change the role list to whatever applies (`install_redis`, etc. — check
  the role library)
- Update assertions to match

### 4. Add a Make target (optional)

In `Makefile`:

```make
.PHONY: linux-cache
linux-cache:
	@if [ -z "$(HOST)" ]; then echo "Usage: make linux-cache HOST=hostname"; exit 1; fi
	ansible-playbook $(APB_FLAGS) playbooks/linux/build_linux_vm.yml
	ansible-playbook $(APB_FLAGS) playbooks/linux/configure_cache.yml
```

Add `linux-cache` to the help text under "Linux".

### 5. Add to site.yml (optional)

If `make site` should build cache hosts too:

```yaml
# playbooks/site.yml
- import_playbook: linux/configure_cache.yml
```

### 6. Document in VARIABLES.md

Add a section for `group_vars/cache/main.yml` so future readers know
what the tier expects.

---

## Add a new playbook

Create a new file in `playbooks/linux/` or `playbooks/windows/`.

Skeleton:

```yaml
---
# playbooks/linux/something_new.yml
#
# What this does in 2-3 sentences.
#
# Usage:
#   make something-new HOST=foo.your.domain
#   # or:
#   ansible-playbook -i inventory/hosts \
#                    playbooks/linux/something_new.yml \
#                    --limit foo.your.domain
#
# REQUIRED variables: ...

- name: Do the thing
  hosts: <appropriate-group>
  gather_facts: true
  become: true
  vars:
    desired_state: present

  pre_tasks:
    - name: Sanity check
      ansible.builtin.assert:
        that: ...

  roles:
    - { role: <role-name>, tags: [...] }

  post_tasks:
    - name: Verify
      ansible.builtin.command: ...
      changed_when: false
```

Then add it to `Makefile` and (optionally) `site.yml`.

---

## Use a role that isn't bundled yet

The role library is bundled at `roles/`. There are 350 roles already; see
[`docs/ROLE_INVENTORY.md`](ROLE_INVENTORY.md) for the full list. If what
you need isn't there:

### Option A: Add it to `roles/`

Best for anything that's reusable across hosts or environments:

1. Create `roles/<rolename>/` with the standard layout:
   ```
   roles/<rolename>/
   ├── defaults/main.yml
   ├── handlers/main.yml
   ├── meta/main.yml
   ├── tasks/
   │   ├── main.yml          # 4-state dispatcher
   │   ├── is_present.yml
   │   └── is_absent.yml
   ├── templates/
   ├── files/
   ├── vars/main.yml
   └── README.md
   ```
2. Use `roles/install_apache/` or any other existing role as a copy-paste
   reference for the dispatcher pattern.
3. Reference it in playbooks as `role: <rolename>`.

### Option B: Pull a third-party role from Galaxy

If you need a role from Ansible Galaxy or a third-party Git repo, add it
to `requirements.yml` under a new `roles:` section:

```yaml
collections:
  - name: ansible.posix
  # ...

roles:
  - name: third_party_role
    src: https://github.com/some/repo.git
    version: v1.0.0
```

Run `make install`. The role lands in `collections/ansible_roles/`,
which is in `roles_path` already, so `role: third_party_role` just works.

---

## Add a new collection

Edit `requirements.yml`:

```yaml
collections:
  ...
  - name: dellemc.openmanage
    version: ">=8.0.0"
```

Then `make install`.

---

## Adding CI

The `.github/workflows/` directory is empty by default. Drop a workflow
file in there to lint on PRs. Example:

```yaml
# .github/workflows/lint.yml
name: lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install ansible-core ansible-lint yamllint
      - run: ansible-galaxy collection install -r requirements.yml
      - run: ./scripts/lint.sh
      - run: make syntax INVENTORY=inventory.example/hosts
```
