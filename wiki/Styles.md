**English** · [Русский](Styles-ru)

# Styles

Three axes:

- **Theme** — colours and wallpapers (Omarchy themes).
- **Style** — the *form*: window geometry, bar skin, lock design, launcher skin, widget / OSD / notification look,
  animations, transparency, blur, sounds, Glyph, fonts.
- **Preset** — theme + style + wallpapers.

Any style works on any theme. Apply one in Customizer → Presets → **Style**. The toggles under the list choose which
parts a style applies (`~/.config/omarchy/customizer/style-apply.json`); "Restore the previous setup" rolls back.

| Style | What it looks like |
|---|---|
| **Flat** | clean, solid panels, no effects |
| **Glass** | translucent panels with blur |
| **Liquid Glass** | after [Vitreus](https://github.com/natepayn3/Vitreus): very clear panels under strong vivid blur, a light rim and a soft top highlight, the `liquid` bar skin, the dashboard flows out of the bar like a drop and springs into place |
| **Fluent** | Windows-11-like acrylic, soft corners |
| **Paper** | sheets of paper: torn edge, grain, a strip of tape in the accent colour, handwritten Caveat, a static paper-grain screen shader; light themes give white paper, dark ones kraft / slate |
| **Neon** | accent glow, the `neon` bar skin, a scanline shader |
| **Neumorph** | soft relief, the `soft` bar skin |
| **Brutal** | thick borders with hard shadows, the `brutal` bar skin |
| **Retro** | a 3D bevel (Windows 9x), the `bevel` bar skin, the pixel `retro` font profile |
| **Glyph** | after [glyph-rice](https://github.com/Nebelung-cloud/glyph-rice): Nothing OS on a floating left pill (`glyph-pill` skin, `glyph-left` layout with RunCat and a focus timer), the `glyph` home screen (dot-matrix clock, bento of round and square tiles), a deck from the bottom edge, edge-light OSD, perimeter Glyph lighting, the `glyph` wallpaper switcher (full-screen preview assembling from dots; dots / grey / colour wallpaper look) with the `dotwave` transition, the glyph-rice lock screen (`glyph` design), Quick settings on Super+M (`settingsPanel: quick`), the `nothing` font profile; preset **Glyph** on the `nothing-glyph-dark` theme (the glyph-rice palette) |
| **DOT-MATRIX** | the Nothing OS look: dot-matrix type, LED meters, hardware cards, windows flush against a bezel frame, the `pixel` font profile |

Panels of the widgets, OSD and notifications follow the style through `~/.config/omarchy/style.json` (shadows, animation
speed, material, corners, typeface).

## DOT-MATRIX in detail

DOT-MATRIX restyles everything at once: the bar (`dotmatrix` skin with LED workspaces), tray / Wi-Fi / Bluetooth /
sound / display / agents panels ([DOT-MATRIX panels](Widgets-OSD-Notifications#dot-matrix-panels)), the settings drawer
(`Super+M`), dashboard, OSD (16-LED meter), notifications (hardware toasts with a Glyph sweep), the lock screen and the
launcher. The palette follows your theme (`{"palette": "theme"}` in `~/.config/omarchy/dotmatrix.json`) or uses the
original black / white / red (`"mono"`); every role can be overridden in Customizer → Desktop → Widgets.

The **DOT-MATRIX preset** also switches to the `dotmatrix` theme and wallpapers.

Your own style: [Make your own](Make-Your-Own#a-style).
