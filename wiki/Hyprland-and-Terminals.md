**English** · [Русский](Hyprland-and-Terminals-ru)

# Hyprland and terminals

## Hyprland (Lua)

The config is Lua on top of Omarchy 4 defaults: `hyprland.lua` loads Omarchy, then my `monitors`, `input`, `bindings`,
`windows`, `looknfeel`, `autostart`, `env`. Apply changes with **`hyprctl eval`** or `hyprctl reload` — with Lua,
`hyprctl keyword` and plain `hyprctl dispatch` do nothing.

Most useful binds: `Super+Shift+T` Customizer, `Super+M` settings, `` Super+` `` overview, `Super+Alt+D` dashboard,
`Super+Esc` power menu, `Super+Alt+C/O/U` shader / transparency / blur presets, `Super+H/J/K/L` smart focus. Full list:
[docs/apps/hyprland.md](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/hyprland.md).

## Terminals

- **Kitty** (main): Maple Mono NF CN by default, kitty-scrollback.nvim (`Alt+P`), blur, theme from Omarchy, the
  Customizer style (`style.conf`) and the font profile (`fonts.conf`).
- **Ghostty**: shaders and cursor shaders (submodules), the same theme / style / font includes.

## Shell and tools

**Nushell** + **Starship**; Zsh as the fallback. Every TUI tool (yazi, lazygit, btop, tmux, atuin, television, gitui,
rmpc, fastfetch, fzf…) follows the theme — see [Themes and app theming](Themes-and-App-Theming). Neovim (LazyVim) takes
its colour scheme from the theme too.
