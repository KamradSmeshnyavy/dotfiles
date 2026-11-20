# Vitreus rice (liquid style)

[🇷🇺 Русский](omarchy-shell-vitreus.ru.md)

A port of [natepayn3/Vitreus](https://github.com/natepayn3/Vitreus) (MIT; his shell is written in pleamar, everything
here is my own QML that copies its look and motion). One entry in Customizer → Rices; the profiles **Glass, Retro, UwU,
Cyber, Milkbox, Doodle, Paper, Proxy** are the `Liquid-*` presets (style `liquid`, a theme `vitreus-*` or
`dynamic-vitreus`, and a `base` in `~/.config/omarchy/style.json` that changes the shape: glass or plastic).

## Panels flow out of the bar ("drip")

The dashboard, the settings panel, the power menu, the launcher (`liquid` skin), the stock module panels (audio,
network…) and the OSD grow out of their bar button the way Vitreus's drawers do: one piece of glass with the bar,
widening first and then pouring down, 7 % narrower mid-way, with a wide neck that becomes the concave join. When it
lands it sags and wobbles a little, then the content fades in rising 12 px; on close the content goes first, the
shape pulls back into the bar and the bar's edge ripples.

- His springs (mass 1, stiffness / damping): drip 235/21, settings 120/13, sag 360/38, wobble 581/22.
  `Spring.qml`, `DripMotion.qml`, the drip geometry in `DrawerGeom.qml` (kamradsmeshnyavy.widgets; copies in the
  bar, OSD and launcher plugins).
- The ripple: the closing panel writes `$XDG_RUNTIME_DIR/omarchy-bar-ripple.json`, the bar's glass frame
  (`ScreenBorder.qml`) plays it in `shaders/liquidglass.frag` (`ripple`).
- **For any rice**: Customizer → Widgets → *How panels appear*: `auto` (as the style says — `appear` in
  `style.json`; `liquid` → drip), `drip`, `classic` (`~/.config/omarchy/panel-shadow.json` `panelAppear`).
- Retro and Cyber (square bases) have almost no neck, as in Vitreus.

## Joins

Anything at the bar or the frame is one piece with it (smooth union of the shapes, concave curve ≈ 22 px). A desktop
card closer than 64 px to the frame reaches for it (the gap closes by `1 − (gap − 14) / 50`, the rest is bridged by
the neck); two glass cards closer than 26 px merge into one piece of glass (`WidgetCard.qml`, `StyleCard.glassJoin3`).

## Parts

| Part | What | Where |
|---|---|---|
| OSD | a drop out of the right frame edge, 316 px plate: icon tile, pencil slider, percent in Space Grotesk 21/700 | `osdStyle: vitreus`, `kamradsmeshnyavy.osd/VitreusOsd.qml` |
| Player | 288 × 148 card: cover, visualizer bars, buttons, seek bar; floating — grip and pin | `mediaStyle: vitreus`, `VitMediaCard.qml` |
| Pulling the player out | from the dashboard: follows the pointer on a 415/24 spring, lifts, gets its own glass after 16 px; dropped outside the panel it stays there and settles | `Dashboard.qml` |
| Module panels | glass base: the stock card turns into liquid glass joined to the bar; a thin grip instead of the moulded tab (Retro keeps the tab) | `kamradsmeshnyavy.bar/PopDress.qml` |
| Clock, monitor | the big "2 / 42" clock and the CPU / memory / GPU rings | `clockStyle` / `sysinfoStyle: vitreus` |
| Colours | the settings panel (Super+Alt+I → COLORS) shows his theme cards: name, tagline, swatches; Glass (wallpaper colours) first | `sheet/Sheet.qml` |
| UwU | cat ears, whiskers, stars, hearts and paw prints on panels and desktop cards | `BaseDecor.qml` |

`dashStyle: vitreus` is the glass-tile dashboard (`DashGlass.qml`), `pencils` the pencil one (`DashVitreus.qml`);
the Vitreus profiles keep the default dashboard, which plays the part of his calendar drawer with the player.

## Wallpapers

Vitreus has none of its own; his demos use paintings by Ismail Inceoglu from Wallhaven. `omarchy-themes/rices/vitreus/build.py`
downloads them by id (`6oqzgq`, `dpwq6o`, `dp35yo`, `725zyy`, plus one more of his per profile) into
`vitreus/walls/` (not in git) and links them into each theme: `0-original.jpg` is the profile's own, the presets start
on it. Customizer → Dynamic → *find wallpapers on Wallhaven* searches the month's toplist, like his `vitreus-wallhaven`.
