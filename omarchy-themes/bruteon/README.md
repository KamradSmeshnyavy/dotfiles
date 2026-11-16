# bruteon-* themes

[🇷🇺 Русский](README.ru.md)

An Omarchy theme after [Bruteon](https://github.com/Darkkal44/Bruteon) by Darkkal44 — a neo-brutalism rice. Its repository
only has three screenshots so far, so everything is taken from them (colours sampled from the pictures); the code is own.

`bruteon-light` — warm paper: cream cards `#f5ebe6` on `#efe0d6`, a thick dark outline `#161110` and a hard shadow without
blur, pastel accents (peach, salmon, green, pink, lavender, blue). It is **one-colour** by default (syntax, the 16 terminal
colours and btop in shades of brown and peach); `bruteon-light-color` keeps the pastel rainbow of its terminal.

`bruteon-dark` (+ `-color`) is our own dark take in its spirit, the original has none: warm charcoal `#1d1816`, cards a shade
lighter, the outline and the hard shadow in light ink `#f3e6dc`, the same pastel tiles with dark text, a dusk wallpaper.

- fastfetch — like its own: «ARCH LINUX» and «HYPRLAND» pills, «icon key › value» rows, pastel pills at the bottom, no logo.
- Windows — a 3 px border in the outline colour and a hard 6 × 6 shadow (`decoration.shadow.sharp`), titlebars like on its
  screenshots: a bar in the card colour with a bold title and pink ✕ / green maximize tiles (hyprbars plugin,
  `just hypr-plugins`; double click maximizes).
- Wallpapers — drawn here: a soft sunset from a blue sky to peach and cream, like on its screenshots (`1-sunset`), or plain
  paper (`2-paper`).

```sh
python3 build.py          # all
python3 build.py dark     # only these
```
