# SketchyBar

[🇷🇺 Русский](sketchybar.ru.md)

A highly customisable status bar for macOS, written in Lua (via sketchybar-package). The config is a submodule.

## Paths

- **In the repo:** `apps/sketchybar`
- **Linked to:** `~/.config/sketchybar` (macOS only)

## What differs from the defaults

1. **Architecture:** rewritten in Lua with the `sketchybar-package` wrapper; a Rust background process
   (`stats_provider`) watches CPU, RAM and the network (`en0`).
2. **Look:**
   - theme `catppuccin_mocha` (also `catppuccin_latte`, `rose_pine`, `tokyo_night`, …);
   - preset `gnix` (a floating bar, radius 10, gap 5, border 3, height 32); `compact` sticks to the edges without
     borders;
   - icons and text in `Maple Mono NF CN`.
3. **Modules:** logo and the active app's menus; spaces named with uppercase Greek letters (`greek_uppercase`); the
   front app; calendar, battery (icon), Wi-Fi (with `FlClash` as the proxy app), volume; chat, `brew` updates; a
   `toggle_stats` button, keyboard layout, network / CPU / memory stats; **music** (via `media-control`, 1280 px album
   art, titles cut to 15 characters, a default cover).
4. **Window manager:** `WINDOW_MANAGER = "macos_native"` by default, while AeroSpace sends `aerospace_workspace_change`
   and `aerospace_toggle_gaps` events to the bar.
