# Ghostty

[🇷🇺 Русский](ghostty.ru.md)

A fast cross-platform terminal with a native UI and GPU rendering — the second terminal here, mostly for shaders.

## Paths

- **In the repo:** `apps/ghostty` (`shaders/` and `cursors/` are submodules)
- **Linked to:** `~/.config/ghostty`

## What differs from the defaults

### Look and fonts

- `config` keeps the stock font: **Maple Mono NF CN**, size 12, with its ligature sets `ss01` (`!=`, `===`), `ss02`
  (`<=`, `>=`), `ss03` (`->`), `ss04` (`</>`) and `-calt`.
- The font profile (`omarchy-font-profile`) writes a gitignored `fonts.conf` (`config-file = ?fonts.conf`): it resets
  `font-family` / `font-feature` with an empty value and sets the profile's font, `calt` and sizes.
- Colours: `theme = theme.conf` — the current Omarchy theme. `config-file = ?style.conf` — the Customizer style.
- Custom shaders and cursor shaders (`shaders/`, `cursors/`, `my_shaders*/`), `custom-shader-animation = true`.

### Behaviour

- Clipboard read and write allowed, `copy-on-select = true`.
- The window state is remembered (`window-save-state = always`), no confirmation on close.
- `start-tmux.sh` — open the terminal straight into a tmux session.
