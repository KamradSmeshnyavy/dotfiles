# WezTerm

[🇷🇺 Русский](wezterm.ru.md)

A powerful cross-platform terminal with multiplexing. Not the main terminal any more (Kitty is), kept for macOS and
Windows.

## Paths

- **In the repo:** `apps/wezterm`
- **Linked to:** `~/.config/wezterm`

## What differs from the defaults

- **Colours and fonts:** the Catppuccin Mocha theme; fonts live in the `config.fonts` module, with `Maple Hand` as the
  fallback for UI elements such as window titles.
- **Performance:** the `WebGpu` front end with the `HighPerformance` profile, `animation_fps = 60`, `max_fps = 60`.
- **UI:**
  - the tab bar at the bottom (`tab_bar_at_bottom = true`), no scroll bar;
  - window padding top 12, bottom 7, left/right 3;
  - no close confirmation (`window_close_confirmation = 'NeverPrompt'`);
  - the `tabline` plugin styled like Catppuccin.
- **Cursor:** a blinking underline (`BlinkingUnderline`) with `EaseIn`/`EaseOut` animations, thickness 4.
- **Modules:** `appearance.lua`, `bindings.lua`, `domains.lua`, `fonts.lua`, `general.lua`, `launch.lua`.
- **Key bindings:**
  - `Ctrl + p` — command palette; `Super/Alt + p` — tab navigator
  - `Ctrl + w` (and `W`) — close the tab without confirmation
  - `Alt + a / d` — previous / next tab
  - `Super/Alt + \` — vertical split
  - the modifier (`Super` or `Alt`) adapts to the OS (macOS or Windows) via the `utils.platform` module.
