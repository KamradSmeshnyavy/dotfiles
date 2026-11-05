# omarchy-shell desktop widgets

[🇷🇺 Русский](omarchy-shell-widgets.ru.md)

> The plugin is a separate repo and a submodule: [omarchy-desktop-widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets).

My own plugin `kamradsmeshnyavy.widgets` (`kind: service`): `apps/omarchy-shell/plugins/kamradsmeshnyavy.widgets/` →
`~/.config/omarchy/plugins/kamradsmeshnyavy.widgets`. Enable: `omarchy plugin enable kamradsmeshnyavy.widgets`
(after `omarchy-shell shell rescanPlugins`); QML changes need `omarchy restart shell`.

Windows sit on the Bottom layer: above the wallpaper and below windows, visible on an empty desktop. Clicks pass
through, except for the player buttons and the interactive cards (todo, quote, photo).

| Widget | What it shows | Data source |
|---|---|---|
| Clock | styles `big`, `stacked`, `terminal`, `minimal`, `dotmatrix`; date in the Customizer language | a `Timer` once a second |
| Now playing | cover, title, artist, progress, ⏮ ⏯ ⏭ (dot-matrix cover in the `dotmatrix` style) | MPRIS (`Quickshell.Services.Mpris`), the playing player or the first one |
| Visualizer | `bars`, `mirror`, `wave` (or LED dots) full width at the bottom edge | cava in raw mode (pipewire), runs only while music plays |
| System rings | CPU, RAM, temperature, battery (or 28-LED dials); red on overheat and ≤15 % | `/proc/stat`, `/proc/meminfo`, `/sys/class/thermal`, `/sys/class/power_supply` every 2 s |
| Network | default interface, ↓ / ↑ speed and a dotted oscilloscope | polled every 2 s |
| Todo | a list from `~/.config/omarchy/widgets-todo.json`; click the box — done, right click — delete, "+" — add (a zenity prompt: the desktop layer takes no keyboard) | the file |
| Quote | a quote of the day: built-in proverbs and sayings plus your lines from `~/.config/omarchy/widgets-quotes.txt` ("text — Author", one per line); click — next | changes once a day |
| Photo frame | a picture from `photoDir` changing every `photoInterval` minutes and on click; no folder — the current wallpaper. The frame follows the style (Paper — a polaroid with tape, Retro — a rim, Neon — a glow) | the folder |

cava and the `/proc` poll start once for all monitors; a disabled widget costs nothing. `desktopWidgets: false` turns
off every desktop widget (the layer is not even created).

## Dashboard

`Super+Alt+D` (`omarchy-shell widgets toggleDashboard`, also `openDashboard` / `closeDashboard`) — the panel "grows"
out from under the bar at the top edge of the focused screen (the idea is from caelestia, written from scratch):
concave corners at the top flow into the bar strip, the height grows from zero. With the `frame` or `hug` bar shape
and an opaque background it takes the bar's colour and corner radius; with transparent skins — the theme's popup colour.
Closes with Esc or a click outside (`HyprlandFocusGrab`).

Inside (`dashStyle: default`): the player (cover, time, buttons, cava visualizer), a month calendar (‹ › to page),
weather (open-meteo, no key: city — `weatherCity`, refreshed every 20 minutes and only while open), 2-minute CPU/RAM
graphs, temperature and battery. `dashStyle: dotmatrix` — a Doto clock, dot-matrix MPRIS cover, a 24×6 LED spectrum,
28-LED CPU/RAM/°C dials and an rx/tx LED oscilloscope. While the dashboard is open data is collected even if the
desktop widgets are off.

### Dashboard and power menu look

Customizer → Desktop → **Dashboard** (keys in `widgets.json`). The style is computed by `BarStyle.qml`:

| Key | Default | |
|---|---|---|
| `dashStyle` | `default` | `default` or `dotmatrix` |
| `dashFollowBar` | `true` | colour, transparency, border and radius as the bar; with a transparent bar — glass (0.72 under Hyprland blur, 0.92 without) |
| `dashAttach` | `auto` | `auto` — stick with concave corners only to a solid bar at the edge (`frame`, `hug`, `full`), otherwise a floating card with a gap and a shadow; `attached` / `floating` — forced |
| `dashBackground`, `dashAlpha`, `dashRadius`, `dashBorder` | `background`, `0.94`, `22`, `false` | your own look when `dashFollowBar: false` |
| `dashMedia`, `dashCalendar`, `dashWeather`, `dashStats` | `true` | blocks; the width adapts |
| `dashAnimation`, `dashDuration` | `grow`, `340` | `grow` / `slide` / `fade`, ms |

