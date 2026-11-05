# Yabai

[🇷🇺 Русский](yabai.ru.md)

A tiling window manager for macOS (used before / alongside AeroSpace).

## Paths

- **In the repo:** `apps/yabai`
- **Linked to:** `~/.config/yabai` (macOS only)

## What differs from the defaults

1. **Scripting addition:** `sudo yabai --load-sa`, reloaded automatically when the Dock restarts (`dock_did_restart`).
2. **Layout:** `bsp`; space reserved for an external bar (SketchyBar) `all:40:0`; active windows opaque (1.0), inactive
   0.8, no opacity animation; shadows only for floating windows; no window animations; gaps 10 between windows, 8 from
   the edges.
3. **Mouse:** mouse follows focus, focus follows mouse (`autoraise`); modifier `cmd` — left button moves, right resizes,
   dropping a window swaps it; new windows open as the second child.
4. **Rules:** many apps are not tiled (`manage=off`): AmneziaVPN, Ghidra, Terminal, LuLu, Calculator, System Settings,
   VLC, Finder and Safari dialogs, Activity Monitor and more. Workspace assignments: Zen → 2, Telegram and Spotify → 3,
   Code → 4, Ghidra → 5.
