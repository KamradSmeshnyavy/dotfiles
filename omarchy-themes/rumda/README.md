# rumda-* themes

[🇷🇺 Русский](README.ru.md)

Omarchy themes after [Rumda](https://github.com/hexonide/rumda) by hexonide. The repository has no licence, so only its
colours, look and wallpapers are taken here — its code is not copied. `rumda-dark` (coffee graphite with a caramel
accent) and `rumda-light` (sand with brown ink) are **one-colour**: syntax, the 16 terminal colours, statuses and btop
use only shades of the accent and the ink. `rumda-dark-color` and `rumda-light-color` keep Rumda's own colourful terminal.

- Palettes — from its `Colors.qml` (bar, dashboard, borders) and `kitty.conf`.
- btop — laid out like its `rumda.theme`: brown boxes, graphs from ochre through brick to rust.
- fastfetch — in the spirit of its neofetch: a `┌──┐` box, short keys (os, krn, up, pkg, sh, wm) in the accent; the logo is
  an own pixel cat face (`apps/rumda-logo.txt`).
- Wallpapers — first its own from `pictures/` (`0-original`: the dark one with a cat, the light one with coffee; then `0r-…`: the
  katana-and-sakura variants of the dark one, the warm sand one of the light one), then own: the plain theme colour with a pixel
  cat silhouette in the corner (`1-plain`), or without it. `build.py` takes them from a Rumda clone (`RUMDA_SRC`) or GitHub.
- The shell font is the pixel **Dogica Pixel** (Roberto Mocci, SIL OFL 1.1, `kamradsmeshnyavy.customizer/fonts/rumda`).
- Windows get Rumda's double border: the brown 3 px border, a 13 px band of the background (11 px of sand in the light
  theme) and an outer sand line — through the borders-plus-plus plugin (`just hypr-plugins`, see `docs/apps/hyprland.md`);
  without it only the single border is drawn.

```sh
python3 build.py            # all themes
python3 build.py dark       # chosen ones
```
