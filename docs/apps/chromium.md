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

## Video translation (Voice Over Translation)

Yandex Browser-style voice-over for videos in Firefox: the
[Voice Over Translation](https://github.com/ilyhalight/voice-over-translation) extension, installed from
[AMO](https://addons.mozilla.org/firefox/addon/voice-over-translation/) (the official build linked from the
repo's README; it is preferred over the userscript, being reviewed, signed and auto-updated by Mozilla).
It uses the Yandex translation API and supports YouTube, VK, Twitch, Rutube, Coursera, Udemy, X and more.

- Installed by hand, like the other extensions — nothing in the repo.
- In the VOT menu on the player: target language Russian, original volume ~15–20 %.
- Allow audio and video autoplay for the sites you translate on (Settings → Privacy & Security → Permissions →
  Autoplay), otherwise the extension errors out.
- Videos longer than 4 hours are not translated (API limit). Video URLs are sent to Yandex.
