# Hyprland

[🇷🇺 Русский](hyprland.ru.md)

The dynamic tiling Wayland compositor, configured in **Lua** on top of Omarchy 4 (Quattro) defaults.

## Paths

- **In the repo:** `apps/hyprland`
- **Linked to:** `~/.config/hypr` (Dotbot, `install/install.conf.yaml`)

## How the config is built

`hyprland.lua` loads Omarchy's bootstrap and defaults (`default.hypr.omarchy`), then my overrides, then Omarchy's
toggles. Package updates improve the defaults without rewriting these files.

| File | What it holds |
|---|---|
| `hyprland.lua` | load order: Omarchy defaults → `hypr.monitors`, `input`, `bindings`, `windows`, `looknfeel`, `autostart`, `env` → toggles |
| `bindings.lua` | my binds (`o.bind`) and re-binds of keys Omarchy 4.5 took (`o.rebind`, otherwise both actions fire) |
| `input.lua` | keyboard, touchpad, 4-finger gestures (3 fingers are `drag_3fg`) |
| `looknfeel.lua` | gaps 2/4, border 2, `dwindle`, rounding 10, inactive opacity 0.9 + dim, blur (xray, popups, special), shadow |
| `windows.lua` | window and layer rules (blur under the bar, dashboard, OSD, notifications) |
| `autostart.lua` | KDE Connect, cliphist for text and images, the cursor |
| `env.lua` | Wayland environment (Firefox, GTK portal) |
| `monitors.lua` | monitors |
| `animations/` | animation presets (HyDE, ML4W, end-4, …) — the Customizer applies them |
| `scripts/` | `smart_focus.sh`, `focus_float_toggle.sh`, `kbptr-wrapper.sh` |

**Apply changes with `hyprctl eval`** (or `hyprctl reload`). With the Lua config `hyprctl keyword` and plain
`hyprctl dispatch` do nothing — dispatchers go through `hyprctl eval 'hl.dsp…'`.

## Key bindings (my own)

| Keys | Action |
|---|---|
| `Super + Return` | terminal in the current directory |
| `Super + Shift + F` / `Shift + B` | Nautilus / browser |
| `Super + Shift + T` | **Customizer** (`omarchy-shell shell toggle kamradsmeshnyavy.customizer`) |
| `Super + M` | DOT-MATRIX settings panel (Wi-Fi, BT, sound, DND, night light) |
| `` Super + ` `` | workspace overview |
| `Super + Alt + D` | dashboard |
| `Super + Esc` | power menu from the right edge |
| `Super + Alt + C` / `+ Shift` | screen shader on/off / next (CRT, TFT) |
| `Super + Alt + O` / `+ Shift` | next / previous transparency preset |
| `Super + Alt + U` / `+ Shift` | next / previous blur preset |
| `Super + Alt + W` | toggle the shell layout |
| `Super + Alt + E` / `Super + Shift + V` | emoji / clipboard |
| `Super + H/J/K/L` | smart focus (moves between floating and tiled sensibly) |
| `Super + Shift + H/J/K/L` | swap window |
| `Super + Ctrl + H/J/K/L` | resize; `Super + R` — resize submap |
| `Super + S` / `Super + .` / `Super + Shift + .` | toggle split / consume / expel |
| `Super + D` | scratchpad |
| `Super + Tab` | smart float toggle |
| `Super + ;` / `Super + Ctrl + ;` | toggle workspace layout / keybindings cheatsheet |
| `Pause`, `Scroll_Lock`, `Break` | play/pause, next, previous (work on the lock screen too) |
| `F19` | switch keyboard layout (sent by kanata; `all`, because mouseless sits in between) |
| 4 fingers ← → / ↑ / ↓ | workspaces / overview / dashboard |

Everything else is Omarchy's stock bindings (`Super + Ctrl + ;` lists all of them).

## Look

Animations, transparency, blur and the window-corner rule are set from the Customizer and survive a reload: it writes
`~/.local/state/omarchy-customizer/animations.lua` and `~/.local/state/hypr/{opacity,blur,screen-shader}` and re-applies
them after every `hyprctl reload`. For a reload without a flash of defaults, `looknfeel.lua` loads the Customizer hook
`hypr/customizer.lua`.
