# MPD

[🇷🇺 Русский](mpd.ru.md)

Music Player Daemon — a music server controlled by clients (rmpc here).

## Paths

- **In the repo:** `tui/mpd`
- **Linked to:** `~/.config/mpd`

## What differs from the defaults

- **Folders:** music library `~/Music/CloudMusic`, playlists `~/.config/mpd/playlists`.
- **Network:** listens on `127.0.0.1:6600`.
- **Outputs:** CoreAudio with a software mixer (macOS); a FIFO `/tmp/mpd.fifo` (`44100:16:2`, no resampling, mmap)
  for visualizers — cava and rmpc read the spectrum from it.
