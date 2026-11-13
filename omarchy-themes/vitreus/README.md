# vitreus-* themes

[🇷🇺 Русский](README.ru.md)

Seven Omarchy themes from the themes of [Vitreus](https://github.com/natepayn3/Vitreus) (MIT, © natepayn3): `vitreus-retro`,
`-uwu`, `-cyber`, `-milk`, `-doodle`, `-paper`, `-proxy`. Vitreus's own Glass has no palette — it takes its colours from the
wallpaper, which is the `dynamic` theme here.

Each Vitreus theme has eleven interface colours (ink, faint, mint — the accent, mintlo / minthi, onmint, tint — the
background, panel, deep, off, alert); `build.py` lays them out over every app with the generator of the `nothing` themes
(`../nothing/build.py`). Syntax and status colours are not part of Vitreus — they are picked here to match each theme and
brightened or darkened to a contrast of 4.5 against the background (comments 3), so code stays readable. The wallpapers
are soft "liquid" blobs of the theme colours (Vitreus ships none), something for the glass to blur.

```sh
python3 build.py            # all themes
python3 build.py retro uwu  # chosen ones
```

The Customizer presets **Liquid Retro … Proxy** put the Liquid Glass style on these themes with the theme's title font
(`omarchy-font-profile vitreus-<theme>`).
