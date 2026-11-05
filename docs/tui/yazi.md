# Yazi

[🇷🇺 Русский](yazi.ru.md)

A blazing fast terminal file manager in Rust with async I/O and previews.

## Paths

- **In the repo:** `tui/yazi`
- **Linked to:** `~/.config/yazi`

## What differs from the defaults

Heavily extended with plugins and Lua scripts (`init.lua`).

### Plugins (`package.toml`)

- **Systems:** `git` / `vcs-files` for file status, `mactag` for macOS tags.
- **Look:** `full-border`, `max-preview`.
- **Comfort:** `smart-enter`, `chmod`, `clipboard`, `mount`, `ouch` (any archive format).
- `television` fuzzy search.

### Theme and UI

- **Colours follow the Omarchy theme:** `theme.toml` is a slot pointing at the current theme's `yazi.toml`, the flavor is
  `omarchy` (`flavors/omarchy.yazi`), and the yatline status bar plugin (`yatline-omarchy.yazi`) is themed too.
- A custom Lua status bar (`init.lua`) with progress and metadata.

### Keys (`keymap.toml`)

A large keymap for Vim-style navigation and quick access to the plugins (archives, search, git).
