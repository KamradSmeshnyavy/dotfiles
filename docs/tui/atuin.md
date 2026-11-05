# Atuin

[🇷🇺 Русский](atuin.ru.md)

A shell history replacement: history in SQLite, with sync.

## Paths

- **In the repo:** `tui/atuin`
- **Linked to:** `~/.config/atuin`

## What differs from the defaults

- **Sync:** `auto_sync = true` against the official server (`https://api.atuin.sh`) every 10 minutes.
- **Search:** the `skim` engine; `enter_accept = true` runs the chosen command at once; no update check.
- **Colours follow the Omarchy theme:** `themes/omarchy.toml` is a theme slot — a gitignored symlink that `omarchy-app-themes` points at the current theme (see `omarchy-themes/APP-THEMING.md`). Change colours inside the theme, not here.
