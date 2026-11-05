**English** · [Русский](Wallpapers-and-Pickers-ru)

# Wallpapers and pickers

## Wallpaper FX

**24 wallpaper transitions** on a single custom shader: slant, fade, wipe, wave, grow, outer, diamond, clock, blinds,
doors, mosaic, dissolve, pixelize, ripple, swirl, crosszoom, slide, zoom, glitch, burn, waterdrop, hexagon, random,
none. Repo: [omarchy-wallpaper-fx](https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx --enable
omarchy restart shell
```

Customizer → Desktop → **Wallpaper FX**: effect, duration, easing, angle, origin (centre / cursor / random), softness;
`p` replays the current effect. From a terminal: `omarchy-shell background replay`. Settings:
`~/.config/omarchy/wallpaper-transition.json`.

## Picker styles

Six styles for the theme and wallpaper picker: `slices` (stock), `cards`, `coverflow`, `strip`, `wide`, `polaroid`.
Repo: [omarchy-image-picker-styles](https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles). Customizer → Pickers. Open as usual:
Super+Shift+Ctrl+Space (themes), Super+Ctrl+Space (wallpapers).

**Slow picker?** Omarchy's thumbnail index grows on every theme change. Customizer → Pickers → "⚡ Cache thumbnails" and
"🧹 Clean up unused"; turn on autoCache to cache in the background after each theme change
([why](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-wallpaper.md#thumbnail-cache--why-the-pickers-were-slow)).

## Wallpaper tools in the Customizer

- **Recolor** — any picture into the current theme's palette (lutgen).
- **Dotify** — LED dot-matrix wallpapers and an Arch glyph generator.
- **Theme from wallpaper** — `just theme-from-wallpaper` / `>dynamic` in the launcher (matugen).
