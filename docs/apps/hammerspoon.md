# Hammerspoon

[🇷🇺 Русский](hammerspoon.ru.md)

A macOS automation tool, used here for Vim-style mouse control from the keyboard.

## Paths

- **In the repo:** `apps/hammerspoon`
- **Linked to:** `~/.hammerspoon` (set up by hand; not in `install.conf.yaml`).

## What differs from the defaults

A script for moving the cursor and clicking from the keyboard. The modal mode is triggered by keys from the Karabiner
config (`s`, `m`, `spacebar`); an overlay shows `-- NORMAL --` or `-- VISUAL MODE --`.

1. **Mouse movement:** `h j k l` (small step), `Shift + h/j/k/l` (big step); left/right arrows move horizontally.
2. **Scrolling:** smooth `u/d` (up/down) and `w/b` (left/right); big `Shift + u/d/w/b`; medium `Ctrl + u/d`; up/down
   arrows scroll; the direction respects `naturalScroll`.
3. **Clicks:** `a` — right click; `i` — triple left click (select a paragraph / line).
4. **Visual mode (drag and drop):** `v` holds the left button to start a selection/drag; `Shift + v` triple-clicks and
   then holds; `y` in visual mode releases the button and sends `cmd+c`.
