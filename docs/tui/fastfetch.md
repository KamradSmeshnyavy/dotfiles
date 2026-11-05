# Fastfetch

[🇷🇺 Русский](fastfetch.ru.md)

A fast system information tool.

## Paths

- **In the repo:** `tui/fastfetch`
- **Linked to:** `~/.config/fastfetch`

## What differs from the defaults

- **The whole `config.jsonc` is a theme slot:** `omarchy-app-themes` points it at the current theme's fastfetch config
  (or `omarchy-themes/app-defaults`), so the logo, frame and colours change with the theme.
- The default layout: a custom ASCII logo (`preset/*.txt`), `➜ ` as the key separator, a "SYSTEM INFORMATION" frame,
  icon labels (` OS`, ` DE`, ` PC`), a fixed key palette (system yellow, graphics green, hardware red, network/sound
  magenta) and a colour palette row at the bottom.
- Modules: OS, Kernel, Packages, Shell, DE/WM (with LM and theme), Terminal, Host, CPU, Disk, Memory, Swap, Uptime,
  Display, Sound, Wi-Fi, Local IP.
