# collections/

This directory holds **Galaxy-installed collections** after you run
`make install` (or `./scripts/setup.sh`).

After install, you'll see:

    collections/
    └── ansible_collections/
        ├── ansible/posix/
        ├── ansible/windows/
        ├── community/general/
        ├── community/vmware/
        ├── community/windows/
        └── microsoft/ad/

The contents of `ansible_collections/` are gitignored — only the list in
`requirements.yml` is committed.

> **Note:** The 350-role library lives at `roles/`, NOT here. It's bundled
> directly into this repo so a single `git clone` gives you everything
> needed to build VMs.
