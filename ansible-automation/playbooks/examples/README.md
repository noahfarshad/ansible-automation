# Example playbooks

This directory holds **reference** playbooks that show how to compose
the building blocks. Don't run them blindly — copy and adapt to your
needs.

## Conventions

- Each example has a header explaining what it does and what it requires
- Examples reference roles by their `<name>` path
- Examples include `pre_tasks` assertions for the variables they need
- Examples are tagged so subsets can be run

## Files in this directory

(Currently empty — populate as you build out reference patterns.)

Suggested examples worth writing as you go:

- `patch_all_linux.yml` — yum-update + reboot loop with serial throttling
- `rotate_certs.yml` — pull new certs from internal CA, reload services
- `windows_patching.yml` — wuauserv + post-patch reboot orchestration
- `verify_compliance.yml` — read-only audit using check mode