## Settings panel

`Super+M` (`omarchy-shell widgets toggleSettings`, `widgets openSettingsSection wifi|bt|audio`) — the DOT-MATRIX
hardware drawer at the right edge, growing out of the frame corner: 3×2 round tiles (Wi-Fi, Bluetooth, Audio, Mic, DND,
Night light), 24-segment LED sliders, expandable Wi-Fi/Bluetooth/Audio lists (details in
[omarchy-shell-dotmatrix.md](omarchy-shell-dotmatrix.md)), notification history, session actions with a two-click red
confirmation.

`edgeHover: true` adds screen-edge dwell hot zones that open the dashboard, the settings panel and the launcher.

## Power menu

`Super+Esc` (`omarchy-shell widgets togglePower`; it used to be the stock System menu — that one is still in the
launcher) — a column of buttons sliding out of the right edge / frame, the same colour as the dashboard. Items and
commands are as in the stock System menu: lock, suspend (unless `suspend-off` is set), hibernate (if
`omarchy-hibernation-available`), log out, reboot, shut down. The last three need a second press within 3 seconds (the
first one colours the button: "again"). Keys: `j`/`k` or ↑↓, Enter, `1`–`6`, Esc; a click outside closes it. Opening the
menu closes the dashboard and vice versa.

## Workspace overview and gestures

`` Super+` `` (`omarchy-shell widgets toggleOverview`) — a grid of workspaces (1…5, more if occupied) with wallpapers
and live window previews (`ScreencopyView`). Click a workspace — go there, a window — focus it; drag a window to another
workspace — move it there without leaving the current one. Keys: ←→↑↓ / `hjkl`, Enter, `1`–`9`, Esc; a click on empty
space closes it. Dispatchers go through `hyprctl eval`
(`hl.dsp.window.move({ workspace, follow = false, window = "address:0x…" })`) — with the Lua config a plain
`hyprctl dispatch` does nothing.

Touchpad gestures (`apps/hyprland/input.lua`) use four fingers, because three are taken by `drag_3fg`: sideways —
workspaces, up — overview, down — dashboard.

## Settings

Customizer (Super+Shift+T) → Desktop → **Widgets**: `h`/`l` change a value, `x` resets it. Written to
`~/.config/omarchy/widgets.json` (no file — defaults), the plugin picks it up at once.

| Key | Default | |
|---|---|---|
| `desktopWidgets` | `true` | `false` — no desktop widgets at all |
| `clock`, `media`, `visualizer`, `sysinfo`, `network`, `todo`, `quote`, `photo` | per widget | enable a widget |
| `widgetStyle` | `default` | `default` or `dotmatrix` |
| `clockStyle` | `big` | `big` `stacked` `terminal` `minimal` |
| `clockAnchor`, `mediaAnchor`, `sysinfoAnchor`, `networkAnchor`, `todoAnchor`, `quoteAnchor`, `photoAnchor` | per widget | `top-left` `top` `top-right` `left` `center` `right` `bottom-left` `bottom` `bottom-right` |
| `clock24`, `clockSeconds` | `true`, `false` | |
| `visualizerStyle` | `bars` | `bars` `mirror` `wave` |
| `visualizerBars`, `visualizerHeight`, `visualizerAlpha` | `48`, `140`, `0.45` | |
| `visualizerIdle` | `false` | draw without music too (cava then always runs) |
| `todoMax` | | how many todo lines to show |
| `photoDir`, `photoInterval` | `""`, minutes | photo folder (`~` expands) and change interval |
| `edgeMargin` | `56` | distance from the screen edges |
| `edgeHover` | `false` | screen-edge hot zones |
| `tint` | `accent` | a role (`accent` `foreground` `muted`), a `colors.toml` key or `#hex` |
| `locale` | `""` | date language; empty — `lang` from `customizer.json`, else the system one |
| `screens` | `all` | `all` or `primary` |
| `weatherCity` | `""` | city for the dashboard weather |
| `weatherUnits` | `celsius` | `celsius` or `fahrenheit` |

Colours come from the theme (`Commons.Color` and `colors.toml`) and change with it. The card look (frame, corners,
font) follows the current Customizer style through `BarStyle.qml` / `StyleCard.qml`.
