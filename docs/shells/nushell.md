# Nushell

[🇷🇺 Русский](nushell.ru.md)

The main shell: it treats data as structured tables rather than plain text.

## Paths

- **In the repo:** `shells/nushell` (`config.nu`, `env.nu`, `aliases/`, `completions/`, `plugins/`, `utils/`, `themes/`)
- **Linked to:** `~/.config/nushell`

## What differs from the defaults

- **Colours follow the Omarchy theme:** `themes/omarchy.nu` is a theme slot that `omarchy-app-themes` points at the
  current theme; `config.nu` sources it when it exists.
- **Output:** no banner (`show_banner: false`); tables switch between `table -e` and `table` by terminal width (from 100
  columns).
- **File colours:** directories blue, files white, executables green, symlinks cyan; `error_style: "fancy"`.
- **Behaviour:** `rm` always goes to the trash (`always_trash: true`); `edit_mode: vi` with the cursor shape following
  the vi mode (block, blinking block, blinking underscore).
- **Terminal integration:** extended OSC sequences and the Kitty keyboard protocol (`use_kitty_protocol: true`).
- **Hooks and plugins:** an `env_change` hook for `direnv` (load / unload project environments); a customised completion
  menu; plugin GC (`stop_after: 10sec`); `mise.nu` for runtimes.
