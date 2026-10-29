# Omarchy Edge OSD

[🇷🇺 Русский](README.ru.md)

The [Omarchy](https://omarchy.org) on-screen display (a clone of the stock `omarchy.osd`) where volume,
brightness and microphone levels are a vertical slider that slides out of the screen edge. With a solid bar
glued to the edge — for example the `frame` skin of
[omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins) — it grows out of the frame with
concave corners; otherwise it is a floating card with a gap and a shadow. Messages and media OSDs keep the
stock card. The OSD never takes clicks.

## Install

```sh
git clone https://github.com/KamradSmeshnyavy/omarchy-edge-osd ~/.config/omarchy/plugins/kamradsmeshnyavy.osd
omarchy-shell shell rescanPlugins
omarchy plugin enable kamradsmeshnyavy.osd        # back to stock: omarchy plugin enable omarchy.osd
```

Blur under a glass OSD (Hyprland Lua config):
`hl.layer_rule({ match = { namespace = "omarchy-osd" }, blur = true, ignore_alpha = 0.2 })`.

## Settings

`~/.config/omarchy/osd.json`, re-read live. The
[Customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) edits it under Windows → OSD.

```jsonc
{
  "osdStyle": "edge",       // edge | stock
  "osdSide": "right",       // right | left
  "osdAlign": "center",     // center | top | bottom — along the edge
  "osdSize": "normal",      // compact | normal | large
  "osdShowValue": true,     // the percentage above the slider
  "osdTimeout": -1,         // ms; -1 — as sent by `omarchy osd`
  "osdFollowBar": true,     // colour, alpha, border, radius as the bar
  "osdAttach": "auto",      // auto | attached | floating
  "osdBackground": "background", "osdAlpha": 0.94, "osdRadius": 18
}
```

Edits to the stock `Osd.qml` are marked `// edge:`. `BarStyle.qml` is shared with
[omarchy-desktop-widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets) and
[omarchy-drawer-notifications](https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications).

## License

MIT (includes the stock Omarchy plugin it was cloned from).
