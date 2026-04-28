# Variables Reference

Every variable you can set, where to set it, what it does.

This page is the source of truth. The `inventory.example/` files are
working defaults; this document explains *why* they are what they are
and what to change.

## Conventions

- **REQUIRED** — playbooks fail if not set
- **REQUIRED if X** — required only when condition X is true
- **Default: ...** — the value used if you don't override

---

## `group_vars/all/main.yml` — environment-wide

### Identity

| Variable | Required? | What it is |
|---|---|---|
| `org_name` | **REQUIRED** | Short organization name (snake_case). Used as a prefix in indexes and AD NetBIOS. |
| `org_domain` | **REQUIRED** | DNS domain. Drives a lot — AD domain, default certificate names, etc. |
| `org_email` | **REQUIRED** | Used by Apache `ServerAdmin`, Splunk metadata, etc. |

### DNS

| Variable | Required? | What it is |
|---|---|---|
| `dns_servers` | **REQUIRED** | List of nameserver IPs. Pushed into VM customization specs and `/etc/resolv.conf`. |
| `dns_search_domains` | optional | Default search domains. Defaults to `[ org_domain ]`. |

### NTP

| Variable | Required? | What it is |
|---|---|---|
| `ntp_servers` | optional | List of NTP server hostnames. Defaults to public pool. |
| `ntp_timezone` | optional | IANA timezone for Linux hosts. Default: `America/Denver`. |

### Repository / artifact server

| Variable | Required? | What it is |
|---|---|---|
| `repo_server_host` | **REQUIRED if** `enable_yum_repo` | DNS name of your internal YUM/package server. |
| `repo_server_url` | optional | Computed from `repo_server_host`. |
| `yum_repo_baseurl` | optional | Computed from `repo_server_url`. |

### vSphere — VM creation

| Variable | Required? | What it is |
|---|---|---|
| `vsphere_host` | **REQUIRED** | vCenter hostname or IP. |
| `vsphere_datacenter` | **REQUIRED** | vCenter datacenter name. |
| `vsphere_cluster` | **REQUIRED** | vCenter cluster name. |
| `vsphere_folder` | optional | Default folder; can be overridden per-host. |
| `vsphere_validate_certs` | optional | Default `false`. Set `true` if vCenter has a real cert. |
| `vsphere_account` | **REQUIRED** | Reads from `vault_vsphere_account`. |
| `vsphere_password` | **REQUIRED** | Reads from `vault_vsphere_password`. |

### Active Directory

| Variable | Required? | What it is |
|---|---|---|
| `ad_domain` | **REQUIRED if Windows hosts** | AD DNS domain. Often equals `org_domain`. |
| `ad_domain_netbios` | **REQUIRED if Windows hosts** | NetBIOS short name. Default: `org_name | upper`. |
| `ad_dc_hostname` | **REQUIRED if Windows hosts** | Hostname of a writable DC. |
| `ad_default_ou` | **REQUIRED if Windows hosts** | LDAP path for new server objects. |
| `ad_join_user` | **REQUIRED if Windows hosts** | UPN of the bind account. From vault. |
| `ad_join_password` | **REQUIRED if Windows hosts** | From vault. |

### IPA (FreeIPA / Identity Management)

| Variable | Required? | What it is |
|---|---|---|
| `enable_ipa_client` | optional | Default `true`. Set `false` to skip the `ipaclient` role. |
| `ipa_admin_user` | **REQUIRED if** `enable_ipa_client` | IPA admin username. Default: `admin`. |
| `ipa_admin_password` | **REQUIRED if** `enable_ipa_client` | From vault. |
| `ipa_servers` | **REQUIRED if** `enable_ipa_client` | List of IPA server hostnames. |

### Splunk forwarder

| Variable | Required? | What it is |
|---|---|---|
| `enable_splunk_forwarder` | optional | Default `true`. |
| `splunk_forwarder_host` | **REQUIRED if** enabled | Forwarder destination hostname. |
| `splunk_forwarder_port` | optional | Default `9997`. |
| `splunk_index` | optional | Default `<org_name>_default`. |

### Feature toggles

| Variable | Default | Behavior |
|---|---|---|
| `enable_selinux` | `true` | Run `configure_selinux` role |
| `enable_firewall` | `true` | Open ports listed in `firewall_open_tcp_ports` |
| `enable_ipa_client` | `true` | Join Linux hosts to IPA |
| `enable_splunk_forwarder` | `true` | Install + configure Splunk UF |
| `enable_nagios` | `false` | Install Nagios agent |
| `enable_centrify` | `false` | Use Centrify (alternative to IPA/SSSD) |

---

## `group_vars/linux/main.yml` — Linux defaults

| Variable | Required? | What it is |
|---|---|---|
| `ansible_python_interpreter` | optional | Default `/usr/bin/python3`. |
| `linux_volume_groups` | optional | List of LVM VGs to create. |
| `linux_logical_volumes` | optional | List of LVs and their mounts. See example. |
| `linux_baseline_packages` | optional | Packages installed on every Linux host. |
| `firewall_open_tcp_ports` | optional | Ports open to the world. SSH-only by default. |
| `selinux_state` | optional | `enforcing` / `permissive` / `disabled`. |
| `selinux_policy` | optional | `targeted` (default) or `mls`. |

---

## `group_vars/windows/main.yml` — Windows defaults

