# omarchy-shell bar: skins and layouts

[🇷🇺 Русский](omarchy-shell-bar.ru.md)

> The plugin is a separate repo and a submodule: [omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins).

The top bar is a clone of the stock `omarchy.bar` (`omarchy plugin clone omarchy.bar`) with a skin layer:
`apps/omarchy-shell/plugins/kamradsmeshnyavy.bar/` → `~/.config/omarchy/plugins/kamradsmeshnyavy.bar`.
The shell picks it via `bar.id` in `~/.config/omarchy/shell.json`; if the clone fails to load, the shell falls back to
the stock bar on its own.

Everything is set in the Customizer (Super+Shift+T), group **Bar**: **Bar Skin**, **Bar Layout**, **Bar Tweaks**,
**Bar widgets**.

## Where things live

| File | What it is |
|---|---|
| `~/.config/omarchy/bar-skin.json` | the active skin; the bar watches the file and changes live |
| `~/.config/omarchy/shell.json` `.bar` | position, widget sections, `transparent` (also live) |
| `kamradsmeshnyavy.bar/skins/*.json` | skin presets (24) |
| `~/.config/omarchy/bar-skins/*.json` → `apps/omarchy-shell/bar-skins/` | your own skins (★ in Bar Skin) |
| `~/.config/omarchy/bar-layouts/*.json` → `apps/omarchy-shell/bar-layouts/` | your own layouts (★ in Bar Layout) |
| `kamradsmeshnyavy.bar/layouts/*.json` | layout presets (`position`, `centerAnchor`, `layout`) |
| `kamradsmeshnyavy.bar/BarSkin.qml` | reading the skin, defaults, colour roles |
| `kamradsmeshnyavy.bar/SkinFrame.qml` | the shaped backdrop, input mask, exclusive zone |
| `kamradsmeshnyavy.bar/SkinIsland.qml` | islands under the sections |
| `kamradsmeshnyavy.customizer/BarMock.qml` | the bar mock-up in the Customizer preview |

## Skin schema

```json
{
  "shape": "floating",        // full floating pill islands notch underline hug frame
  "height": 30,               // 0 = stock height from shell.toml
  "gap": 6,                   // distance from the screen edge
  "margin": 10,               // left/right margins
  "width": 1.0,               // share of the width (floating/pill/notch)
  "radius": 12,
  "padding": -1,              // module padding from the backdrop edges; -1 = stock
  "islandGap": 6,             // island margins
  "background": "bar",        // colour: a role or #hex
  "backgroundAlpha": 0.85,    // -1 = alpha from the theme
  "gradient": "accent",       // second colour of a horizontal gradient (no key — no gradient)
  "border": "accent", "borderWidth": 1, "borderAlpha": 0.6,
  "text": "bar", "active": "bar",
  "shadow": true,
  "glow": false,              // a glow in the border colour instead of a shadow
  "autoHide": false,          // hide behind the edge, slide out on hover (reserves no space)
  "moduleStyle": "plain",     // plain pills hover — a backdrop under each module
  "moduleBackground": "foreground", "moduleAlpha": 0.08,
  "spacing": 0,               // gap between modules
  "font": "",                 // empty = system font
  "transparent": false,       // the stock transparent mode (written to shell.json)
  "note": "caption for the Customizer"
}
```

A colour is `bar` (the stock bar colour from the theme's `[bar]`), a shell role (`background`, `foreground`, `accent`,
`muted`, `urgent`), any key of the current theme's `colors.toml` (`red`, `cyan`, `lighter_background`, …) or `#rrggbb`.
Roles are recoloured with the theme.

Shapes: `full` — stock; `floating` — a strip with gaps; `pill` — floating with a half-height radius; `islands` — a
separate island under each section; `notch` — a notch at the edge; `underline` — a line along the edge; `hug` — a
full-width strip with concave corners under it (radius from `radius`, at least 8); the corners show on an empty desktop
and with large `gaps_out`, windows cover them. `frame` — a strip plus a frame in the bar colour along the other screen
edges (`frameWidth`, default 8) with rounded inner corners (`radius`, at least 8): the frame is drawn by
`ScreenBorder.qml` — a full-screen window above windows (Top layer, clicks pass through) and three invisible strips with
`exclusiveZone`, so windows stay inside. Compact and autoHide do not apply to `frame`. A vertical bar (left/right) only
supports `full`, `floating` and `frame`; anything else falls back to `floating` (`hug` — to `full`).

