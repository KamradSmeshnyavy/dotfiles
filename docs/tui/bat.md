# Bat

[🇷🇺 Русский](bat.ru.md)

A `cat` clone with syntax highlighting and git integration (`cat` is aliased to `bat` in the shells).

## Paths

- **In the repo:** `tui/bat`
- **Linked to:** `~/.config/bat`

## What differs from the defaults

- Colour always on (`--color="always"`).
- Style: line numbers, git changes, file name and size in the header (`--style="numbers,changes,header-filename,header-filesize"`).
- No pager (`--paging=never`). In scripts use `command cat` when you need a plain `cat`.
- After installation Dotbot runs `bat cache --build` (custom themes and syntaxes).
