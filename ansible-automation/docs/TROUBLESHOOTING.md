# Troubleshooting

Common errors and their fixes.

---

## Setup

### `./scripts/setup.sh: Permission denied`

```bash
chmod +x scripts/*.sh
```

### `ansible: command not found`

Install Ansible:

```bash
pip3 install --user ansible-core
# Then add ~/.local/bin to PATH if needed:
export PATH="$HOME/.local/bin:$PATH"
```

### `ansible-galaxy: cannot install — connection refused`

Galaxy or your Git server isn't reachable. Check:

- `https://galaxy.ansible.com` is reachable from your workstation
- `https://galaxy.ansible.com` is reachable for collection downloads

If you're behind a corporate proxy, set `HTTPS_PROXY` and `HTTP_PROXY`
in your shell, then re-run `make install`.

### `python3 module 'pyVmomi' not installed`

```bash
pip3 install --user pyvmomi
```

### `python3 module 'winrm' not installed`

```bash
pip3 install --user pywinrm
```

---

## VM creation (vSphere)

### `Failed to find virtual machine before ...`

Usually one of:

- `vsphere_template` doesn't exist in the datacenter you specified.
  Run `govc vm.info -dc=<dc> <template>` (or check vCenter UI) to verify.
- `vsphere_folder` path is wrong. Folder paths are case-sensitive and
  must use the form `/<datacenter>/vm/<folder>`.
- The cluster doesn't have access to the datastore. Check the storage
  policy in vCenter.

### `Customization spec is missing required values`

`build_*_vm.yml` requires every `vsphere_*` and `static_ipv4_*` variable
to be set. Run with `--check` first to surface missing values:

```bash
ansible-playbook --check -i inventory/hosts \
  playbooks/linux/build_linux_vm.yml \
  --limit foo
```

The pre_tasks block lists exactly which vars are required.

### `Customization timed out waiting for IP`

The new VM is up, but vCenter never saw it get an IP. Causes:

- Static IP collides with another host
- Subnet/gateway mismatch
- DHCP isn't responding (if using DHCP)
- VMware Tools aren't installed in the template
- Customization spec ran but couldn't apply (check the VM's console)

Connect to the VM via vCenter console to debug.

### `unable to validate certificate`

vCenter has a self-signed cert and `vsphere_validate_certs: true`.
Set `vsphere_validate_certs: false` in `group_vars/all/main.yml`,
or install the vCenter root CA on your workstation.

---

## SSH (Linux)

### `UNREACHABLE — Permission denied (publickey,password)`

The user `ansible` (or whatever `ansible_user` is set to) doesn't exist
yet, or doesn't have an SSH key set up. Check:

- Is the user in your template? (Most templates have a default user;
  for new builds, you may need to use `--user root` and `--ask-pass`
  for the first run, with `sshpass` installed)
- Is your SSH key in `~/.ssh/authorized_keys` for that user?
- Is the host's IP reachable? (`ping`, `nc -zv host 22`)

For the very first run on a brand-new VM, you may need:

```bash
ansible-playbook -i inventory/hosts \
  playbooks/linux/build_linux_vm.yml \
  --limit foo \
  --user root --ask-pass
```

### `UNREACHABLE — Host key verification failed`

```bash
ssh-keygen -R foo.your.domain
```

Or run the playbook — `build_linux_vm.yml` includes the
`remove_known_hosts` role on localhost specifically to handle this.

### `Python interpreter not found`

```
Failed to import the required Python library (...) on host's Python /usr/bin/python.
```

Set `ansible_python_interpreter` per-host or in `group_vars/linux/main.yml`:

```yaml
ansible_python_interpreter: /usr/bin/python3
```

---

## WinRM (Windows)

### `Connection refused on port 5986`

WinRM HTTPS isn't up yet. The build playbook waits up to 20 minutes;
if it times out, connect to the VM via vCenter console and check:

- Did the runonce script execute? Look at `C:\Windows\Setup\Scripts\`
- Run from PowerShell as admin:
  ```powershell
  Enable-PSRemoting -Force
  ```

### `kerberos: Server not found in Kerberos database`

WinRM is using Kerberos but the host isn't in DNS or AD yet. Either:

- Switch transport to NTLM:
  ```yaml
  ansible_winrm_transport: ntlm
  ```
- Or ensure the host's A record exists in AD-integrated DNS

### `WinRMTransportError: 401 Unauthorized`

Wrong password or wrong domain qualifier on the user. Try:

```yaml
# group_vars/windows/main.yml
ansible_user: "DOMAIN\\username"      # NetBIOS form
# or
ansible_user: "username@example.com"  # UPN form
```

Different transports want different forms; NTLM tends to like
NetBIOS, Kerberos likes UPN.

### `certificate verify failed`

WinRM HTTPS uses a self-signed cert by default. The example inventory
has:

```yaml
ansible_winrm_server_cert_validation: ignore
```

Keep it that way unless you've installed real certs on every Windows host.

---

## Domain join

### `Computer object already exists`

A previous run created the AD object. Either:

- Delete it from AD Users & Computers and rerun
- Or pass `pre_existing: true` to allow the role to take over the existing object

### `Unable to find an authoritative server for domain ...`

The Linux/Windows host can't reach a DC. Check:

- DNS — does `nslookup _ldap._tcp.<domain>` from the host return DCs?
- Firewall — is UDP 389 / TCP 88 open between host and DC?
- Time — Kerberos requires clocks within ~5 minutes (configure NTP first!)

---

## Vault

### `ERROR! Attempting to decrypt but no vault secrets found`

Either:

- Pass `--ask-vault-pass` (or `--vault-password-file .vault_pass`)
- Or create `.vault_pass` and add this to `ansible.cfg`:
  ```ini
  vault_password_file = .vault_pass
  ```

### `ERROR! Decryption failed`

Wrong vault password. If you forgot it, the encrypted file is
unrecoverable — restore from backup or rotate the secrets.

---

## Performance

### Playbook is very slow on first run

Fact gathering dominates. Either:

- Set `gathering: smart` in `ansible.cfg` (already set)
- Use `--limit <single-host>` for testing
- Set `gather_facts: false` on plays that don't need facts

### `forks` setting

Default is 10 (set in `ansible.cfg`). Increase for large fleets:

```ini
[defaults]
forks = 50
```

But: more forks = more open SSH sessions = more memory on the controller.
50 is fine for ~200 hosts; 100+ if you're on a beefy controller.

---

## Idempotency

### "It says changed but nothing actually changed"

Some commands in the bundled roles are tagged with
`# TODO: review changed_when` because their idempotency depends on
context. Grep for these in the role you ran:

```bash
grep -rn 'TODO: review changed_when' \
  roles/<rolename>/
```

If you're confident the command is read-only or idempotent in your
environment, you can fix it locally and contribute the fix back.

---

## Still stuck?

1. Re-run with `-vvvv` for full debug:
   ```bash
   ansible-playbook -vvvv -i inventory/hosts \
     playbooks/... --limit ...
   ```
2. Check the role's own README:
   ```bash
   cat roles/<role>/README.md
   ```
3. File an issue — include the output of `ansible --version`, the
   playbook + limit you ran, and the relevant error.