In Bar Tweaks: `h`/`l` or `−`/`+` (can be held), `x` — reset a setting to its default, `⏎` on a colour — a custom
colour, `i` — type a value (out of range / not in the list — not applied, with a warning under the line; the same from a
terminal: `customizer.sh tweak <key> set <value>`). Settings are grouped (Shape & size, Colours, Modules, Effects,
Workspaces, Compact): `[` / `]` — jump to a group, `/colour` — the whole group. Each line shows its default, `●` marks a
changed setting.

Blur under a translucent bar — a layer rule in `apps/hyprland/windows.lua` (`ignore_alpha = 0.2`).

## Workspaces

In this bar `omarchy.workspaces` is replaced by `SkinWorkspaces.qml` (layouts and `shell.json` stay the same).
Settings live in the same `bar-skin.json`; in the Customizer — the "Workspaces: …" lines in Bar Tweaks:

| Key | Default | What it does |
|---|---|---|
| `wsLabelStyle` | `omarchy` | labels: omarchy numbers circled circled-filled circled-sans circled-sans-filled parens fullwidth superscript roman roman-small kanji greek cyrillic braille dots squares diamonds stars triangles hearts hexagons bars leds none |
| `wsWindowIcons` | `false` | window icons inside a workspace |
| `wsIconStyle` | `color` | color mono tinted accent bubble faded glyph letter dots count |
| `wsMaxIcons` | `3` | icons per workspace, the rest — "+N" |
| `wsDedupe` | `true` | one app — one icon |
| `wsShown` | `5` | how many workspaces are always visible (occupied ones up to 10 — always) |
| `wsShowEmpty` | `true` | show empty ones |
| `wsActivePill` | `false` | an accent pill under the active one |
| `wsActiveColor` | per style | colour of the current workspace: a theme role or `#hex` (and of the pill) |

The mouse wheel over workspaces scrolls through them. Icons come from `.desktop` files by appId and load synchronously
(asynchronous themed icons used to crash the shell).

## Compact

The bar shrinks on a monitor where the condition holds and expands back on hover. Settings — the "Compact: …" lines in
Bar Tweaks, preset `compact-focus`:

| Key | Default | What it does |
|---|---|---|
| `compact` | `off` | `single` — one tiled window on the workspace (or a fullscreen one); `fullscreen` — only fullscreen/maximized; `always` |
| `compactHeight` | `22` | backdrop height in compact; `0` — unchanged. Widgets are not shrunk, they are centred |
| `compactModules` | `essentials` | `essentials` — menu, workspaces, clock, network, sound, power; `center` — only the centre; `minimal` — workspaces + clock; `all` |
| `compactShape` | `full` | shape in compact; `same` — as usual |
| `compactAlpha` | `-1` | background alpha in compact; `-1` — as usual |
| `compactReserve` | `keep` | `keep` — the space under the bar stays (windows don't jump, a strip remains under the thin bar); `shrink` — windows get the space |
| `compactExpandOnHover` | `true` | expand on hover and while a bar panel is open |

Floating windows are not counted for `single`. The Customizer mock-up shows the bar in its normal state.

## A new preset

- Skin: drop a JSON file into `skins/` of the `kamradsmeshnyavy.bar` plugin, it appears in Bar Skin at once.
- Your own skin: Bar Skin → "💾 Save the current skin…" — what is on the bar now (with Bar Tweaks edits) goes to
  `~/.config/omarchy/bar-skins/<name>.json` (in the dotfiles — `apps/omarchy-shell/bar-skins/`) and appears in the list
  with ★. To delete — `D` on your skin's line (with a confirmation, the file goes to the trash). `my-glass-islands` is
  the bar before the frame (glass islands, greek, compact). Or build it in Bar Tweaks and copy
  `~/.config/omarchy/bar-skin.json`.
- Layout: in Bar Layout the line "💾 Save the current one as a preset…" — goes to `~/.config/omarchy/bar-layouts/<name>.json`
  (in the dotfiles — `apps/omarchy-shell/bar-layouts/`) and appears with ★; `D` deletes (with a confirmation, to the trash).

## Updating from upstream

Clone changes in `Bar.qml` are marked `// skin:`. After an Omarchy update:

```sh
just bar-upstream-diff   # stock Bar.qml against the clone
```

If upstream changed a lot, it is easier to clone again and carry over the `// skin:` blocks. After QML edits —
`omarchy restart shell`: cloned plugins don't hot-reload.
