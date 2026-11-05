# Fish

[🇷🇺 Русский](fish.ru.md)

A friendly shell with autosuggestions and syntax highlighting out of the box.

## Paths

- **In the repo:** `shells/fish`
- **Linked to:** `~/.config/fish`

## What differs from the defaults

- **Modern CLI tools:**
  - `zoxide` as a smarter `cd` (alias `cd="z"`);
  - `oh-my-posh` prompt from `~/.config/ohmyposh/omp.json`;
  - `tv` (television) wired in at startup;
  - `carapace` bridge for layered completions (`tui/carapace/bridge/fish/config.fish`).
- **Aliases:** `gg="gitui"`, `lg="lazygit"`, `vim="nvim"`, `cat="bat"`, `cls="clear"`, `f="fish"`.
- **Environment and paths:** `uv`, `rustup`, `~/.local/bin` and fzf (`/opt/homebrew/opt/fzf/bin`) are added to `PATH`.
- **Look and keys:** the theme and key bindings are frozen into `fish_frozen_theme.fish` and
  `fish_frozen_key_bindings.fish`.
