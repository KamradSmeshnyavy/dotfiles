# Helix

[🇷🇺 Русский](helix.ru.md)

A modern modal editor inspired by Kakoune and Neovim.

## Paths

- **In the repo:** `tui/helix`
- **Linked to:** `~/.config/helix`

## What differs from the defaults

- Theme `catppuccin_mocha` with true colour.
- Relative line numbers, cursor line, indent guides; LSP inlay hints.
- Status line: mode, spinner and diagnostics on the left; file name and VCS status in the middle.
- Reworked normal and select modes:
  - `w`, `e`, `b` behave more like Vim (no sticky selection);
  - shortcuts for the system clipboard (copy, delete, paste);
  - `esc` clears every selection and extra cursor.
