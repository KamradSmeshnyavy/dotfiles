# Catppuccin Mocha Lavender for Omarchy

[Catppuccin Mocha](https://catppuccin.com/palette) with the lavender accent, adapted from the
app themes in [Efterklang/dotfiles](https://github.com/Efterklang/dotfiles).

| Omarchy file | Taken from Efterklang/dotfiles |
|---|---|
| `kitty.conf` | `application/kitty/mocha.conf` (verbatim) |
| `ghostty.conf`, `alacritty.toml`, `foot.ini` | same palette as `mocha.conf` (Ghostty uses `theme = Catppuccin Mocha`) |
| `btop.theme` | `tui_cli/btop/themes/catppuccin_mocha.theme` |
| `cava_theme` | gradient from `tui_cli/cava/config` |
| `helix.toml` | `theme = "catppuccin_mocha"` from `tui_cli/helix/config.toml`, lavender cursor/statusline |
| `neovim.lua` | catppuccin/nvim, flavour mocha (`tui_cli/nvim`) |
| `vscode.json` | Catppuccin Mocha (`application/vscode/settings.json`, `accentColor: lavender`) |
| `gum_env.lua` | `tui_cli/gum/theme.sh` (mocha, accent lavender, highlight blue) |
| `chromium.theme` | frame color of `application/chromium/custom-extensions/catppuccin_lavender_alt` |
| `dark-reader.json` | `application/chromium/configs/Dark-Reader-Settings.json` (verbatim) |
| `hyprland.lua` | lavender → mauve border (kitty `active_border_color`) |

On `omarchy theme set`, `scripts/omarchy-darkreader` writes `dark-reader.json` into Dark Reader
in Helium (themes without the file get one generated from Efterklang's settings with only the
colors replaced; the font is always Maple Mono NF CN). `scripts/omarchy-stylus` recolors the
official Catppuccin userstyles (`browser-templates/catppuccin/stylus-import.json`) to the
theme palette and serves them from `http://127.0.0.1:47860/`, where Stylus picks them up.

Backgrounds are the originals from `~/Documents/Wallpapers/Wallpapers` recolored with
`lutgen` to this palette.
