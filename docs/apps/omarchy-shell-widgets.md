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

Desktop widgets follow the rice too (`widgetStyle: style`): on Unit-3 a card is a NieR sheet (92 % background, 1 px line,
grid and corner brackets), on Cozytile, Rumda, surface and Glyph — the card of that rice's dashboard. Bruteon, yami,
Vitreus and DOT-MATRIX get it from their material (brutal, pixel, glass, own card). A card merged with the bar or
frame stays the style card, which knows how to draw the joint.

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

**Space** (after the Space style of [elifouts/Dotfiles](https://github.com/elifouts/Dotfiles), GPL-3.0): the dashboard is a visor (`DashSpace.qml` — corner brackets, the clock, cut-corner plates for the system, processor, memory, graphics, link and music with cell meters), Super+M is an onboard computer (`menus/MenuSpace.qml` — a ship in the centre and the sections as planets on a tilted orbit; wheel or `[` `]` turns it, the chosen planet flies in and unfolds into a HUD plate), the player is a NOW PLAYING plate (`players/PlayerSpace.qml`), the workspace overview is his own star map ported as it is (`voyage/`, `overviewStyle: voyage`: take off from the land, fly freely, land on planets; landing in another world recolours the desktop) or a 3D star map (`OverviewStarmap.qml`, `overviewStyle: starmap`, Qt Quick 3D): a galaxy whose core is your workspaces and whose outer belt holds uncharted worlds, and inside a system your windows are planets; route mode (h/l along the route, arrows show where a key leads) or free WASD flight, F switches. Labels decode through noise (`SpaceDecode.qml`, a copy of the bar's).

**Retro CRT** (after the Retro style of [elifouts/Dotfiles](https://github.com/elifouts/Dotfiles), GPL-3.0): the dashboard is his status screen over the whole screen (`DashCrt.qml` — the host name, QUICK KEYS, LIVE LOAD and SESSION cells, SYSTEM / TASKS / NOW PLAYING boxes; it switches on like a tube), the workspace overview lists every window as a table (`OverviewTable.qml`, `overviewStyle: table` — Enter goes there, `x` closes, 1–9 jump to a workspace), Super+M is «Главное меню ЭВМ» (`menus/MenuCrt.qml` — a numbered menu: a digit picks a line, 1–3 open network / Bluetooth / sound in the same frame, 4–7 toggle), the player is a NOW PLAYING box with a cell visualizer (`players/PlayerCrt.qml`). Shared pieces: `Crt{Pal,Type,Box,Button,Tube,Media}.qml` after his `Retro/common`.

**Modern** (after the Modern style of [elifouts/Dotfiles](https://github.com/elifouts/Dotfiles), GPL-3.0): bar pills grow into cards on hover or click (`ModernIsland.qml` — workspaces, now playing, calendar, Wi-Fi / Bluetooth / sound, session, updates, notifications; a hole in the glass keeps the pill itself visible), Super+M is the same island under the bar with Wi-Fi / Bluetooth / Sound / Session tabs (`settingsPanel: modern`), the dashboard is his Home over the whole screen (`DashModern.qml` — a 128 px clock, Now Playing, the month, System rings, Volume, Notifications, session buttons), the player is a glass card with a visualizer (`players/PlayerModern.qml`), the workspace overview puts the grid over the blurred wallpaper (`overviewStyle: modern`), and his boot animation plays once per login (`BootModern.qml`: rings, HYPRLAND, your hypr config typing itself; `bootIntro`, settings sheet → Shell; replay with `omarchy-shell widgets bootIntro`).

**Shared for every rice.** Under the player card (Super+Alt+M) there is a **timer and alarm** strip (`TimerStrip.qml` / `TimerState.qml`, state in `~/.local/state/omarchy/timer.json`, so it survives a shell restart): 5 / 10 / 25 / 45 min chips, a countdown with +5 and ✕; the alarm time changes with the wheel or clicks (hours / minutes) and has a switch. When it fires the player opens with a ringing bell and his alarm sound (after the Modern alarm of elifouts/Dotfiles); ✕ silences it. IPC: `omarchy-shell widgets timerStart 25`, `timerCancel`, `timerDismiss`, `alarmSet 07:30`, `alarmToggle`. **Power dial** (`powerStyle: dial`, Modern's default): five actions on a ring around the clock, pick by the mouse angle / wheel / arrows; logout, reboot and shutdown fire only on a 0.7 s hold. The launcher has a **Keybindings** page (`keybinds`, every binding with its keys, searchable, in the rice's skin). **Super+Alt+P / Super+Alt+Shift+P** — next / previous profile of the current rice. Switching rices runs under the Customizer's transition (frozen frame under a blur), and every rice gets a boot intro once per login (`bootIntro`).

**Terminal on the wallpaper** (`term`, after his `term` widget and `desk.sh`): the widget only reports where it stands; `omarchy-desk-term` (`scripts/bin`) keeps a real bash there in a transparent `kitten panel` on the background layer — click it and type. It restarts only when its place or size changes; a theme change only swaps the font and background over kitty's socket. On by default in the Retro CRT style, off in the others; `term` / `termAnchor` in the Customizer's Widgets tab. **Settings sheet → SCREEN** (themes with a tube): his CRT knobs and wallpaper filter for the current theme.

**Settings sheet skins** (`settingsSkin`: auto — by the rice): `space` — his Space settings (the bottom strip that unfolds), `crt` — his Retro SETUP (`sheet/SheetCrt.qml`): numbered pages on the left, 1–9 jump; CORE (rice, bar boxes / default / zen, text size and font for the whole Retro shell), COLORS (his tubes and schemes with accent swatches — colours change apart from the wallpaper, `omarchy-crt-colors`), SCREEN, PROFILES (the rice's profiles; the Customizer's Rices tab has one entry per rice). In the Retro style the wallpaper picker is his SCREENS (folders of his library, favorites, filtered preview). `modern` — his Modern settings (`sheet/SheetModern.qml`): a glass side panel with icon tabs; Profile (style, saved profiles of this rice only — his and yours, Save, right-click twice to delete — and his five bars as mini previews), Themes (Pywal and his schemes with 16 swatches — a swatch becomes the accent — and the wallpapers of his library by folder with their pywal colours; a click sets the wallpaper and recolours when the colours are Pywal, `omarchy-modern-colors`), then the Hyprland pages. In the Modern style the wallpaper picker is his carousel from the bottom with a full-screen preview (`ModernWalls.qml` of the image picker). In every skin the profiles page lists only the profiles of the current rice.

**Every rice has its own settings sheet** (`settingsSkin`: auto takes `partDefaults[rice].settingsSkin` in `Widgets.qml`; the file is `sheet/Sheet<Skin>.qml`). Besides Space, Vitreus (`vitreus`, his Settings: centred card, sections on the left), Retro CRT and Modern:
- `rumda` (`SheetRumda.qml`) — a sandy notebook: ruled paper with binder rings on the left and a caramel pill of round section tabs on the right.
- `yami` (`SheetYami.qml`) — `settings.conf` in a terminal: buffers `[1:core] 2:colors …`, `[x]` toggles, `██████▒▒▒` bars, a vim status line; lists open as a completion popup.
- `bruteon` (`SheetBrute.qml`) — a form on a board: pastel sticker tabs, sticker section titles, ON / OFF tiles that drop onto their hard shadow.
- `cozytile` (`SheetCozy.qml`) — a folder with S-sided tabs like his bar; the card flips sideways when the section changes.
- `surface` (`SheetSurface.qml`) — the hub column at the right edge: section tiles on the home view, a section slides in with a `‹ back` crumb (Esc / Backspace go back).
- `unit3` (`SheetUnit3.qml`) — the YoRHa system menu: sections as stripes on the left, a Description frame on the right for the row under the cursor.
- `dotmatrix` (`SheetDots.qml`) — an instrument service menu: a dot display with the section name, LED section buttons, dot bars; colours only from `dotmatrix/Palette.qml`.
- `glyph` (`SheetGlyph.qml`) — Nothing OS settings: a dot heading that types itself, capsule tabs, round toggles with a red dot.

The shared core of these skins: `SkinWindow.qml` (window, keys, open / close), `SkPage.qml` (pages), `SkToggle` / `SkSlider` / `SkPick` / `SkTitle` (controls drawn from the skin's tokens in the `Sk` singleton), `SheetCore.qml` (data).

**Keyboard in every skin:**
- Tab / Shift+Tab and `[` / `]` switch sections; 1–9 jump to one.
- Arrows or `hjkl` move between rows; ← / → on a slider change it by one step.
- Enter or Space press the row.
- `/` searches fonts; `?` shows the keys.
- Esc closes a list, then goes back, then closes the sheet.
- Letters also work in the Russian layout (they are read by scan code).

**Choosing from many** (Rice, Variant, Bar, Super+M, Dashboard, …): Enter or a click opens a dropdown with every option and a ✓ on the current one. ↑ / ↓, PgUp / PgDn and a first letter move the selection. Only Enter or a click applies; Esc applies nothing. Rows with a few short options stay a row of buttons.

**Accent for every rice** (COLORS → Accent; Space, Retro CRT and Modern keep their own colour pickers):
- Two rows of candidates: the 16 colours of the current theme, and the colours of the current wallpaper (Iris clusters, cached in `~/.cache/omarchy/rice-accent`).
- A swatch runs `omarchy-rice-accent set '#rrggbb'` (`omarchy-rices/scripts`). It builds `~/.config/omarchy/themes/<theme>-accent`: a copy of the variant's theme, with its pictures and wallpapers linked, where only `accent` changes. `cursor` and `hyprland_active_border` change too if they equalled the accent.
- The old accent is also swapped in the theme's app files, but only when no other colour in `colors.toml` shares it. Monochrome themes often reuse the text colour as their accent, so for them only `colors.toml` changes.
- The wallpaper stays.
- `reset` goes back to the variant's theme and removes the copy.
- *Save as* stores `accentState`, and the profile rebuilds the accent when applied.

Rice menus (`settingsPanel` bruteon / yami / cozytile / rumda / glassring / instrument / space / crt, `menus/` on the shared
`menus/SectionBody.qml` and `MenuData.qml`) share the same section contents. **Wi-Fi**: a saved network connects with
its NetworkManager profile, no password asked; a new one asks for the password in a field right under its row, and a
failed attempt deletes the profile nmcli created, so a wrong password is not remembered. The status line shows
"connecting…" or nmcli's error. `›` on a saved network (or a click on the connected one) opens its card: address,
gateway, DNS in use, connect / disconnect, auto-connect, **DNS** — presets (router, Cloudflare, Google, Quad9, AdGuard,
Yandex) or your own addresses (IPv4 and IPv6 mixed), applied at once with `nmcli dev reapply` without reconnecting —
show password, new password, forget (second press confirms). Below the list: saved networks out of range, a hidden
network (name, then password) and rescan. **Bluetooth**: a new device is paired, trusted and connected in one press,
battery level in the row; `›` — connect, trusted (auto-connect), forget. **Audio**: volume, microphone and its level,
outputs and inputs. Esc steps back (field → card → section → menu). Unit-3 (NieR) and surface Hub keep their own
lists but also connect saved networks without a password.

Keyboard (`KeyNav.qml`, every menu and dashboard): a target inside a scrolling list is scrolled into view, the
selection ring hides instead of drawing over the panel when the wheel takes the target away, and after the list is
rebuilt the selection stays on the row in the same place.

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
