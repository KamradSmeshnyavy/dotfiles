# Omarchy Drawer Notifications

[🇷🇺 Русский](README.ru.md)

[Omarchy](https://omarchy.org) notifications (a clone of the stock `omarchy.notifications`) where the toasts
share one panel. With a solid bar glued to the edge — for example the `frame` skin of
[omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins) — the panel is glued to the bar and the
screen edge with concave corners; with a transparent or floating bar it is a floating card with a gap and a
shadow. Its height follows the number of toasts. The daemon, Do Not Disturb, history and IPC are stock.

## Install

```sh
git clone https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications ~/.config/omarchy/plugins/kamradsmeshnyavy.notifications
omarchy-shell shell rescanPlugins
omarchy plugin enable kamradsmeshnyavy.notifications   # back to stock: omarchy plugin enable omarchy.notifications
```

Blur under a glass panel (Hyprland Lua config):
`hl.layer_rule({ match = { namespace = "omarchy-notifications" }, blur = true, ignore_alpha = 0.2 })`.
A sound per toast, if `~/.local/bin/omarchy-sound` exists (from the author's dotfiles), is played on show.

## Settings

`~/.config/omarchy/notify-style.json`, re-read live. The
[Customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) edits it under Windows → Notifications.

```jsonc
{
  "notifyStyle": "drawer",      // drawer | stock
  "notifyCorner": "top-right",  // top-right | top-left | top-center
  "notifyWidth": 380,
  "notifyMax": 0,               // toasts visible at once; 0 — all (newest on top)
  "notifyCards": "flat",        // flat | bordered
  "notifyFollowBar": true,      // colour, alpha, border, radius as the bar
  "notifyAttach": "auto",       // auto | attached | floating
  "notifyBackground": "background", "notifyAlpha": 0.94, "notifyRadius": 18
}
```

Edits to the stock files are marked `// drawer:`. `BarStyle.qml` is shared with
[omarchy-desktop-widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets) and
[omarchy-edge-osd](https://github.com/KamradSmeshnyavy/omarchy-edge-osd).

## License

MIT (includes the stock Omarchy plugin it was cloned from).
