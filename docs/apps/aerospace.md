# AeroSpace

[🇷🇺 Русский](aerospace.ru.md)

A tiling window manager for macOS, used instead of yabai (macOS is the secondary platform).

## Paths

- **In the repo:** `apps/aerospace`
- **Linked to:** `~/.config/aerospace` (macOS only)

## What differs from the defaults

1. **Integrations**
   - Sends `aerospace_workspace_change` to SketchyBar on a workspace change, with `FOCUSED_WORKSPACE`.
   - Works with `borders` (frames around active and inactive windows): active `#ffe1e3e4`, inactive `#ff494d64`,
     width 5.0.
   - Toggles gaps through SketchyBar.

2. **Layout and behaviour**
   - Starts at login.
   - Gaps: 10 between windows, 8 from the screen edges.
   - Default layout `tiles`, orientation `auto` (horizontal on wide screens, vertical on tall ones).
   - Container normalisation (`flatten-containers`, `opposite-orientation-for-nested-containers`).
   - Accordion padding 300.
   - The mouse moves to the focused monitor (`move-mouse monitor-lazy-center`).

3. **Window rules**
   - Floating rules for native macOS apps, browsers, settings, etc.
   - Rules carried over from yabai: Finder, Safari, Camera, Discord, Mail, Obsidian, Terminal, Ghidra, VLC and others
     open floating, as do Finder and Safari settings dialogs and save dialogs.
   - Workspace assignments: `zen` → 2, `telegram`, `spotify` → 3, `code` → 4, `ghidra` → 5.

4. **Key bindings (Qwerty preset)**
   - Focus: `alt-h/j/k/l`, `alt-tab` / `alt-shift-tab` (DFS), `alt-semicolon` / `alt-quote` — the outermost windows.
   - Move windows: `alt-shift-h/j/k/l`.
   - Workspaces: `alt-1…6` to go, `alt-shift-1…6` to move the window there.
   - Float and fullscreen: `alt-space` (tiling/floating), `alt-shift-f` and `alt-f` (fullscreen).
   - Resize: `alt-ctrl-h/j/k/l`, `alt-ctrl-e` (balance sizes).
   - Monitors: `alt-ctrl-d` (next monitor), `alt-ctrl-1…3` (focus), `alt-ctrl-shift-n/p` (move to another monitor).
   - **Service mode** (`alt-shift-semicolon`): reset the layout (`r`), toggle float (`f`), close all but the current
     (`backspace`), back (`esc`).
