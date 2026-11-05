# Lla

[🇷🇺 Русский](lla.ru.md)

A fast, customisable `ls` replacement.

## Paths

- **In the repo:** `tui/lla`
- **Linked to:** `~/.config/lla`

## What differs from the defaults

- Sort by `name`, `default` format, icons off, symbolic permissions (`-rw-r--r--`).
- Natural sorting (2.txt before 10.txt).
- Fuzzy search ignores heavy folders: `node_modules`, `target`, `.git`, `.idea`, `.vscode`.
- The `long` format columns: `permissions`, `size`, `modified`, `user`, `group`, `name`, date `%Y-%m-%d %H:%M`.
- **Colours follow the Omarchy theme:** `themes/omarchy.toml` is a theme slot — a gitignored symlink that `omarchy-app-themes` points at the current theme (see `omarchy-themes/APP-THEMING.md`). Change colours inside the theme, not here.
