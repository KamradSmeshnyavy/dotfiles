# Tmux

[🇷🇺 Русский](tmux.ru.md)

The terminal multiplexer: sessions, windows and panes.

## Paths

- **In the repo:** `tui/tmux`
- **Linked to:** `~/.config/tmux`

## What differs from the defaults

A heavy, fully rewritten config built for comfort and the system look.

### Basics

- Windows and panes start at `1`; `renumber-windows on`.
- True colour, including overrides for Ghostty (`xterm-ghostty`).
- Full mouse support.
- Closing the last pane switches to another session instead of quitting (`detach-on-destroy off`).

### Key bindings (`tmux.binds.conf`)

- All default bindings are dropped (`unbind-key -a`) and rebuilt from scratch.
- Seamless navigation between tmux panes and Neovim windows (`C-h`, `C-j`, `C-k`, `C-l`, `vim-tmux-navigator`).
- Many bindings are inspired by Zellij (some work without the prefix).

### Look

- Colours follow the Omarchy theme: `omarchy-tmux-theme` writes `om-theme.conf` on every theme change, and
  `om-app-theme.conf` is a theme slot.
- `scripts/` — status bar, session and clipboard helpers; a custom status bar with the session, windows and time.
