# CLI/TUI app themes for Omarchy themes

[🇷🇺 Русский](APP-THEMING.md)

`scripts/omarchy-app-themes` (run from `hooks/theme-set` and `hooks/font-set`) colours the apps Omarchy itself doesn't touch.

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
| `fastfetch.jsonc` | `~/.config/fastfetch/config.jsonc` | read by fastfetch itself |
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
| `vesktop.css.tpl` | `~/.config/vesktop/themes/omarchy.css` | the script enables `omarchy.css` + `omarchy-fonts.css` itself (see below) |
| `mpv-osc.conf.tpl` | `~/.config/mpv/script-opts/osc.conf` | read by mpv's built-in OSC |
| `qt6ct-colors.conf.tpl` | `~/.config/qt6ct/colors/omarchy.conf` | needs the `qt6ct` package: then the script writes `qt6ct.conf` (Fusion + theme icons) and `env.lua` sets `QT_QPA_PLATFORMTHEME=qt6ct` |

A template lands in the theme only on `omarchy theme set` (`just theme <name>`), not on `just app-themes`.

## GUI apps: generators

A theme may ship its own hand-made `apps/<file>`; otherwise the script builds it from `colors.toml` into
`~/.local/state/omarchy/app-themes/generated-<file>`. All generators share colour roles (background, surface,
selection, accent…) from `scripts/theme_palette.py`. Fonts come from fontconfig (`sans-serif`, `monospace`), so the
script also runs after `omarchy font set` (hook `hooks/font-set`) and `omarchy-font-profile`.

| theme file | generator | target | visible |
|---|---|---|---|
| `gtk4.css` | `omarchy-gtk-theme` | `~/.config/gtk-4.0/gtk.css` (libadwaita variables) | new GTK4 windows (Nautilus, portals) |
| `gtk3.css` | `omarchy-gtk-theme --gtk3` | `~/.config/gtk-3.0/gtk.css` (`@define-color`) | new windows; needs the `adw-gtk3` theme (package `adw-gtk-theme`), which the script selects instead of Adwaita |
| `ghidra.theme` | `omarchy-ghidra-theme` | `~/.config/ghidra/ghidra_*/themes/omarchy.theme` + `Theme=` in `preferences` | next Ghidra start; `preferences` is left alone while Ghidra runs |
| `telegram.tdesktop-theme` | `omarchy-telegram-theme` | `~/.local/state/omarchy/app-themes/omarchy.tdesktop-theme` | immediately, after one manual apply (below) |
| `telegram.attheme` | `omarchy-telegram-android-theme` | `~/.local/state/omarchy/app-themes/Omarchy.attheme` | on the phone, after forwarding and applying (below) |
| `wl-kbptr.opts` | `omarchy-kbptr-theme` | `~/.local/state/omarchy/app-themes/wl-kbptr.opts` (slot) | next time hints open |

Ghidra: FlatLaf colours (`[laf.color]Panel.background` etc. — `system.color.bg.control` does not paint panels),
listing, decompiler, bookmarks; `font.standard` / `font.monospaced` use the system fonts at size 13.

**Telegram** keeps the theme internally but watches the applied theme file (`QFileSystemWatcher`) and reloads it.
So apply it once: `just app-themes telegram` opens Telegram's "Forward to…" with the file → send it to Saved
Messages → click the file → Apply. After that the file is updated in place on every theme change.
Telegram 7 opens a `.tdesktop-theme` passed on the command line as "Forward to…", not as a preview.
Palette keys live in `scripts/data/telegram-palette.tsv` (from lib_ui; refresh with
`omarchy-telegram-theme --update-palette`): greys of the default light theme map onto the background…text ramp,
colours onto the nearest theme colour by hue, outgoing messages onto the accent. Media viewer and calls
(dark by design) are left alone.

