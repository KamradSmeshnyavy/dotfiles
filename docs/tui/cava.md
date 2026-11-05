# Cava

[🇷🇺 Русский](cava.ru.md)

A console audio spectrum visualizer (ALSA / PulseAudio / PipeWire / MPD).

## Paths

- **In the repo:** `tui/cava`
- **Linked to:** `~/.config/cava`

## What differs from the defaults

- Bars 1 wide with no spacing (`bar_width = 1`, `bar_spacing = 0`) — a continuous wave; upper cutoff 8000 Hz.
- `shaders/` and `themes/` folders for quick restyling.
- Ready for an MPD FIFO (`/tmp/mpd.fifo`) together with the MPD config.
- The desktop widgets plugin runs its own cava in raw mode for the visualizer and the dashboard.
