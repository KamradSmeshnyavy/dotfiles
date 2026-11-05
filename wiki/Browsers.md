**English** · [Русский](Browsers-ru)

# Browsers

Firefox and Helium (Chromium-based) follow the Omarchy theme and the font profile automatically.

| What | How |
|---|---|
| **Dark Reader** | its settings are written from the theme's colours (OLED-friendly dark pages save the most battery) |
| **Stylus** | user styles generated per theme, including "DOT-MATRIX fonts"; written at browser launch (Firefox — IndexedDB, Helium — over a CDP pipe) |
| **Surfingkeys** | its theme block follows the palette and the mono font |
| **Firefox UI** | a generated `userChrome.css`: the stock view or a DOT-MATRIX one, depending on the font profile |
| **Page fonts** | from the font profile |
| **Bookmarks** | `just bookmarks-sync` — a 3-way merge between Firefox, Helium and Chromium (`-n` dry run) |

If a browser is open while the theme changes, you get a "Restart" notification — the settings are written when it is
closed.

Flags: `apps/browser/chromium-flags.conf`, `helium-flags.conf` (overlay scrollbars, Wayland decorations). Reference:
[docs/apps/chromium.md](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/chromium.md) and
[BROWSER-THEMING](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/omarchy-themes/BROWSER-THEMING.md).
