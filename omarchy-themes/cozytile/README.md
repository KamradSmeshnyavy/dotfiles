# cozytile-* themes

[🇷🇺 Русский](README.ru.md)

Omarchy themes after [Cozytile](https://github.com/Darkkal44/Cozytile) by Darkkal44 (a Qtile rice). The repository has no
licence, so its colours and look are taken here, and its code is not copied.

Five themes, like its own: **cozy** (lavender dusk), **sakura** (pink), **natura** (dark grass), **everforest** (misty pine
forest) and the light **carbon** (grey e-paper). They are **one-colour** by default: syntax, the 16 terminal colours, statuses
and btop use only shades of the accent and the ink. The `-color` twins keep the colourful terminal of its
`alacritty/colors.toml`.

- Palettes — from its `qtile/config.py` (the two bar fills, the accent, the current workspace), `rofi/settings/launcher/*.rasi`
  and `dunstrc`; the terminal background is the dark bar fill, as on its screenshots (there pywal colours the terminal).
- Windows — no border (qtile `border_width 0`), a soft shadow like its picom.
- fastfetch — in the spirit of its pfetch: an Arch logo in strokes, keys os / host / kernel / uptime / pkgs / memory.
- Wallpapers — first its own wallpaper for each theme (`0-original`, as its `autostart_once.sh` sets them). `build.py`
  copies them from a Cozytile clone (`COZYTILE_SRC`, default `~/src/rice-refs/Cozytile`) or downloads them from GitHub.
  Then drawn ones: a lavender sky with roofs, a sakura branch, grass blades, a misty pine
  forest, grey paper (`1-cozytile`), and a plain grainy fill (`2-plain`).
- Carbon's terminal is grey only, from its `Wallpaper/e-ink.json`.
- Font profile: `omarchy-font-profile cozytile` (JetBrains Mono Nerd Font everywhere, like its bar and terminal).

```sh
python3 build.py              # all themes
python3 build.py cozy carbon  # chosen ones
```

## Dynamic

`dynamic-<rice>` from the wallpaper (`../scripts/omarchy-rice-dynamic`, rice engine, `build.py` → `dynamic()`): soft background, a pastel accent and a second colour from the wallpaper; any variant (Carbon too) can be turned light ↔ dark. Details: `../APP-THEMING.en.md`, Customizer → Dynamic.
