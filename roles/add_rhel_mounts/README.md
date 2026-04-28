# add_rhel_mounts

**Platform:** Linux
**Archetype:** `mount`

## What this role does

Manages filesystem mounts (NFS, CIFS, etc.).

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

No user-facing input variables. See `defaults/main.yml`.

## Example

```yaml
- hosts: all
  roles:
    - role: add_rhel_mounts
      desired_state: present
```

## License

MIT
