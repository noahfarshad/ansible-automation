# create_dc

**Platform:** Windows
**Archetype:** `config_only`

## What this role does

Pushes configuration files into place.

See `tasks/is_present.yml` for the actual implementation and
`tasks/is_absent.yml` for the removal logic.

## Lifecycle (desired_state)

| Value     | Behavior                                                        |
|-----------|-----------------------------------------------------------------|
| `present` | Run is_present.yml (default)                                   |
| `absent`  | Run is_absent.yml                                               |
| `started` | Reserved — uncomment in tasks/main.yml when needed              |
| `stopped` | Reserved — uncomment in tasks/main.yml when needed              |

## Variables

Variables this role uses (see `defaults/main.yml`):

- `disk_datastore`
- `disk_gb`
- `disk_type`
- `memory_allocated_mb`
- `number_of_cores_per_socket`
- `number_of_cpus`
- `short_hostname`
- `template_name`
- `vcenter_hostname`
- `vsphere_account`
- `vsphere_cluster`
- `vsphere_datacenter`
- `vsphere_datastore`
- `vsphere_folder`
- `vsphere_password`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: windows
  roles:
    - role: create_dc
      desired_state: present
```

## License

MIT
