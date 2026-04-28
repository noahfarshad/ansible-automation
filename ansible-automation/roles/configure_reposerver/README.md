# configure_reposerver

**Platform:** Linux
**Archetype:** `service_only`

## What this role does

Manages a service (start/stop/enable/disable).

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

- `appstream_repo`
- `baseline__local_repos`
- `baseline_local_repos`
- `baseos_repo`
- `delta_repos`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: all
  roles:
    - role: configure_reposerver
      desired_state: present
```

## License

MIT