| Variable | Required? | What it is |
|---|---|---|
| `ansible_winrm_transport` | optional | `ntlm` (default) or `kerberos`. |
| `windows_timezone` | **REQUIRED** | E.g., `Mountain Standard Time`. |
| `windows_install_packages` | optional | List of friendly names — see install_software.yml. |
| `windows_features` | optional | List of Windows server feature names. |
| `windows_local_admin_user` | **REQUIRED** | Default `Administrator`. |
| `windows_local_admin_password` | **REQUIRED** | From vault. Used by VM customization spec. |

---

## `group_vars/webservers/main.yml`

| Variable | Required? | What it is |
|---|---|---|
| `apache_listen_port` | optional | Default `80`. |
| `apache_listen_port_ssl` | optional | Default `443`. |
| `apache_serveradmin` | optional | Default: `org_email`. |
| `apache_document_root` | optional | Default `/var/www/html`. |
| `apache_modules_enabled` | optional | List of mods to load. |
| `apache_ssl_cert_path` | **REQUIRED** | Path to TLS cert. Distributed by `certificates` role. |
| `apache_ssl_key_path` | **REQUIRED** | Path to TLS private key. |
| `apache_ssl_chain_path` | optional | CA chain bundle. |
| `firewall_open_tcp_ports` | optional | Override Linux default to add 80/443. |
| `content_root` | optional | Default `/var/www/html`. |
| `content_owner` / `content_group` | optional | Default `apache`. |
| `splunk_forwarder_inputs` | optional | Per-tier log paths. |

---

## `group_vars/dbservers/main.yml`

| Variable | Required? | What it is |
|---|---|---|
| `db_engine` | **REQUIRED** | `postgres` / `mysql` / `oracle`. |
| `db_version` | **REQUIRED** | Major version (`"15"`). |
| `db_listen_address` | optional | Default `0.0.0.0`. Set to `localhost` for primary-only. |
| `db_listen_port` | optional | Default `5432`. |
| `db_max_connections` | optional | Default `200`. |
| `db_admin_user` | **REQUIRED** | DB superuser. |
| `db_admin_password` | **REQUIRED** | From vault. |
| `db_app_user` | optional | Application connection user. |
| `db_app_password` | optional | From vault. |
| `db_shared_buffers` | optional | Tuning — sized to RAM. |
| `db_effective_cache_size` | optional | Tuning. |
| `db_work_mem` | optional | Tuning. |
| `db_maintenance_work_mem` | optional | Tuning. |
| `db_backup_dir` | optional | Default `/var/backup/db`. |
| `db_backup_retention_days` | optional | Default `14`. |
| `db_backup_cron_hour` / `_minute` | optional | When to run backups. |
| `db_role` | optional | `primary` (default) or `replica`. |

---

## `group_vars/appservers/main.yml`

| Variable | Required? | What it is |
|---|---|---|
| `app_user` / `app_group` | **REQUIRED** | Service account. Default `appuser` / `appgroup`. |
| `app_uid` / `app_gid` | optional | Numeric IDs. Default `2000`. |
| `app_install_dir` | **REQUIRED** | Where the app lives. Default `/opt/myapp`. |
| `app_data_dir`, `app_log_dir`, `app_config_dir` | optional | Computed defaults. |
| `java_install_directory` | optional | Default `/opt/java`. |
| `java_version` | optional | Default `17`. |
| `app_http_port` / `_https_port` / `_admin_port` | optional | Defaults `8080` / `8443` / `7001`. |
| `heap_size` | optional | JVM heap. Default `4g`. Override per-host based on RAM. |

---

## `host_vars/<hostname>.yml` — per-host

These are typical overrides:

| Variable | Required? | What it is |
|---|---|---|
| `vsphere_template` | **REQUIRED for build_*_vm.yml** | Name of the template in vCenter. |
| `vsphere_folder` | **REQUIRED** | Folder path. |
| `vsphere_datastore` | **REQUIRED** | Datastore name. |
| `vsphere_network` | **REQUIRED** | Portgroup name. |
| `vsphere_cpu` | **REQUIRED** | vCPU count. |
| `vsphere_memory_mb` | **REQUIRED** | Memory in MB. |
| `vsphere_disk_gb` | **REQUIRED** | OS disk size. |
| `static_ipv4_address` | **REQUIRED** | Host IP. |
| `static_ipv4_netmask` | **REQUIRED** | Netmask. |
| `static_ipv4_gateway` | **REQUIRED** | Gateway. |
| `ad_target_ou` | optional (Windows) | Override `ad_default_ou` for this host. |
| `windows_extra_packages` | optional (Windows) | Per-host extras on top of the group default. |
| Anything else | Anything | Override any group var here for this host only. |

---

## Vault variables (encrypted)

All in `inventory/group_vars/all/vault.yml` (encrypted with ansible-vault).

| Variable | Required? | What |
|---|---|---|
| `vault_vsphere_account` | **REQUIRED** | vCenter service account UPN. |
| `vault_vsphere_password` | **REQUIRED** | vCenter service account password. |
| `vault_ad_bind_user` | **REQUIRED if Windows** | AD bind account UPN. |
| `vault_ad_bind_password` | **REQUIRED if Windows** | AD bind password. |
| `vault_domain_password` | optional | DA password for AD ops requiring DA rights. |
| `vault_ipa_admin_password` | **REQUIRED if** IPA enabled | IPA admin password. |
| `vault_windows_local_admin_password` | **REQUIRED if Windows** | Local admin set on new VMs. |
| `vault_db_admin_password` | **REQUIRED if** building DB | DB superuser password. |
| `vault_db_app_password` | optional | DB app user password. |
| `vault_repo_username` / `_password` | optional | Repo server creds if private. |
| `vault_splunk_hec_token` | optional | Splunk HEC token if used. |

See [`SECRETS.md`](SECRETS.md) for vault setup.
