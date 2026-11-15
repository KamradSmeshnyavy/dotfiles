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
(`omarchy-font-profile vitreus-<theme>`). The theme base (`"base"` in `~/.config/omarchy/style.json`) also reshapes the `liquid` launcher (`kamradsmeshnyavy.menu/LiquidView.qml`): plastic bases get a solid inked card with a hard shadow and the Vitreus header (four-square badge, SEARCH › mode, hints in two rows of cells); Retro adds the red tab, grip slots, a screw and red-tinted selection; Cyber gets glowing corner brackets, a ruler and a blinking readout.

The themes are **one-colour** by default: syntax, the 16 terminal colours, statuses and btop use only shades of mint (the accent) and the theme's ink, faint and off — no stray greens or purples. Vitreus itself does not theme the terminal, btop or fastfetch (it has its own terminal in the Desk), so these are made here in its colours: fastfetch shows «VITREUS // theme», a hollow glass V in half blocks from minthi to mintlo and a strip of the palette (`apps/fastfetch.jsonc`, `apps/vitreus-logo.txt`). `python3 build.py --color` builds the earlier colourful variant. Window corners follow each theme's `corner_rounding` (Retro, Cyber, Doodle 3 px, Paper and Proxy 6, Glass and UwU 22, Milkbox 24) through the Liquid-* presets.
