# Quick Start

This walks you from "I just cloned the repo" to "I just built a Linux web server"
in about 15 minutes (most of which is the VM creation itself, not your time).

## Prerequisites

You need:

- **A workstation** with Python 3.10+, `git`, `ssh`
- **Ansible 2.16+** — install with `pip3 install --user ansible-core`
- **vSphere/vCenter access** with permission to create VMs and read templates
- **A Linux template in vCenter** (e.g. `rhel9-template`) — see "Templates" below
- **A vault password** (you'll choose one in step 3)

The setup script (`./scripts/setup.sh`) checks all of these and tells you
what's missing.

---

## Step 1 — Clone and enter the repo

```bash
git clone https://github.com/noahfarshad/ansible-automation.git
cd ansible-automation
```

---

## Step 2 — Run the setup script

This installs the role library, copies `inventory.example/` to `inventory/`,
and walks you through choosing a vault password.

```bash
./scripts/setup.sh
```

Output should end with `Setup complete.` If a tool is missing, install it
and re-run — the script is idempotent.

After setup, your tree looks like this:

```
ansible-automation/
├── inventory/                    <- copied from inventory.example/
├── collections/                  <- Galaxy collections installed here
├── .vault_pass                   <- (if you chose to create one — gitignored)
└── ...
```

---

## Step 3 — Edit your inventory

Open the inventory file:

```bash
$EDITOR inventory/hosts
```

Replace the example hosts with yours. Keep the same group structure
(`[webservers]`, `[dbservers]`, `[appservers]`, `[windows]`, plus the
`:children` rollups). Example:

```ini
[webservers]
web01.your.domain
web02.your.domain

[windows]
win01.your.domain
```

---

## Step 4 — Set environment-wide variables

Open `group_vars/all/main.yml` and fix at minimum:

```yaml
org_name:        your_org
org_domain:      your.domain
org_email:       admin@your.domain

dns_servers:
  - <YOUR DNS SERVER IP>

vsphere_host:           vcenter.your.domain
vsphere_datacenter:     your_dc
vsphere_cluster:        your_cluster

ad_domain:              your.domain
ad_dc_hostname:         dc01.your.domain
ad_default_ou:          "OU=Servers,DC=your,DC=domain"
```

See **[`docs/VARIABLES.md`](VARIABLES.md)** for what every variable does.

---

## Step 5 — Set your secrets

```bash
make edit-vault
# (this opens inventory/group_vars/all/vault.yml in $EDITOR via ansible-vault)
```

At minimum, set:

```yaml
vault_vsphere_account:                "ansible@vsphere.local"
vault_vsphere_password:               "<your vCenter password>"
vault_ad_bind_user:                   "ad-bind@your.domain"
vault_ad_bind_password:               "<your AD bind password>"
vault_windows_local_admin_password:   "<a complex password>"
```

When you save and exit, ansible-vault encrypts the file. From now on,
any time you need to edit it, run `make edit-vault` again — it handles
decrypt → edit → encrypt for you.

---

## Step 6 — Set up the host you want to build

```bash
make new-host NAME=web01.your.domain OS=linux
$EDITOR inventory/host_vars/web01.your.domain.yml
```

Set at minimum:

```yaml
vsphere_template:        "rhel9-template"
vsphere_folder:          "/your_dc/vm/Linux"
vsphere_datastore:       "datastore1"
vsphere_network:         "VM Network"
vsphere_cpu:             4
vsphere_memory_mb:       8192
vsphere_disk_gb:         80

static_ipv4_address:     10.10.10.11
static_ipv4_netmask:     255.255.255.0
static_ipv4_gateway:     10.10.10.1
```

---

## Step 7 — Build it

```bash
make linux-web HOST=web01.your.domain
```

This runs two playbooks in sequence:

1. `playbooks/linux/build_linux_vm.yml` — creates the VM, applies baseline
2. `playbooks/linux/configure_webserver.yml` — installs Apache, opens firewall

If you want to dry-run first to see what would change:

```bash
ansible-playbook --check --diff -i inventory/hosts \
  playbooks/linux/build_linux_vm.yml \
  --limit web01.your.domain
```

---

## Templates

`build_linux_vm.yml` and `build_windows_vm.yml` clone an existing vSphere
template. They do **not** create the template. You need to:

1. Build a base VM (RHEL 9 or Windows Server 2022, etc.) once by hand
2. Sysprep / reset it
3. Convert it to a template in vCenter
4. Reference its name as `vsphere_template:` in your `host_vars/`

Templates need:

- A working SSH server (Linux) or WinRM (Windows)
- The `cloud-init` / `open-vm-tools` package installed
- A user `ansible` (or whatever `ansible_user` is) with sudo / admin rights
- For Windows: VMware Tools, recent enough to support guest customization

---

## Common variations

### Build a Windows host

```bash
make new-host NAME=win01.your.domain OS=windows
$EDITOR inventory/host_vars/win01.your.domain.yml
make windows HOST=win01.your.domain
```

### Build the entire site at once

```bash
make site
```

### Just install software on an existing Windows host

```bash
make windows-software HOST=win01.your.domain
```

### Run in dry-run mode

```bash
make check
```

---

## Where to go next

- [`INVENTORY.md`](INVENTORY.md) — full inventory reference
- [`VARIABLES.md`](VARIABLES.md) — what every variable does
- [`LINUX_VM.md`](LINUX_VM.md) — what `make linux-*` actually runs
- [`WINDOWS_VM.md`](WINDOWS_VM.md) — what `make windows*` actually runs
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — when something breaks
