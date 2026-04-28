# gold_data_import_stage_dmp

**Platform:** Linux
**Archetype:** `mixed`

## What this role does

Performs multiple operations — see is_present.yml for details.

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
    - role: gold_data_import_stage_dmp
      desired_state: present
```

## License

MIT
