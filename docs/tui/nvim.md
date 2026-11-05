# Neovim

[🇷🇺 Русский](nvim.ru.md)

The main editor: a `LazyVim`-based config with many custom plugins.

## Paths

- **In the repo:** `tui/nvim`
- **Linked to:** `~/.config/nvim`

## What differs from the defaults

### Core

- **LazyVim** as the base (LSP, completion, sensible defaults), `lazy.nvim` as the plugin manager.

### Look

- **The colour scheme comes from the Omarchy theme:** `colorscheme.lua` loads the theme's own scheme from
  `~/.local/state/omarchy/current/theme/nvim` (e.g. `nothing-steel`, with a matching lualine theme), so Neovim changes
  with the desktop theme.

### Key plugins

- **Files:** `neo-tree.nvim`, `oil.nvim` (edit the filesystem as text), `yazi.lua` (Yazi inside Neovim).
- **Terminal and tmux:** `vim-tmux-navigator` (seamless panes ↔ windows), `kitty-scrollback.nvim` (Kitty scrollback in
  Neovim).
- **Editing:** `multicursor.nvim`, `surround.lua`, `nvim-colorizer.lua` (hex colours), `markdown.lua` /
  `render-markdown` (rendered Markdown in the buffer), `obsidian.lua` (vault notes), `codediff.lua`, `gitsigns.lua`.
- **Tracking / practice:** `wakatime`, `leetcode.lua`.
- **Remote clipboard:** `config/remote_clipboard.lua` — OSC 52 over SSH.

### LSP and linters

- **Python:** `basedpyright` and `ruff`; formatting through `conform`, linting through `lint`.
- **FASM:** custom LSP and syntax for the flat assembler (`fasm-lsp.lua`, `fasm-syntax.lua`).
