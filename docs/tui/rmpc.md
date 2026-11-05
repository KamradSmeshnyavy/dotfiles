# Rmpc

[🇷🇺 Русский](rmpc.ru.md)

A modern terminal client for MPD, written in Rust.

## Paths

- **In the repo:** `tui/rmpc`
- **Linked to:** `~/.config/rmpc`

## What differs from the defaults

- **Connection:** local MPD (`127.0.0.1:6600`); lyrics from `~/Music/CloudMusic`.
- **Look:** 30 FPS cap, mouse support, album art found automatically, centred, up to 1200×1200 (no http/https art).
- **Colours follow the Omarchy theme:** `themes/omarchy.ron` is a theme slot — a gitignored symlink that `omarchy-app-themes` points at the current theme (see `omarchy-themes/APP-THEMING.md`).
- **Cava built in:** 80 FPS, sensitivity 100, low cutoff 50 Hz, reads `/tmp/mpd.fifo`; noise reduction 77, monstercat
  and waves off.
- **Controls:** volume step 5 %, config hot reload.
