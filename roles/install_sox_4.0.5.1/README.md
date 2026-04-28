# install_sox_4.0.5.1

**Platform:** Windows
**Archetype:** `win_package`

## What this role does

Installs a Windows package (MSI/MSU/exe).

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
- `sox_ffmpeg_path`
- `sox_main_path`
- `sox_postgre`
- `sox_video_filters_path`
- `system_name`

Commented-out entries in defaults/main.yml are inputs the caller is
expected to provide via group_vars, host_vars, or role params.

## Example

```yaml
- hosts: windows
  roles:
    - role: install_sox_4.0.5.1
      desired_state: present
```

## License

MIT
