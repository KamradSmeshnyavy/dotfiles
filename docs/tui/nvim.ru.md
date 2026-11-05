# Neovim

[🇬🇧 English](nvim.md)

Основной редактор: конфиг на базе `LazyVim` со множеством своих плагинов.

## Пути

- **В репозитории:** `tui/nvim`
- **Линкуется в:** `~/.config/nvim`

## Отличия от настроек по умолчанию

### Ядро

- **LazyVim** как основа (LSP, автодополнение, разумные настройки), менеджер плагинов `lazy.nvim`.

### Внешний вид

- **Цветовая схема берётся из темы Omarchy:** `colorscheme.lua` грузит собственную схему темы из
  `~/.local/state/omarchy/current/theme/nvim` (например, `nothing-steel` с подходящей темой lualine), поэтому Neovim
  меняется вместе с темой рабочего стола.

### Ключевые плагины

- **Файлы:** `neo-tree.nvim`, `oil.nvim` (файловая система как текст), `yazi.lua` (Yazi внутри Neovim).
- **Терминал и tmux:** `vim-tmux-navigator` (бесшовно между панелями и окнами), `kitty-scrollback.nvim` (буфер прокрутки
  Kitty в Neovim).
- **Редактирование:** `multicursor.nvim`, `surround.lua`, `nvim-colorizer.lua` (hex-цвета), `markdown.lua` /
  `render-markdown` (Markdown прямо в буфере), `obsidian.lua` (заметки хранилища), `codediff.lua`, `gitsigns.lua`.
- **Учёт и практика:** `wakatime`, `leetcode.lua`.
- **Удалённый буфер обмена:** `config/remote_clipboard.lua` — OSC 52 через SSH.

### LSP и линтеры

- **Python:** `basedpyright` и `ruff`; форматирование через `conform`, линтинг через `lint`.
- **FASM:** свой LSP и синтаксис для flat assembler (`fasm-lsp.lua`, `fasm-syntax.lua`).
