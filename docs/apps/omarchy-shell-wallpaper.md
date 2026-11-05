# Wallpapers and the theme switcher: transitions, picker styles, thumbnail cache

[🇷🇺 Русский](omarchy-shell-wallpaper.ru.md)

> The plugins are separate repos and submodules: [omarchy-wallpaper-fx](https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx) and [omarchy-image-picker-styles](https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles).

Two clones of first-party plugins, both set up in the Customizer (Super+Shift+T):

| Plugin | Clone of | Settings | Category |
|---|---|---|---|
| `kamradsmeshnyavy.background` | `omarchy.background` | `~/.config/omarchy/wallpaper-transition.json` | Wallpaper FX |
| `kamradsmeshnyavy.image-picker` | `omarchy.image-picker` | `~/.config/omarchy/image-picker.json` | Theme Switcher |

Both files are read live. Clone changes are marked `// fx:` and `// picker:`.

## Wallpaper transitions

The transition is drawn by a custom shader `shaders/transition.frag` (one for all effects, the number is `mode`) via
`TransitionEffect.qml`. After editing the shader: `just shaders-wallpaper` (qsb → `transition.frag.qsb`, both files are
in the repo).

Effects (my own implementations of ideas from swww and gl-transitions): `slant` (as in stock), `fade`, `wipe`, `wave`,
`grow`, `outer`, `diamond`, `clock`, `blinds`, `doors`, `mosaic`, `dissolve`, `pixelize`, `ripple`, `swirl`,
`crosszoom`, `slide`, `zoom`, `glitch`, `burn`, `waterdrop`, `hexagon`, `random`, `none`.

| Key | Default | |
|---|---|---|
| `type` | `slant` | effect |
| `duration` | `420` | ms |
| `easing` | `InOutCubic` | a Qt curve: InOutQuad, OutExpo, OutBack, OutBounce, Linear, … |
| `angle` | `0` | degrees for wipe / wave / slide |
| `origin` | `center` | where the circle and the drop start: center / cursor / random |
| `softness` | `0.02` | width of the soft edge |

`omarchy-shell background replay` replays the current effect (the theme's neighbouring wallpaper → the current one).
In the Customizer it is `p`.

## Theme switcher

One overlay for picking themes and wallpapers. Styles: `slices` (stock), `cards`, `coverflow`, `strip`, `wide`,
`polaroid`. On top of a style — `expandedWidth/Height`, `sliceWidth/Height`, `spacing`, `skew`, `cardRadius`, `dim`,
`selectedBorder`, `animMs`, `scrimAlpha`, `labels`; 0 / -1 means the style's or theme's value (the key is not stored).
`autoCache` — cache thumbnails after a theme change (`omarchy-themes/hooks/theme-set`).

## Thumbnail cache — why the pickers were slow

`omarchy-menu-images` keeps thumbnails in `~/.cache/omarchy/image-selector/` and an index `index.tsv` (path,
size:mtime, hash). The current theme's wallpapers live at the same path
`~/.local/state/omarchy/current/theme/backgrounds`, but are copied again with a new mtime on every theme change — the
index grows forever (it reached 56k lines and 9 GB of thumbnails). After a theme change the row cache misses, and for
every picture the index goes through `awk`: ~55 ms × 439 wallpapers ≈ 24 s.

In Customizer → Theme Switcher:
- **⚡ Cache thumbnails** — `omarchy-theme-switcher --print-rows` and `omarchy-menu-images --cache-only` for theme
  previews and the current theme's wallpapers (the same directories as `omarchy-theme-bg-switcher`: the row cache key
  is the md5 of the directory list);
- **🧹 Clean up unused** — keeps thumbnails of pictures that exist with the same signature and everything referenced by
  `*.rows`; deletes the rest and rewrites the index without duplicates. Asks for confirmation with the size first;
- **autoCache** — the same caching in the background after every theme change.