**Telegram for Android** reads an `.attheme` file (`key=#AARRGGBB` lines; the theme's name in Telegram is the file
name, and Telegram decides dark or light from `windowBackgroundWhite`). The file is always `Omarchy.attheme`, so
applying it again replaces the same theme. The phone doesn't watch the file, so after an Omarchy theme change:
`just app-themes telegram-android` opens Telegram Desktop's "Forward to…" with the file → send it to Saved
Messages → on the phone tap the file → Apply. Keys live in `scripts/data/telegram-android-palette.tsv` (from
DrKLO/Telegram `ThemeColors.java`; refresh with `omarchy-telegram-android-theme --update-palette`). Recolouring is
shared with desktop (`scripts/telegram_common.py`); on top of that the dark hover haze turns light, white text on
coloured chips becomes on-accent text, and secondary text is lifted to 4.5 contrast. Calls (`voipgroup_`, `calls_`)
and toasts (`undo_`) are left alone.

**Vesktop**: the script writes `omarchy-fonts.css` (system fonts); `enabledThemes` = `omarchy.css` +
`omarchy-fonts.css` is set only while Vesktop is closed. Vencord misses content changes behind a symlink, so the
script runs `touch -h` on the link and the theme changes without a restart. Stock `discord` takes no CSS.

**Qt**: `qt6ct.conf` gets fonts too (`[Fonts]`). Needs the `qt6ct` package and a re-login. Telegram is Qt but draws
itself.

**wl-kbptr** reads a single config, so `wl-kbptr.opts` is not a config but one option per line
(`mode_tile.label_color=#rrggbbaa`): `apps/hyprland/scripts/kbptr-wrapper.sh` passes them as `-o` on top of
`apps/wl-kbptr/config` (which keeps label symbols, modes and sizes; its colours are only a fallback). The generator
also follows the Customizer style (`~/.config/omarchy/style.json`): wl-kbptr has no corner radius or border width,
so the style sets backdrop opacity (glass — more transparent, flat/brutal/retro/paper — solid cells), cell border
colour (brutal/retro — text colour, neon — accent) and the font: DOT-MATRIX — `DotMatrix Dot`, otherwise the
`typeface` token (`shell` — Omarchy font, `profile` — sans from `fonts.json`, `hand` — handwritten). A theme's own
`apps/wl-kbptr.opts` replaces both colours and style.

Not recoloured: Signal and Bitwarden (light/dark only — they follow `color-scheme`), Spotify (spicetify only),
LibreOffice/OnlyOffice (partly, via GTK3).

## Cursor

`<theme>/apps/cursor` — one line `NAME SIZE`; without it `app-defaults/cursor` (or `cursor-light` for
`mode = "light"`). Applied right away (`hyprctl setcursor`, gsettings) and saved to
`~/.local/state/omarchy/app-themes/cursor`, which `apps/hyprland/env.lua` reads at login.

## Theme from wallpaper

`just theme-from-wallpaper [image] [--scheme vibrant|expressive|…] [--mode light]` (`scripts/omarchy-wallpaper-theme`,
on `PATH` as `omarchy-wallpaper-theme`) runs the wallpaper through matugen and writes the theme
`~/.config/omarchy/themes/dynamic`: just `colors.toml` (Material You + ANSI colours blended towards the wallpaper),
`icons.theme` (Yaru by accent hue) and the wallpaper itself. Everything else — terminals, btop, nvim, Hyprland, the
templates above, slots, browsers — `omarchy-theme-set` generates. Customizer → Theme has “🎨 Theme from wallpaper” rows.

## Boot

`just boot-theme` (`scripts/omarchy-boot-theme`, needs sudo) recolours the header of `/boot/limine.conf`
(backup — `limine.conf.bak-boot-theme`) and the Plymouth screen (`omarchy-plymouth-set-by-theme`). Not run
from the hook; `just boot-theme --dry-run` shows the diff.

## A new theme

Put the files you need into `<theme>/apps/` — every other app stays on `app-defaults`.
