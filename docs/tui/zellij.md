# Zellij

[🇷🇺 Русский](zellij.ru.md)

A terminal multiplexer with plugins and layouts, written in Rust.

## Paths

- **In the repo:** `tui/zellij`
- **Linked to:** `~/.config/zellij`

## What differs from the defaults

- Custom `layouts/`, `plugins/` and `themes/`.
- **tmux-like keys:** defaults cleared (`clear-defaults=true`); modes on `Ctrl+Alt+<key>` (`a` pane, `w` tab,
  `x` session, `r` resize, `m` move); the plugin manager on `Ctrl+Alt+f` (floating); pane navigation `Ctrl+h/j/k/l` and
  `Ctrl+\`; arrows `Alt+←/→/↑/↓` move focus or tabs; swap layouts `Alt+{ }` and `Alt+[ ]` (for macOS terminals).
