# create_desktop_pool

**Platform:** Windows
**Archetype:** `win_service`

## What this role does

Manages a Windows service.

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

- `bool`
- `connectionserver`
- `domain`
- `horizon_server_password`
- `horizon_server_username`
- `string_name`
- `system_name`
- `vcenter_hostname`
- `vcenter_password`
- `vsphere_account`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: windows
  roles:
    - role: create_desktop_pool
      desired_state: present
```

## License

MIT
