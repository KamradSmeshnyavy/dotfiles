# Todo (theme scripts and patches)

[🇷🇺 Русский](todo.ru.md)

Old helper scripts for switching themes system-wide (from before Omarchy's theme hooks).

## Paths

- **In the repo:** `cli/todo`
- **Linked to:** `~/.config/todo`

## What's inside

- `theme.sh` — switches colour themes (profiles `current` and `catppuccin-mocha-pink`) across terminals and bars
  (SketchyBar, Ghostty, Zellij, tmux), editors (VS Code, Neovim / nixvim), the Starship prompt and tool themes (e.g.
  swapping `theme.yml` for eza). On Omarchy this is done by `omarchy-themes/hooks/theme-set` and theme slots instead.
- Debug diff patches for the NixOS / Darwin configs (e.g. `nvim-rollback`) to roll back quickly.
