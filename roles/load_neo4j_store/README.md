# load_neo4j_store

**Platform:** Linux
**Archetype:** `group`

## What this role does

Manages group(s).

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

- `backup_dir`
- `db_name`
- `db_name_dump`
- `db_name_version`
- `group`
- `neo4j_command`
- `neo4j_command_admin`
- `nexus_gold_repository`
- `nexus_host_qualified`
- `user`
- `version`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: all
  roles:
    - role: load_neo4j_store
      desired_state: present
```

## License

MIT
