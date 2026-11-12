# omarchy-shell launcher commands (`>…`)

[🇷🇺 Русский](omarchy-shell-launcher-commands.ru.md)

The launcher is the `kamradsmeshnyavy.menu` plugin (`apps/omarchy-shell/plugins/kamradsmeshnyavy.menu/`). A search
starting with `>` switches it into command mode (idea from caelestia, written from scratch, `Commands.js`). Command rows
go into the same list as ordinary items, so they look native in every launcher skin.

| Input | What it shows |
|---|---|
| `>` | every command with a description |
| `>th` | commands whose name starts with `th` |
| `>theme` + Enter | completes to `>theme ` and shows the arguments |
| `>theme rose` | arguments containing `rose` |

| Command | Arguments | Does |
|---|---|---|
| `>theme` | Omarchy themes (own and stock) | `omarchy-theme-set` |
| `>dynamic` | `tonal-spot` `vibrant` `expressive` `fruit-salad` `monochrome` `light` | a theme from the wallpaper (`omarchy-wallpaper-theme`; only if it is in `PATH`) |
| `>wall` | next / choose… | `omarchy-theme-bg-next` / `omarchy-theme-bg-switcher` |
| `>skin` | bar skins: ★ own ones and presets | `customizer.sh apply bar-skins` |
| `>dash` | — | the widgets dashboard |
| `>dnd` | — | "Do not disturb" |
| `>shader` | — | screen shader (crt-toggle) |
| `>custom` | — | the Customizer |
| `>ocr` | — | text from a screen region (`omarchy-capture-text`) |
| `>qr` | — | decode a QR code from a screen region (`omarchy-capture-qr`, also Super+Alt+Print) |
| `>curtain` | — | stream curtain: windows hidden from screen sharing (`omarchy-curtain`, Super+Ctrl+Alt+S) |
| `>reading` | — | reading mode |
| `>lock` | — | `omarchy-system-lock` |
| `>power` | — | the power menu (widgets) |

`>skin`, `>shader`, `>custom` need the `kamradsmeshnyavy.customizer` plugin, `>dash` and `>power` —
`kamradsmeshnyavy.widgets`; without them these commands are hidden (so `Commands.js` can be published with
`just publish-launcher`). Theme and skin lists are read once per menu opening, at the first `>`. Captions follow the
Customizer language. A new command is an entry in `catalog()` in `Commands.js`: `name`, `icon`, `desc`, and either
`action` or `args()`.

## Quick modes (`= : @ ! ;`)

The first character of the search switches the launcher into a quick mode (`Modes.js`; ideas from Vitreus and
glyph-rice, written from scratch). Rows are ordinary launcher rows, so they work in every skin.

| Input | Mode | Enter |
|---|---|---|
| `=2^10`, `=5 km to mi`, `=100 usd to eur` | calculator, units and currencies (`qalc`) | copy the result |
| `:fire`, `:k cat`, `:s arrow` | emoji, kaomoji (`:k`), symbols (`:s` — arrows, math, currency, box drawing, Greek…) | copy |
| `@`, `@fire` | open windows (title / class) | focus the window |
| `!g …`, `!yt …`, `!gh …`, `!aw …` | web search; bangs: `g` `d` `yt` `gh` `w` `aw` `aur` `pkg` `r` `so` `mdn` `tr` `m` `ya`; anything else — DuckDuckGo | open in the browser |
| `;`, `;http` | clipboard history (`cliphist`) | put it back into the clipboard |

Emoji and symbols come from the Unicode database bundled with Python (`scripts/gen-charms.py` → `charms.json`): single
code points with English names, no ZWJ sequences, flags or skin tones. Kaomoji are our own list with English and
Russian tags. Needs `qalc`, `cliphist`, `wl-copy`.
