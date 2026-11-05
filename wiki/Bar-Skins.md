**English** · [Русский](Bar-Skins-ru)

# Bar skins

The top bar with **24 skins**, **10 layouts**, a compact mode and dozens of workspace styles. Repo:
[omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-bar-skins --enable
omarchy restart shell
```

## Pick a skin

Customizer → **Bar** → Bar Skin. The active skin is `~/.config/omarchy/bar-skin.json`; the bar watches the file and
changes live. Shapes: `full` (stock), `floating`, `pill`, `islands`, `notch`, `underline`, `hug` (concave corners),
`frame` (the bar plus a frame around the whole screen, windows sit inside). Skins: stock, floating, pill, islands,
capsules, glass, hover-glass, frame, hug, notch, underline, minimal, soft, brutal, bevel, neon, paper, dotmatrix,
solid-accent, window-icons, compact-focus, autohide and more.

## Tweak it

Bar Tweaks — 41 settings in groups (Shape & size, Colours, Modules, Effects, Workspaces, Compact): `h`/`l` change, `x`
resets, `i` types a value, each line shows its default. Colours can be a theme role (`accent`, `muted`…), any key of the
theme's `colors.toml` or `#hex` — roles recolour with the theme.

## Workspaces

Labels: numbers, circled, roman, kanji, greek, cyrillic, braille, dots, LEDs and more (`wsLabelStyle`); window icons
inside a workspace (`wsWindowIcons`, styles color / mono / tinted / glyph / letter / dots / count…); an accent pill under
the active one.

## Compact mode

The bar shrinks when one tiled window fills the workspace (or only for fullscreen, or always) and expands on hover —
the `compact-focus` preset.

## Layouts and bar widgets

Bar Layout — position (top / bottom / left / right) and which widgets go into each section; Bar widgets — move a widget
with `h` / `l`, remove it with `x`, bring it back from "Not on the bar". Save your own skin or layout with
"💾 Save…" (★ in the list).

Back to the stock bar: `omarchy plugin enable omarchy.bar`. Reference: [docs](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-bar.md).
