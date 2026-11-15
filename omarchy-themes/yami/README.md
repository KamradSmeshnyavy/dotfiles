# yami-* themes

[🇷🇺 Русский](README.ru.md)

Seven dark Omarchy themes after [yami](https://github.com/Trendorin/yami) (MIT, © Trendorin and the yami contributors), one per
yami accent preset: `yami-blood`, `-ash`, `-sakura`, `-amber`, `-venom`, `-ice`, `-dusk`.

yami has a single accent and derives every other tone from it (`shell/src/recolor_math.rs`): graphite slightly tinted with
the accent's hue for the background, panels and surfaces; borders and dim text are mixes of the panel with the accent.
`build.py` repeats that derivation and lays the result over every app with the generator of the `nothing` themes
(`../nothing/build.py`). yami sets no syntax colours — muted ones are picked here to sit on the graphite and brightened to
a contrast of 4.5. The wallpapers are graphite with a grid of small square dots and a soft light from one corner, like
yami's pixel background.

The terminal's 16 colours follow yami (`recolor_apps.rs`, `ansi`): the usual hues shifted 18 % towards the accent, colour 0 the panel, 7 / 15 the text. fastfetch is yami's own too: the 闇 sign drawn in half blocks in four bands from the bright to the deep accent with a shadow, «YAMI // hyprland», keys in the accent and a strip of the palette (`apps/fastfetch.jsonc`, `apps/yami-logo.txt`).

The themes are **one-colour** by default, like yami itself on its screenshots: syntax, the 16 terminal colours and statuses use only shades of the accent and the graphite grey, and btop is exactly yami's (`btop.theme`, from `recolor_apps.rs`, `btop`). `python3 build.py --color` builds the colourful variant (yami's `ansi` and muted syntax colours) instead.

```sh
python3 build.py             # all themes
python3 build.py blood ash   # chosen ones
```

The shell font of the rice — the pixel Tiny5 — comes with the `yami` font profile (`omarchy-font-profile yami`, fonts in
`kamradsmeshnyavy.customizer/fonts/yami`, OFL).
