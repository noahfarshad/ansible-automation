# configure_splunk_server

**Platform:** Linux
**Archetype:** `unarchive`

## What this role does

Extracts an archive into an install directory.

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

- `infra_ifc_version`
- `nexus_vars`
- `splunk_package_list`
- `splunk_port_list`
- `users`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: all
  roles:
    - role: configure_splunk_server
      desired_state: present
```

## License

MIT
