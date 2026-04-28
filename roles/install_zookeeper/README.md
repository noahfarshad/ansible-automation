# install_zookeeper

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

- `app_group`
- `app_user`
- `zookeeper_archive`
- `zookeeper_config_dir`
- `zookeeper_config_file`
- `zookeeper_data_dir`
- `zookeeper_dir`
- `zookeeper_java_home`
- `zookeeper_name`
- `zookeeper_port_number`
- `zookeeper_startup_cmd`
- `zookeeper_version`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: all
  roles:
    - role: install_zookeeper
      desired_state: present
```

## License

MIT
