# Oh My Posh

[🇷🇺 Русский](ohmyposh.ru.md)

A fast, configurable prompt engine for any shell (used by Fish here).

## Paths

- **In the repo:** `shells/ohmyposh`
- **Linked to:** `~/.config/ohmyposh`

## What differs from the defaults

- **Layout:** right-aligned blocks (`alignment: right`), `diamond` segments with rounded ends.
- **One style:** every segment shares a dark blue background (`#29315A`) and differs only by text colour.
- **Segments:** user (`session`, red `#E64747`), path (`path`, green `#3EC669` with a folder icon), git (`git`, light
  blue `#43CCEA`, the default branch icon hidden).
- **Dev environments:** Python (yellow `#E4F34A`), Go (`#7FD5EA`), Node (green `#42E66C`), Ruby and Java (red `#E64747`).
  Version fetching is off for each (`fetch_version: false`) — a much faster, quieter prompt. Icons come from Nerd Fonts.
