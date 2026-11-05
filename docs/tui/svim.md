# SketchyVim (svim)

[🇷🇺 Русский](svim.ru.md)

Modal Vim editing in macOS text fields (macOS only).

## Paths

- **In the repo:** `tui/svim`
- **Linked to:** set up system-wide (not in the automatic links).

## What differs from the defaults

- The `svim.sh` hook sends the current `MODE` and `CMDLINE` to SketchyBar to show the Vim mode in the bar.
- `blacklist` disables svim in apps with their own Vim keys — terminals (kitty, Alacritty, WezTerm), editors (MacVim,
  Neovide, Code) and browsers (Chrome, Arc, Firefox).
