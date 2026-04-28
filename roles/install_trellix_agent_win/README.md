# install_trellix_agent_win

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

- `artifact_staging`
- `domain_password`
- `domainadmin_user`
- `system_name`
- `trellix_path_win`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: windows
  roles:
    - role: install_trellix_agent_win
      desired_state: present
```

## License

MIT
