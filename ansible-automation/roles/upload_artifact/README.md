# upload_artifact

**Platform:** Linux
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

- `nexus_admin`
- `nexus_host`
- `nexus_password`
- `nexus_upload`
- `staging`
- `upload_artifacts`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: all
  roles:
    - role: upload_artifact
      desired_state: present
```

## License

MIT
