# Secrets Reference

Where secrets live, how to set them, how to keep them safe.

## TL;DR

```bash
make edit-vault
```

That command opens `inventory/group_vars/all/vault.yml` for editing,
handling decrypt → edit → encrypt for you.

---

## What goes in the vault

Anything that's a credential or a token. The full list is in
[`VARIABLES.md#vault-variables-encrypted`](VARIABLES.md#vault-variables-encrypted).

Critical ones:

| Variable | Required? | Why |
|---|---|---|
| `vault_vsphere_account` | Always | vCenter API access for VM creation |
| `vault_vsphere_password` | Always | vCenter password |
| `vault_ad_bind_user` | Windows hosts | AD bind account |
| `vault_ad_bind_password` | Windows hosts | AD bind password |
| `vault_windows_local_admin_password` | Windows hosts | Set during VM customization |
| `vault_ipa_admin_password` | IPA-using sites | IPA admin |
| `vault_db_admin_password` | DB hosts | DB superuser |

## The naming convention

Every vault variable is prefixed with `vault_`. Reasons:

- **Greppable** — `grep -r vault_ playbooks/` shows every secret reference
- **Indirection** — non-vault vars point to them, e.g.:
  ```yaml
  # group_vars/all/main.yml (NOT encrypted, committed)
  vsphere_password: "{{ vault_vsphere_password }}"

  # group_vars/all/vault.yml (encrypted, gitignored)
  vault_vsphere_password: "actual-secret-here"
  ```
- **Safer rotation** — change one place; consumers don't move

---

## First-time vault setup

The setup script does this for you, but here's the manual sequence:

```bash
# 1. Copy the template
cd inventory/group_vars/all/
cp vault.yml.example vault.yml

# 2. Replace EVERY placeholder with a real value
$EDITOR vault.yml

# 3. Encrypt with ansible-vault
ansible-vault encrypt vault.yml
# You'll be prompted for a "vault password" — pick a strong one and remember it

# 4. (Optional) save the password locally so you don't have to type it
echo 'your-vault-password' > ../../../.vault_pass
chmod 600 ../../../.vault_pass
# .vault_pass is in .gitignore — never commits
```

---

## Daily use

### Edit the vault

```bash
make edit-vault
```

### Run a playbook with the vault

If `.vault_pass` exists, the Makefile uses it automatically:

```bash
make linux-web HOST=web01.your.domain
```

If not, you'll be prompted:

```bash
ansible-playbook -i inventory/hosts \
  playbooks/linux/build_linux_vm.yml \
  --limit web01.your.domain \
  --ask-vault-pass
```

### Encrypt one-off files

If you have an additional file with secrets (e.g., a per-host vault):

```bash
make encrypt FILE=inventory/host_vars/db01.your.domain.yml
```

You can decrypt it later, or use `ansible-vault edit`.

### Encrypt a single string (instead of a whole file)

Useful for embedding one secret in a normal YAML file:

```bash
ansible-vault encrypt_string 'mysecretvalue' --name 'my_secret_var'
```

Output is a YAML block you can paste anywhere:

```yaml
my_secret_var: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  3437...
```

---

## Operational hygiene

### NEVER commit:

- `inventory/` (entire tree, including the encrypted vault.yml)
- `.vault_pass`
- Anything ending in `.local`

`.gitignore` blocks all of these — verify it's in place after `git init`.

### Backup the vault password somewhere safe

If you lose it, the encrypted vault is unrecoverable. Use a password
manager. Don't email it to yourself.

### Rotate periodically

```bash
ansible-vault rekey inventory/group_vars/all/vault.yml
# prompts for old password, then new password
```

### Different password for production vs dev

Use separate password files and select with `--vault-id`:

```bash
ansible-playbook --vault-id dev@.vault_pass.dev \
                 --vault-id prod@.vault_pass.prod \
                 ...
```

Each vault file should be encrypted with its environment's password.

---

## What happens if I commit a real vault.yml?

Don't, but if you do:

1. Immediately rotate every secret in it (assume compromised)
2. Use `git filter-repo` or BFG to scrub it from history
3. Force-push the cleaned history

This is why `inventory/` is gitignored. Don't fight `.gitignore`.

---

## Why not pass-through env vars / external secret store?

Both are great. They're not in this repo's default flow because:

- Most users want the simplest path that works
- `ansible-vault` works offline, on-airgap, and needs no infra
- Migrating to HashiCorp Vault, AWS Secrets Manager, etc. is a swap of
  the lookup; the rest of the repo doesn't care

If you migrate, change the indirection in `group_vars/all/main.yml`:

```yaml
# Before
vsphere_password: "{{ vault_vsphere_password }}"

# After (HashiCorp Vault example)
vsphere_password: "{{ lookup('community.hashi_vault.vault_kv2_get', 'secret/vsphere')['data']['password'] }}"
```
