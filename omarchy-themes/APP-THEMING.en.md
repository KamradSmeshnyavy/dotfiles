# CLI/TUI app themes for Omarchy themes

[🇷🇺 Русский](APP-THEMING.md)

`scripts/omarchy-app-themes` (run from `hooks/theme-set`) colours the apps Omarchy itself doesn't touch.

## Slots

Each app reads its theme from a single slot file. The slot is a symlink (git-ignored) that the script
repoints on every theme change: to `apps/<file>` of the current theme, or, if the theme has no such file,
to `app-defaults/<file>` (the previous behaviour: terminal colours or the app's built-in theme).

| theme file | slot | wired up in |
|---|---|---|
| `yazi.toml` | `~/.config/yazi/theme.toml` | read by yazi itself |
| `yazi-flavor/` (directory) | `~/.config/yazi/flavors/omarchy.yazi` | `dark = "omarchy"` in the theme's `yazi.toml` |
| `yatline.lua` | `~/.config/yazi/plugins/yatline-omarchy.yazi/main.lua` | `init.lua`: `require("yatline-omarchy"):setup()` |
| `lazygit.yml` | `~/.config/lazygit/theme.yml` | `LG_CONFIG_FILE` in `env.nu` / `.zshrc` |
| `atuin.toml` | `~/.config/atuin/themes/omarchy.toml` | `[theme] name = "omarchy"` |
| `lla.toml` | `~/.config/lla/themes/omarchy.toml` | `theme = "omarchy"` |
| `television.toml` | `~/.config/television/themes/omarchy.toml` | `theme = "omarchy"` |
| `gitui.ron` | `~/.config/gitui/theme.ron` | read by gitui itself |
| `rmpc.ron` | `~/.config/rmpc/themes/omarchy.ron` | `theme: "omarchy"` |
| `nushell.nu` | `~/.config/nushell/themes/omarchy.nu` | `source` in `config.nu` |
| `tmux.conf` | `~/.config/tmux/om-app-theme.conf` | `tmux.conf`, after `om-theme.conf`; reloaded immediately |
| `fzf.opts` | `~/.local/state/omarchy/app-themes/fzf.opts` | `FZF_DEFAULT_OPTS_FILE` in `env.nu` / `.zshrc` |

If a theme has no `apps/yatline.lua` or `apps/fzf.opts`, the script generates them from its `colors.toml`
(`scripts/omarchy-yatline-theme`, `scripts/omarchy-fzf-theme` → `~/.local/state/omarchy/app-themes/generated-*`);
`apps/yatline-palette.toml` (same keys as `colors.toml`) overrides the colours — that is how rose-pine-hacker*
is done.

delta sets no `syntax-theme`, so it takes `BAT_THEME` from the theme's `env` (efter — Catppuccin Mocha,
the rest — ansi).

`env` (`KEY=VALUE` lines, `{theme}` is the path to the current theme) becomes
`~/.local/state/omarchy/app-theme.json` (nushell, `load-env` in `env.nu`) and `app-theme.zsh` (`.zshrc`).

Except for tmux, a new theme shows up in a new terminal window or on the app's next start.

## GUI apps: Omarchy templates

`omarchy-theme-set` itself renders `themed/*.tpl` (linked into `~/.config/omarchy/themed`) from `colors.toml` into
the theme root — syntax `{{ accent }}`, `{{ accent_strip }}`, `{{ mix a b 30% }}`. The script points slots at them:

| template | slot | wiring |
|---|---|---|
| `vesktop.css.tpl` | `~/.config/vesktop/themes/omarchy.css` | enable `omarchy.css` once in Vesktop → Themes |
| `mpv-osc.conf.tpl` | `~/.config/mpv/script-opts/osc.conf` | read by mpv's built-in OSC |
| `qt6ct-colors.conf.tpl` | `~/.config/qt6ct/colors/omarchy.conf` | needs the `qt6ct` package: then the script writes `qt6ct.conf` (Fusion + theme icons) and `env.lua` sets `QT_QPA_PLATFORMTHEME=qt6ct` |

A template lands in the theme only on `omarchy theme set` (`just theme <name>`), not on `just app-themes`.

## Cursor

`<theme>/apps/cursor` — one line `NAME SIZE`; without it `app-defaults/cursor` (or `cursor-light` for
`mode = "light"`). Applied right away (`hyprctl setcursor`, gsettings) and saved to
`~/.local/state/omarchy/app-themes/cursor`, which `apps/hyprland/env.lua` reads at login.

## Boot

`just boot-theme` (`scripts/omarchy-boot-theme`, needs sudo) recolours the header of `/boot/limine.conf`
(backup — `limine.conf.bak-boot-theme`) and the Plymouth screen (`omarchy-plymouth-set-by-theme`). Not run
from the hook; `just boot-theme --dry-run` shows the diff.

## A new theme

Put the files you need into `<theme>/apps/` — every other app stays on `app-defaults`.
