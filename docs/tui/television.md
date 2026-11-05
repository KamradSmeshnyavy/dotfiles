# Television

[🇷🇺 Русский](television.ru.md)

A fast terminal fuzzy finder for files, text and more.

## Paths

- **In the repo:** `tui/television`
- **Linked to:** `~/.config/television`

## What differs from the defaults

- **UI:** Nerd Font icons, full screen, `landscape`, the input bar on top; the preview on by default (50 %, with a
  scrollbar); status bar on, help and remote control hidden.
- **Colours follow the Omarchy theme:** `themes/omarchy.toml` is a theme slot — a gitignored symlink that `omarchy-app-themes` points at the current theme (see `omarchy-themes/APP-THEMING.md`).
- **General:** history of 200 per channel (no global history), default channel `files`, `tick_rate = 50`.
- **Shell integration:** `ctrl-t` — smart completion, `ctrl-r` — history. Channel triggers: `cd`, `ls`, `rmdir`, `z` →
  `dirs`; `cat`, `vim`, `nano`, `bat`, file commands and archivers → `files`; git commands → `git-diff`, `git-branch`,
  `git-log`, `git-repos`; `kill`, `procs` → `procs`; `docker run` → `docker-images`.
