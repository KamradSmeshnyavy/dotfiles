# Kitty

[🇷🇺 Русский](kitty.ru.md)

A fast GPU-accelerated terminal emulator — the main terminal here.

## Paths

- **In the repo:** `apps/kitty`
- **Linked to:** `~/.config/kitty`

## What differs from the defaults

### Fonts

- `kitty.conf` keeps the stock font: **Maple Mono NF CN** (bold/italic variants, `font_features +cv01 +ss02 +ss04
  +ss05 +zero` — e.g. a slashed zero), size 14.
- The system font profile (`omarchy-font-profile`) overrides family, variants and size in a generated
  `fonts.conf`, included last (`globinclude fonts.conf`) and ignored by git — switching fonts leaves no diff.

### Neovim integration (kitty-scrollback.nvim)

- `Alt + P` — open the whole scrollback in Neovim.
- `Super + Shift + P` — open only the output of the last command.
- `Ctrl + Shift + right click` — open the clicked command output in Neovim.

### Look and windows

- Background blur `background_blur 64`; opacity comes from the theme / Customizer transparency presets.
- Window decorations hidden (`hide_window_decorations titlebar-only`).
- Colours follow the Omarchy theme: `include ./themes/theme.conf` points at the current theme.
- `globinclude style.conf` — the Customizer style (window padding, cursor shape), written by `omarchy-app-themes`.

### System tweaks

- Remote control is allowed over a socket (`allow_remote_control socket-only`) for scripts and kitty-scrollback.
- macOS: Option works as Alt (`macos_option_as_alt`), the title bar matches the background.
