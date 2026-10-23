# Catppuccin Mocha Efter для Omarchy

[Catppuccin Mocha](https://catppuccin.com/palette) с акцентом lavender — все темы приложений из
[Efterklang/dotfiles](https://github.com/Efterklang/dotfiles) в одной теме Omarchy.

```sh
omarchy theme set catppuccin-mocha-efter
```

## Файлы, которые применяет сам Omarchy

Основа взята из `catppuccin-mocha-lavender` (там же таблица источников): kitty (`application/kitty/mocha.conf`),
ghostty/alacritty/foot, btop (`tui_cli/btop/themes/catppuccin_mocha.theme`), cava, helix, neovim, vscode,
obsidian, gum, chromium, hyprland, Dark Reader (`application/chromium/configs/Dark-Reader-Settings.json`).
Stylus и Surfingkeys подхватывают палитру через `hooks/theme-set` (см. `../BROWSER-THEMING.md`).

## `apps/` — приложения, которые Omarchy не красит

Их переключает `scripts/omarchy-app-themes` (см. `../APP-THEMING.md`).

| файл | приложение | источник в Efterklang/dotfiles |
|---|---|---|
| `yazi.toml` | yazi | `tui_cli/yazi/theme.toml` (flavor catppuccin-mocha) |
| `lazygit.yml` | lazygit | `gui.theme` из `tui_cli/lazygit/config.yml` |
| `atuin.toml` | atuin | `tui_cli/atuin/themes/catppuccin-mocha-lavender.toml` |
| `lla.toml` | lla | `tui_cli/lla/themes/catppuccin.toml` |
| `television.toml` | television | его `theme = …` + встроенная `catppuccin` из television 0.15.9 |
| `gitui.ron` | gitui | `tui_cli/gitui/theme.ron` |
| `rmpc.ron` | rmpc | `tui_cli/rmpc/themes/catppuccin_mocha.ron` |
| `nushell.nu` | nushell | `shells/nushell/themes/catppuccin-mocha.nu` |
| `tmux.conf` | tmux | `tui_cli/tmux/theme.conf` + `@om_*` для статусбара |
| `glow.json` | glow | `tui_cli/glow/catppuccin.json` (через `GLAMOUR_STYLE`) |
| `env` | bat, glow | `BAT_THEME=Catppuccin Mocha` (`tui_cli/bat/config`) |
| `vimium_c.css` | Vimium C | `application/chromium/configs/vimium_c/catppuccin_vimium.css` — импортировать вручную |

Без отдельного слота, потому что уже Catppuccin Mocha в любой теме: delta (`syntax-theme`), scooter, wezterm, starship
(палитра не включена, цвета ANSI — как у Efterklang).

Не перенесено (macOS/Windows или не установлено): zellij, tauon, yasb, sketchybar, borders, windows-terminal,
karabiner, zed.

Обои — те же, что у `catppuccin-mocha-lavender` (жёсткие ссылки на диске, в git одни и те же блобы).
