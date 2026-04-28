# deploy_plugin_updates

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

No user-facing input variables. See `defaults/main.yml`.

## Example

```yaml
- hosts: all
  roles:
    - role: deploy_plugin_updates
      desired_state: present
```

## License

MIT
