# set_gc_feature_toggles

**Platform:** Linux
**Archetype:** `edit_in_place`

## What this role does

Edits one or more existing config files in place.

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
    - role: set_gc_feature_toggles
      desired_state: present
```

## License

MIT
