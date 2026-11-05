**English** · [Русский](Widgets-OSD-Notifications-ru)

# Widgets, OSD, notifications

## Desktop widgets

[omarchy-desktop-widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets) — one service plugin for the desktop layer and several overlays:

- **Widgets** under windows: clock (5 styles incl. dot-matrix), now playing, cava visualizer, system dials, network,
  todo, quote of the day, photo frame. Customizer → Desktop → Widgets shows them on a mini desktop and marks overlaps.
- **Dashboard** (`Super+Alt+D`) — grows out from under the bar: player, calendar, weather, CPU/RAM graphs; or the
  DOT-MATRIX LED dashboard.
- **Settings panel** (`Super+M`) — a DOT-MATRIX drawer with Wi-Fi, Bluetooth, sound, mic, DND, night light, LED sliders
  and notification history.
- **Power menu** (`Super+Esc`) — from the right edge; reboot / shut down need a second press.
- **Workspace overview** (`` Super+` ``) — live window previews; drag a window to another workspace.

Optional: `cava`, `zenity`. Gestures (4 fingers): up — overview, down — dashboard.

## Edge OSD

[omarchy-edge-osd](https://github.com/KamradSmeshnyavy/omarchy-edge-osd) — volume / brightness / mic as a slider sliding out of the screen edge, growing
out of the `frame` bar skin; or a DOT-MATRIX 16-LED meter. Customizer → Windows → OSD and notifications.

## Drawer notifications

[omarchy-drawer-notifications](https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications) — toasts in one drawer of the bar's colour in a
corner, or DOT-MATRIX hardware cards with a Glyph sweep; sounds per toast. The daemon, DND and history are stock.

## DOT-MATRIX panels

The stock bar panels redrawn in the DOT-MATRIX style — each its own plugin, same logic and binds as stock:
[Tray](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-tray) · [Wi-Fi](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-network) · [Bluetooth](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-bluetooth) ·
[Sound](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-audio) · [Display](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-monitor) · [Agents](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-agents).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-audio --enable   # asks which bar section
```

All of these follow the current style (`~/.config/omarchy/style.json`) and the theme. Reference:
[widgets](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-widgets.md), [OSD and notifications](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-osd.md),
[DOT-MATRIX](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-dotmatrix.md).
