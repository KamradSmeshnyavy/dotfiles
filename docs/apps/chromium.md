# Chromium / browsers

[🇷🇺 Русский](chromium.ru.md)

Browser configs (they used to live in `apps/chromium`, now in `apps/browser`).

## Paths

- **In the repo:** `apps/browser`
- **Linked file by file** (the `~/.config/chromium` directory is the browser profile — never link it whole):
  - `apps/browser/chromium-flags.conf` → `~/.config/chromium-flags.conf`
  - `apps/browser/configs/helium/helium-flags.conf` → `~/.config/helium-browser-flags.conf`
  - `apps/browser/configs/tridactyl` → `~/.config/tridactyl`

## What differs from the defaults

- Launch flags for Chromium / Helium (overlay scrollbars and more), extension settings (Dark Reader, Stylus,
  Surfingkeys, Vimium C).
- Firefox and Helium follow the Omarchy theme and the font profile: Dark Reader, Stylus, Surfingkeys and a generated
  Firefox `userChrome.css` — see `omarchy-themes/BROWSER-THEMING.md`.
- `bookmarks-sync` — a 3-way bookmark merge between Firefox and Helium.
