# link_baseline_IFC_GPOs

**Platform:** Windows
**Archetype:** `shell_driven`

## What this role does

Drives shell/PowerShell commands to perform a task.

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

- `common_gpos`
- `domain_ou`
- `ifc`
- `length`
- `pre_ifc`
- `servers_gpos`
- `vdi_gpos`
- `workstations_gpos`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: windows
  roles:
    - role: link_baseline_IFC_GPOs
      desired_state: present
```

## License

MIT
