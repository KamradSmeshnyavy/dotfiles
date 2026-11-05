# Starship

[🇷🇺 Русский](starship.ru.md)

A fast, cross-platform, highly configurable prompt — the prompt for Nushell and Zsh.

## Paths

- **In the repo:** `shells/starship.toml`
- **Linked to:** `~/.config/starship.toml`

## What differs from the defaults

- **Palette:** the full `catppuccin_mocha` palette (rosewater, flamingo, mauve, sky, peach, …).
- **Format:** user, host, directory, git branch, git status, command duration, Python environment — then a line break
  (`$line_break`) before the character (`$character`).
- **Git:** the branch in bright black; repo states (staged, conflicts, deletions) as minimal icons or hidden to cut noise
  (conflicted / untracked / staged / modified are hidden).
- **Character:** `❯` green after success, red after an error; in vi command mode (`vimcmd_symbol`) `❮` in sky.
- **Directories:** blue, truncated to 2 levels (`truncation_length = 2`, symbol `…/`); the repo root in bold cyan.
- No blank line before the prompt (`add_newline = false`).
