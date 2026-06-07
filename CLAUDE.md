# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A [chezmoi](https://www.chezmoi.io/)-managed dotfiles repository. Chezmoi applies files from this source directory to the home directory using its own naming conventions and templating system.

## Chezmoi naming conventions

| Prefix / suffix in repo | Meaning |
|---|---|
| `dot_` | Maps to `.` in `$HOME` (e.g. `dot_gitconfig.tmpl` → `~/.gitconfig`) |
| `private_` | File is written with mode 0600 |
| `executable_` | File is written with mode 0755 |
| `symlink_` | Creates a symlink rather than copying |
| `.tmpl` suffix | Processed as a Go template before being written |

## Applying changes

```sh
chezmoi apply          # apply all changes to $HOME
chezmoi apply <file>   # apply a single file
chezmoi diff           # preview what would change
chezmoi status         # show which managed files differ
```

## Templates

`.tmpl` files are Go templates evaluated with chezmoi's data. Key template variables:

- `.chezmoi.os` — `"darwin"` or `"linux"`
- `.chezmoi.username` — current user
- `.chezmoi.kernel.osrelease` — used to detect WSL (`contains "microsoft"`)

Secrets are read from 1Password at apply time via `onepasswordRead "op://..."`. The 1Password CLI mode is controlled by `.chezmoi.toml.tmpl`: account mode for user `luca` or WSL, service mode otherwise.

## Platform-conditional files

`.chezmoiignore` excludes files that don't apply to the current platform:
- `Library/` (macOS LaunchAgents) — excluded on Linux
- `dot_config/fish/conf.d/wsl.fish` — excluded on non-WSL Linux
- `dot_config/systemd/` — excluded on macOS

## Commit messages

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/). A `commitlint` hook enforces this at `~/.commitlint/hooks/commit-msg`. Use the format:

```
<type>(<scope>): <description>
```

Common scopes match tool names: `helix`, `fish`, `tmux`, `gitui`, `yazi`, etc.

## Key tools configured

| Tool | Config location |
|---|---|
| **Helix** | `dot_config/helix/config.toml`, `languages.toml.tmpl` |
| **Fish** | `dot_config/fish/` — `conf.d/` files are sourced in numbered order |
| **Tmux** | `dot_config/tmux/tmux.conf`; TPM plugins cloned via `.chezmoiexternal.toml` |
| **Zellij** | `dot_config/zellij/config.kdl`; auto-started by fish on interactive login |
| **Yazi** | `dot_config/yazi/`; accessed from Helix via `Space e` |
| **gitui** | `dot_config/gitui/`; opened from Helix via `Ctrl-g` |
| **efm-langserver** | `dot_config/efm-langserver/config.yaml`; bridges vsg (VHDL Style Guide) into Helix |

## LSP / formatter setup (Helix)

Helix delegates formatting to external tools per language: `shfmt` (bash), `cmake-format` (cmake), `prettier` (yaml/ts/html/css/json), `vsg` via `efm-langserver` (VHDL). The `languages.toml.tmpl` template injects the current username into the efm-langserver path.

## First-time setup

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/LucaZulberti/dotfiles/HEAD/setup.sh)"
```

`setup.sh` installs Homebrew, all CLI tools, Node (via fnm), Rust (via rustup), Miniconda, LSPs, and then runs `chezmoi init LucaZulberti` or `chezmoi update` if already initialised.
