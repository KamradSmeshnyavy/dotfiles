**English** · [Русский](Make-Your-Own-ru)

# Make your own

Everything is data or a small QML file — no need to fork a plugin.

## A bar skin

Customizer → Bar → Bar Tweaks until you like it → Bar Skin → "💾 Save the current skin…" → it lands in
`~/.config/omarchy/bar-skins/<name>.json` with ★. Or write the JSON by hand (schema: [docs](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-bar.md#skin-schema)).

## A lock design

`~/.config/omarchy/lock-designs/Mine.qml`:

```qml
import QtQuick
import "../plugins/kamradsmeshnyavy.lock/designs"

DesignBase {
  id: root
  field: pw                       // required: otherwise the stock screen is shown
  Wallpaper { anchors.fill: parent; host: root }
  Text { text: root.time; color: root.fg; font.family: root.font; font.pixelSize: 80 }
  PasswordField { id: pw; host: root; anchors.centerIn: parent }
}
```

Test without locking: `omarchy-shell lock previewDesign my:Mine.qml`.

## A launcher skin

A QML file extending `SkinBase.qml`, registered in `SkinConfig.qml`; `ThemePalette.qml` gives it the whole theme. See
[Writing a skin](https://github.com/KamradSmeshnyavy/omarchy-launcher-skins#writing-a-skin).

## A style

Customizer → Presets → Style → "Save current look as a style" → `~/.config/omarchy/customizer/styles/<id>.json`. A style
is a preset without theme / wallpaper plus `fonts` (a font profile) and a `look` block for panels.

## A preset

Customizer → Presets → save → `~/.config/omarchy/customizer/presets/<name>.json` (theme + style + wallpaper + the rest).
A preset may reference a style: `"style": "<id>"`.

## Animations and shaders

- `~/.config/omarchy/customizer/animations/*.lua` — Hyprland Lua (`hl.curve`, `hl.animation`); a file with the name of a
  bundled preset replaces it.
- `~/.config/omarchy/customizer/shaders/*.frag` — screen shaders; one using `time` gets `damage_tracking = 0`
  automatically.

## A theme

See [Themes and app theming](Themes-and-App-Theming#making-a-theme).
