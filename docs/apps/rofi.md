# Rofi

[🇷🇺 Русский](rofi.ru.md)

A fast, scriptable window and app launcher. It is **no longer bound to Super+Space** — the launcher is the
`kamradsmeshnyavy.menu` shell plugin, and Super+Shift+T is the Customizer. Rofi stays for scripts.

## Paths

- **In the repo:** `apps/rofi`
- **Linked to:** `~/.config/rofi`

## What is left

- Layouts in `apps/rofi/themes/` (`Layout-*.rasi`) that import colours generated from the Omarchy theme
  (`~/.config/rofi/wallust/colors-rofi.rasi`).
- Menus for the scripts in `apps/hyprland/UserScripts/` (RofiBeats — online radio, RofiCalc — a calculator).
- The old combi menu (apps, files, windows, cliphist history, web search) still works with `rofi -show combi`.
