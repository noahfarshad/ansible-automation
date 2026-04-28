# Linux VMs

Walks through what `make linux*` actually does.

## Available targets

| Make target | What it runs |
|---|---|
| `make linux HOST=...` | Just `build_linux_vm.yml` (VM + baseline) |
| `make linux-web HOST=...` | `build_linux_vm.yml` + `configure_webserver.yml` |
| `make linux-db HOST=...` | `build_linux_vm.yml` + `configure_dbserver.yml` |
| `make linux-app HOST=...` | `build_linux_vm.yml` + `configure_appserver.yml` |

You can also run any playbook directly:

```bash
ansible-playbook -i inventory/hosts \
  playbooks/linux/build_linux_vm.yml \
  --limit web01.your.domain
```

---

## What `build_linux_vm.yml` does

### Step 1: Clean stale SSH known_hosts (localhost)

If you've rebuilt a host before, your local `~/.ssh/known_hosts` may
have an outdated fingerprint. The `remove_known_hosts` role clears it
so SSH to the new VM doesn't fail.

### Step 2: Provision the VM in vSphere (localhost)

Uses `community.vmware.vmware_guest`. Required values:

- `vsphere_template` — a Linux template that already exists in vCenter
- `vsphere_folder`, `vsphere_datastore`, `vsphere_network`
- `vsphere_cpu`, `vsphere_memory_mb`, `vsphere_disk_gb`
- `static_ipv4_address`, `static_ipv4_netmask`, `static_ipv4_gateway`

Pre-flight asserts these are all set; the playbook fails fast if not.

After clone, the playbook waits up to 10 minutes for SSH (port 22) to
come up on the new VM's IP. If it doesn't, the playbook fails.

### Step 3: Apply Linux baseline (target host)

Runs in order — each role is tagged so you can re-run a subset:

| Role | Tag | What it does |
|---|---|---|
| `configure_yum` | `packages, yum` | Configures package repos |
| `install_package` | `packages` | Installs `linux_baseline_packages` |
| `configure_volumes` | `storage, lvm` | Creates LVM VGs/LVs from `linux_volume_groups`/`linux_logical_volumes` |
| `configure_firewall` | `firewall, security` | Opens ports listed in `firewall_open_tcp_ports` (skipped if `enable_firewall: false`) |
| `configure_selinux` | `selinux, security` | Sets SELinux state per `selinux_state` |
| `certificates` | `tls, certificates` | Distributes the internal CA bundle |
| `sssd_config` | `identity, sssd` | Configures SSSD |
| `ipaclient` | `identity, ipa` | Joins the host to IPA (skipped if `enable_ipa_client: false`) |
| `push_sudoersd` | `sudo, security` | Drops sudoers files into `/etc/sudoers.d/` |
| `configure_splunk_forwarder_rhel` | `logging, splunk` | Installs and configures the UF |

---

## What `configure_webserver.yml` does

Runs **after** `build_linux_vm.yml`. Targets the `[webservers]` group only.

| Step | What |
|---|---|
| `install_apache` role | Installs httpd, sets up base config |
| `configure_apache_users` role | Creates apache user / group |
| `change_apache_permissions` role | Sets ownership on document root |
| `apache_verify_config` role | Runs `httpd -t` to validate |
| Open firewall ports | 80, 443 (or your overrides) |
| Service start/enable | Ensures `httpd` is up at boot |
| Sanity check | `wait_for: port=443` from controller |

### Variables for webserver tier

See [`VARIABLES.md`](VARIABLES.md#group_varswebserversmainyml) for the full list.

Most-likely overrides:
- `apache_listen_port_ssl` — if you're behind a load balancer
- `apache_modules_enabled` — add `wsgi`, `php`, etc.
- `firewall_open_tcp_ports` — if you need additional ports

---

## What `configure_dbserver.yml` does

Runs **after** `build_linux_vm.yml`. Targets the `[dbservers]` group only.

| Step | What |
|---|---|
| `install_db` role | Installs DB engine packages |
| `db_parameters` role | Applies tuning (`shared_buffers`, `work_mem`, etc.) |
| `db_enable_archive_log_mode` role | Sets up archive log mode (primary only) |
| Open firewall | DB port |
| Service start/enable | DB service up at boot |
| Cron backup (primary only) | Nightly backup at `db_backup_cron_hour` |

### Primary vs replica

Set `db_role: primary` (default) or `db_role: replica` in `host_vars/`.
Replicas skip the archive-log and backup-cron steps.

---

## What `configure_appserver.yml` does

| Step | What |
|---|---|
| `install_java8` role | Installs JDK (only when `java_version <= 8`) |
| `install_fmw_infrastructure` role | WebLogic FMW setup (when `app_engine: weblogic`) |
| `binary_installer` role | Generic installer driver |
| `configure_log_rotation` role | Sets up logrotate for app logs |
| `push_systemd` role | Drops a systemd unit file |
| Open firewall | App ports (8080, 8443, 7001) |

---

## Re-running

All roles in this repo are designed to be idempotent. Re-running
a playbook should not make changes if nothing has drifted. If it does,
that's a bug — file it as an issue.

To re-run only one part (e.g., just firewall):

```bash
ansible-playbook -i inventory/hosts \
  playbooks/linux/build_linux_vm.yml \
  --limit web01.your.domain \
  --tags firewall
```

---

## Customizing

If you need a tier that isn't web/db/app, see [`EXTENDING.md`](EXTENDING.md)
for the pattern. The short version:

1. Create `playbooks/linux/configure_<tier>.yml` based on one of the existing files
2. Create `inventory.example/group_vars/<tier>/main.yml`
3. Add a `[<tier>]` group to `inventory.example/hosts`
4. Add `<tier>` to `[linux:children]`
5. Optional: add a Make target
