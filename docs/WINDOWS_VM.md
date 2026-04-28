# Windows VMs

Walks through what `make windows*` actually does.

## Available targets

| Make target | What it runs |
|---|---|
| `make windows HOST=...` | `build_windows_vm.yml` + `configure_baseline.yml` + `install_software.yml` |
| `make windows-baseline HOST=...` | Just `configure_baseline.yml` (assumes VM exists and is domain-joined) |
| `make windows-software HOST=...` | Just `install_software.yml` (no VM creation, no baseline) |

---

## What `build_windows_vm.yml` does

This is a 3-play pipeline.

### Play 1: Provision the VM in vSphere (localhost)

Same pattern as the Linux build, but the customization spec also:

- Sets the local Administrator password from `windows_local_admin_password`
  (which reads from `vault_windows_local_admin_password`)
- Configures `runonce` PowerShell to enable WinRM as the host comes up
- Sets the timezone

After clone, waits up to 20 minutes for WinRM (port 5986) to be reachable.

### Play 2: Configure WinRM on the new host

Connects with the **local** Administrator account (not yet domain-joined),
runs:

| Role | What |
|---|---|
| `configure_winrm` | Hardens WinRM (HTTPS, certs, allowed users) |
| `upgrade_vmware_tools` | Updates VMware Tools to current |

### Play 3: Join the host to AD

Still using the local Administrator account, runs:

| Role | What |
|---|---|
| `join_windows_active_directory` | Adds the computer object to AD in `ad_target_ou` (or `ad_default_ou` fallback) |

After the role completes, the playbook reboots the host (`win_reboot`)
to finalize the join, then waits for WinRM to come back.

After this point, the host can be reached using the AD bind account
(`{{ ad_join_user }}` from `group_vars/windows/main.yml`).

---

## What `configure_baseline.yml` does

Runs **after** `build_windows_vm.yml`. Connects with the AD bind account.

| Role | Tag | What |
|---|---|---|
| `configure_windows` | `baseline` | Common Windows config (page file, services, etc.) |
| `install_win_features` | `features` | Installs features from `windows_features` list |
| `configure_splunk_forwarder_windows` | `logging, splunk` | Installs UF, configures event log inputs |

### Variables

In `group_vars/windows/main.yml`:

```yaml
windows_features:
  - .NET-Framework-Features
  - GPMC
  - RSAT-AD-Tools     # if this server needs to manage AD
```

`splunk_forwarder_inputs` defines which Windows event logs ship to
which Splunk index. The default ships System / Security / Application
to per-channel indexes.

---

## What `install_software.yml` does

Two paths run side-by-side:

### Path 1: dedicated install_<pkg> roles

For software that has a dedicated role in `roles/`, the playbook
includes the role conditionally. Currently:

- `winscp` — uses `install_winscp` role
- `trellix` — uses `install_trellix_agent_win` role (also enabled by `install_trellix: true`)

### Path 2: Chocolatey for everything else

Anything in `windows_install_packages` (or `windows_extra_packages` in
host_vars) that isn't already handled by a dedicated role gets installed
via Chocolatey.

The mapping from "friendly name" → "chocolatey package name" is in
`install_software.yml`'s `windows_chocolatey_packages` dict. Defaults
cover common packages:

| Friendly | Chocolatey |
|---|---|
| `7zip` | `7zip` |
| `notepad_plus_plus` | `notepadplusplus` |
| `firefox` | `firefox` |
| `chrome` | `googlechrome` |
| `vscode` | `vscode` |
| `putty` | `putty` |
| `winscp` | `winscp` |
| `git` | `git` |
| `wireshark` | `wireshark` |
| `sql_server_management_studio` | `sql-server-management-studio` |
| `powerbi_desktop` | `powerbi` |
| `adobereader` | `adobereader` |

### Adding a package

If it's already on Chocolatey, just add it to `windows_install_packages`.
If the choco package name differs from your friendly name, extend
`windows_chocolatey_packages` in `install_software.yml`:

```yaml
windows_chocolatey_packages:
  ...existing...
  my_internal_tool: my-internal-tool-choco-pkg
```

For software that needs a dedicated role (custom MSI, license file,
post-install config), add it in `roles/` first as a role
named `install_<pkg>`, then add a conditional include in `install_software.yml`.

---

## Templates

`build_windows_vm.yml` clones a template that already exists in vCenter.
Templates need:

- VMware Tools installed (recent enough to support guest customization)
- Sysprep'd Windows install
- WinRM configured to start automatically (the runonce script does this
  on first boot, so it's fine if WinRM is off in the template itself)
- `Administrator` enabled with a known password (which you'll override
  during customization)

---

## Connection model

Three different identities are used in sequence:

| When | Identity | Why |
|---|---|---|
| Step 1 (vSphere create) | `vsphere_account` (vCenter API) | To clone from template |
| Step 2 (WinRM config, VMware Tools) | `windows_local_admin_user` | Host isn't domain-joined yet |
| Step 3 (AD join) | `windows_local_admin_user` | Local admin needed to perform the join itself |
| All later plays | `ad_join_user` (AD account) | Standard ops |

The vault holds three passwords:

- `vault_vsphere_password` — vCenter
- `vault_windows_local_admin_password` — local admin set during customization
- `vault_ad_bind_password` — AD bind account
