# unit3-* themes

[🇷🇺 Русский](README.ru.md)

Omarchy themes after [Unit-3](https://github.com/samyns/Unit-3) by samyns — a Hyprland + Quickshell rice with a
NieR:Automata look (MIT). Colours are taken from its configs.

- `unit3-dark` — its desktop and terminal: dark sepia `#0b0a09`, text `#c8b89a`, muted accents (red `#c87060`, green
  `#60a880`, blue `#6090c8`, gold `#c8a860`); the 16 terminal colours are exactly those of its `kitty.conf`.
- `unit3-paper` — its menus (launcher, control center) for the whole desktop: the beige NieR paper `#d6cfb5`, ink
  `#463f2e`, red `#6e2a2a`.
- Windows — a 1 px border in the text colour (inactive — `#1a1814`), no rounding, shadow or blur, like its
  `hyprland.conf`.
- Wallpapers — its own first (`assets/wallpapers` of the rice, kept in the repo): 2B in the forest (`0-original`), a
  battle, the YoRHa logo and a Hollow Knight scene; then a drawn NieR grid in the theme colours (`1-grid`). The pictures
  are game art by their authors, not covered by the rice's MIT licence.
- Font profile: `omarchy-font-profile unit3` (Share Tech Mono in the shell, terminal and code, OFL —
  `kamradsmeshnyavy.customizer/fonts/unit3`).

```sh
python3 build.py          # both
python3 build.py paper    # only these
```
