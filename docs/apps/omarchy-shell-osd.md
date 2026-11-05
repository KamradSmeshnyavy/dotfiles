# omarchy-shell OSD and notifications: at the screen edge

[🇷🇺 Русский](omarchy-shell-osd.ru.md)

> The plugins are separate repos and submodules: [omarchy-edge-osd](https://github.com/KamradSmeshnyavy/omarchy-edge-osd), [omarchy-drawer-notifications](https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications).

A clone of the stock `omarchy.osd` (`omarchy plugin clone omarchy.osd`): `apps/omarchy-shell/plugins/kamradsmeshnyavy.osd/` →
`~/.config/omarchy/plugins/kamradsmeshnyavy.osd`. Changes in `Osd.qml` are marked `// edge:`; compare with stock —
`diff -u $OMARCHY_PATH/shell/plugins/osd/Osd.qml apps/omarchy-shell/plugins/kamradsmeshnyavy.osd/Osd.qml`.

An OSD with a scale (volume, brightness, microphone — whatever calls `omarchy osd -p …`) in the `edge` style is a
vertical slider sliding out of the screen edge (`EdgeOsd.qml`, idea from caelestia, written from scratch). The window
sits inside the reserved zones, so with the `frame` bar skin it grows right out of the frame, and the concave corners at
the top and bottom flow into it. The colour is the bar's and the frame's; with a transparent bar — the theme's popup
colour. Messages without a scale and the media OSD keep the stock card. The OSD never takes clicks. The `dotmatrix`
style is a 16-LED hardware meter at the edge.

Settings: Customizer → Windows → **OSD and notifications** or `~/.config/omarchy/osd.json`:

| Key | Default | |
|---|---|---|
| `osdStyle` | `edge` | `edge`, `dotmatrix` or `stock` (the stock card at the bottom) |
| `osdSide` | `right` | `right` or `left` |

The look comes from `BarStyle.qml`, as for the dashboard: `osdFollowBar` (`true`), `osdAttach` (`auto` / `attached` /
`floating`), your own `osdBackground` / `osdAlpha` / `osdRadius`. Also: `osdAlign` (`center` / `top` / `bottom` along the
edge), `osdSize` (`compact` / `normal` / `large`), `osdShowValue`, `osdTimeout` (ms, `-1` — as in stock).

Back to the stock OSD entirely: `omarchy plugin enable omarchy.osd`.

## Notifications

A clone of `omarchy.notifications` (`apps/omarchy-shell/plugins/kamradsmeshnyavy.notifications/`, changes marked
`// drawer:` in `Service.qml` and `components/NotificationCard.qml`). In the `drawer` style the toasts sit in one
backdrop of the bar colour in the top right corner: the window sits inside the bar and the frame
(`ExclusionMode.Normal`), the concave top-left corner flows into the bar, the bottom-right one into the right edge /
frame, the height follows the number of cards smoothly, the cards inside have no border. The daemon, DND, history and
IPC are stock.

| Key (`~/.config/omarchy/notify-style.json`) | Default | |
|---|---|---|
| `notifyStyle` | `drawer` | `drawer` or `stock` |
| `notifyFollowBar`, `notifyAttach` | `true`, `auto` | as for the dashboard: stick to a solid bar, otherwise a floating card |
| `notifyCorner` | `top-right` | `top-right` / `top-left` / `top-center` (centred — flows on both sides) |
| `notifyWidth`, `notifyMax` | `380`, `0` | toast width; how many are visible at once (`0` — all, newest on top) |
| `notifyCards` | `flat` | `flat` — no border inside the backdrop, `bordered` — stock, `dotmatrix` — DOT-MATRIX hardware cards with a Glyph sweep |
| `notifyBackground`, `notifyAlpha`, `notifyRadius` | | your own look when not following the bar |

## Sounds

`omarchy-sound <event>` (`omarchy-themes/scripts/omarchy-sound` → `~/.local/bin`) plays a sound via `pw-play`. Event
names follow the freedesktop sound theme spec; the file is looked up in the current theme's `apps/sounds/`, then in
`omarchy-themes/app-defaults/sounds/`, then in `/usr/share/sounds/freedesktop/stereo`. A theme with its own sounds
ships, for example, `apps/sounds/message-new-instant.oga`.

| Event | Where from |
|---|---|
| `message-new-instant` / `dialog-warning` | a toast / a critical toast (the notifications clone; silent under DND) |
| `audio-volume-change` | the volume OSD (no more than once per 80 ms) |
| `service-login` | hook `post-boot.d/sound-login` |
| `battery-low` (→ `dialog-warning`) | hook `battery-low.d/sound-battery-low` |

Customizer → Windows → **OSD and notifications**: "Sounds: on" and "Sounds: volume"
(`~/.config/omarchy/sounds.json`: `sounds`, `soundVolume`). The Customizer also has tactile sound packs and Hyprland
window/workspace sounds.

Back to the stock notifications entirely: `omarchy plugin enable omarchy.notifications`. With "Do not disturb" on, only
critical `notify-send` without `-a` and `omarchy-action` reach the screen.
