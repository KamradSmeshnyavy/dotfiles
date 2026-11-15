# surface-* themes

[🇷🇺 Русский](README.ru.md)

Omarchy themes after [surface-dots](https://github.com/snes19xx/surface-dots) by **snes19xx**. The repository has no
licence file, but its README says anything may be reused as long as the author and the media sources are credited — so
the colours, curves and layout come from it, with credit here. Its wallpapers are included too (`0-original`).

`surface-dark` (graphite `#141719` with Everforest greens) and `surface-light` (warm paper `#f0ece6` with olive ink) are
**one-colour**: syntax, the 16 terminal colours, statuses and btop use only shades of green and the ink.
`surface-dark-color` and `surface-light-color` keep its own Everforest terminal.

- Palettes — from its `lib/ThemeEngine.qml` (surfaces, text, accents) and `kitty/themes/everforest*.conf`.
- Window borders — 1 px green with alpha, grey when inactive, its warm shadow and green groupbar (`hyprland.lua`);
  thickness and corners come from the style.
- fastfetch — like its `config.jsonc`: the ` ▐ ` separator, Nerd Font icon keys, a `─` line under the title, colour
  circles; the logo is an own pixel Saturn in half blocks (after its Cassini power menu).
- Wallpapers — first its own (`0-original`: `default-dark` / `default-light`; the dark theme also gets the mountains and the
  Earth of its lock screens as `0r-…`, scaled to 3840 px), taken by `build.py` from a surface-dots clone (`SURFACE_DOTS_SRC`)
  or GitHub; then own: paper grain in the theme colour with generated mountain ridges in greens (`1-ridges`), or only the grain
  (`2-paper`).
- Fonts (`kamradsmeshnyavy.customizer/fonts/surface`): **Manrope** (shell), **Newsreader** (power menu),
  **EB Garamond** (lock screen) — SIL OFL 1.1 from Google Fonts; **CMU Typewriter Text** (terminal) — SIL OFL 1.1 from
  the cm-unicode package. Font profile: `omarchy-font-profile surface`.

```sh
python3 build.py            # all themes
python3 build.py dark       # chosen ones
```
