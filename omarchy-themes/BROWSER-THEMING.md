# Browser theming for Omarchy themes

Dark Reader and Stylus in Helium follow the current Omarchy theme.

## Pieces

| Path | What it does |
|---|---|
| `hooks/theme-set` | Omarchy `theme-set` hook (→ `~/.config/omarchy/hooks/theme-set`); runs both sync scripts |
| `hooks/post-boot.d/darkreader-sync` | applies Dark Reader settings left pending at logout |
| `scripts/omarchy-darkreader` | picks the theme's `dark-reader.json` or generates one from `browser-templates/efterklang/Dark-Reader-Settings.json` (colors only), forces the Maple Mono NF CN font, writes it into Dark Reader's storage while Helium is closed |
| `scripts/omarchy-stylus` | recolors the official Catppuccin userstyles (`browser-templates/catppuccin/stylus-import.json`, lib inlined from `lib-std-v1.less`) to the theme palette; `prime` asks Stylus for one update check after the next Helium start |
| `scripts/omarchy-stylus-serve` + `systemd/omarchy-stylus-server.service` | serve the styles on `127.0.0.1:47860–47875` (Stylus throttles per host:port) |
| `scripts/helium-browser` | `~/.local/bin` wrapper: runs `omarchy-darkreader apply` and `omarchy-stylus prime` before starting Helium |

Dark Reader and Stylus read their data only at startup, so a new theme reaches the browser
on the next Helium launch. Stylus checks updates only after a theme change (its own
interval is set to 8760 h).

## New machine

1. `install/install.py` links everything above (Linux entries in `install/install.conf.yaml`).
2. `omarchy pkg add python-plyvel`
3. `systemctl --user enable --now omarchy-stylus-server`
4. Run `omarchy-themes/scripts/omarchy-stylus sync`, then in Stylus: Manage → Import
   `~/.local/state/omarchy/stylus/www/import.json` (once). Do not edit the update interval field.

State and backups live in `~/.local/state/omarchy/{darkreader,stylus}/`.
