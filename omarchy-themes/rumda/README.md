# rumda-* themes

[🇷🇺 Русский](README.ru.md)

Omarchy themes after [Rumda](https://github.com/hexonide/rumda) by hexonide. The repository has no licence, so only its
colours and look are taken here — no files and none of its cat drawings. `rumda-dark` (coffee graphite with a caramel
accent) and `rumda-light` (sand with brown ink) are **one-colour**: syntax, the 16 terminal colours, statuses and btop
use only shades of the accent and the ink. `rumda-dark-color` and `rumda-light-color` keep Rumda's own colourful terminal.

- Palettes — from its `Colors.qml` (bar, dashboard, borders) and `kitty.conf`.
- btop — laid out like its `rumda.theme`: brown boxes, graphs from ochre through brick to rust.
- fastfetch — in the spirit of its neofetch: a `┌──┐` box, short keys (os, krn, up, pkg, sh, wm) in the accent; the logo is
  an own pixel cat face (`apps/rumda-logo.txt`).
- Wallpapers — the plain theme colour with an own pixel cat silhouette in the corner (`1-plain`), or without it.
- The shell font is the pixel **Dogica Pixel** (Roberto Mocci, SIL OFL 1.1, `kamradsmeshnyavy.customizer/fonts/rumda`).

```sh
python3 build.py            # all themes
python3 build.py dark       # chosen ones
```
