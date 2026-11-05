**English** · [Русский](Lock-Screen-ru)

# Lock screen

**23 designs** plus one per style for the Omarchy lock screen. Repo: [omarchy-lock-designs](https://github.com/KamradSmeshnyavy/omarchy-lock-designs).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-lock-designs --enable
omarchy restart shell
```

**Authentication is untouched:** password, PAM and fingerprint are the stock `omarchy.lock` service, only the view is
swapped. If a design fails to load or doesn't provide a password field within 0.5 s, the stock screen is shown — you
can never be locked out by a broken design.

Designs: classic, zen, dock, island, split, sheet, card, cinema, poster, editorial, analog, flip, ring, calendar,
terminal, neon, system, music, aurora, rain, constellation, dotmatrix, and style designs (flat, glass, fluent, paper,
neon, neumorph, brutal, retro).

Choose in Customizer → **Lock** (previews in the current theme's colours; `p` shows it live without locking), or by
hand: `echo '{"design": "flip"}' > ~/.config/omarchy/lock-design.json`. Preview from a terminal:
`omarchy-shell lock previewDesign flip`.

Lock Tweaks: 24-hour clock, seconds, date, wallpaper blur and dimming, reduce motion, greeting, avatar.

Emergency exit if something breaks while locked: a TTY (Ctrl+Alt+F3) → `omarchy plugin enable omarchy.lock` or
`loginctl unlock-session`. Your own design: [Make your own](Make-Your-Own#a-lock-design). Reference:
[docs](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-lock.md).
