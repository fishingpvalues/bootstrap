# scripts/ — Automation and Healing

This directory contains all automation, install, and healing scripts for your dotfiles setup.

| Script                        | OS         | Purpose                        |
|-------------------------------|------------|--------------------------------|
| windows/install.ps1           | Windows    | Install all tools and fonts    |
| windows/healer.ps1            | Windows    | Heal/fix common issues         |
| unix/install.sh               | macOS/Linux| Install all tools and fonts    |
| unix/healer.sh                | macOS/Linux| Heal/fix common issues         |

- Shared functions can be placed in `functions.ps1` or `functions.sh` in the appropriate subfolder if needed.
- See the main README for entry points and workflow.

## Note on Submodules

The `bootstrap` folder is now a git submodule. If you do not see the scripts here, run:

```sh
git submodule update --init --recursive
```
