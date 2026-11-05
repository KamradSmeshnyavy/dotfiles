# skhd

[🇷🇺 Русский](skhd.ru.md)

A global hotkey daemon for macOS, used together with yabai.

## Paths

- **In the repo:** `apps/skhd`
- **Linked to:** `~/.config/skhd` (macOS only)

## What differs from the defaults

1. **Navigation:** workspaces `lalt - 1…6` (resolving `SPACES` ids); windows `lalt - h/j/k/l`; by coordinates
   `alt-tab` / `shift-alt-tab`; first / last window `lalt - ;` (0x29) and `lalt - '` (0x27); toggle float
   `lalt - space` (grid `4:4:1:1:2:2`); fullscreen / zoom `shift-lalt-f` (zoom-fullscreen) and `lalt-f` (zoom-parent).
2. **Moving windows:** warp / shift `shift-lalt-h/j/k/l`; split orientation `shift-lalt-s`; to a workspace
   `shift-lalt-1…6` (and focus it); previous / next workspace `shift-lalt-p` / `shift-lalt-n`; mirror the space
   `shift-lalt-x` (X axis) / `shift-lalt-y` (Y axis).
3. **Stacks:** add to a stack in a direction `shift-ctrl-h/j/k/l`; next / previous in a stack `shift-ctrl-n` /
   `shift-ctrl-p`.
4. **Resize and gaps:** `ctrl-lalt-h/j/k/l` (100 px), balance `ctrl-lalt-e`, gaps on/off `ctrl-lalt-g`.
5. **Insertion:** the insertion point `shift-ctrl-lalt-h/j/k/l` and `s` (stack); open a new window with a split (via
   `cmd-n`): `lalt - s` (right), `lalt - v` (below).
6. **Displays:** cycle `lalt-ctrl-d`; focus 1–3 `lalt-ctrl-1/2/3`; move the window to the next / previous display
   `shift-lalt-ctrl-n/p`.
7. **Extras:** hide / show SketchyBar `shift-lalt-space`; hide every floating window of the workspace
   `lalt-shift-0x2A` (`hide-all-float.sh`).
