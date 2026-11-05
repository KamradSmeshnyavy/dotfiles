# Neovide

[🇷🇺 Русский](neovide.ru.md)

A GUI client for Neovim, written in Rust.

## Paths

- **In the repo:** `apps/neovide`
- **Linked to:** `~/.config/neovide`

## What differs from the defaults

- **Frameless window:** no system frame or title bar (`frame = "none"`), Neovim takes the whole window.
- **Title text hidden** (`title-hidden = true`).
- Everything else is left to the Neovim config; Neovide is only a minimal wrapper with its smooth cursor and kinetic
  scrolling out of the box.
