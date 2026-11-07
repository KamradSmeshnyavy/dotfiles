# DOT-MATRIX style (dot-matrix)

[🇷🇺 Русский](omarchy-shell-dotmatrix.ru.md)

The Nothing OS look, ported from [poligle/Nihil-Shell](https://github.com/poligle/Nihil-Shell) (MIT) into my own
omarchy-shell plugins. It is a style, not a theme: it works on any Omarchy theme.

## Where things live

| Part | Key | File |
|---|---|---|
| Bar | skin `dotmatrix` (roles `dotmatrix.*`), layout `dotmatrix`, `wsLabelStyle: leds` | `~/.config/omarchy/bar-skin.json` |
| Tray, Wi-Fi, BT, sound, display, agents in the bar | panels `kamradsmeshnyavy.{tray,network,bluetooth,audio,monitor,agents}` | `shell.json` `.bar.layout` |
| Widgets, dashboard | `widgetStyle`, `dashStyle` = `dotmatrix` | `~/.config/omarchy/widgets.json` |
| Settings panel | Super+M, IPC `widgets toggleSettings` / `widgets openSettingsSection wifi\|bt\|audio` | — |
| OSD | `osdStyle: dotmatrix` | `~/.config/omarchy/osd.json` |
| Notifications | `notifyCards: dotmatrix` | `~/.config/omarchy/notify-style.json` |
| Lock screen | design `dotmatrix` | `~/.config/omarchy/lock-design.json` |
| Launcher | skin `dotmatrix` | `~/.config/omarchy/extensions/menu-skin.json` |
| Glyph, Dotify, sounds | `kamradsmeshnyavy.customizer` | `glyph.json`, `dotify.json`, `sounds.json` |

## Palette

Colours and fonts come from `dotmatrix/Palette.qml` — a singleton (`qmldir`), an identical copy in the widgets, osd,
notifications, bar, menu, lock and customizer plugins and in the six DOT-MATRIX panels. Change all copies together
(check: `md5sum */dotmatrix/Palette.qml`).

- `~/.config/omarchy/dotmatrix.json` `{"palette": "theme"}` (default) — roles from the current theme: `bg`/`fg`/`muted`
  from `Commons.Color`, `signal` = `accent`, `danger` = `urgent`; a theme switch applies at once.
- `{"palette": "mono"}` — the original `#000000` / `#f2f2f2` / `#d71921` on any theme.
- The switch — Customizer → Desktop → Widgets → "DOT-MATRIX palette".
- Next to it, "DOT-MATRIX colours": every role (`dotmatrixBg`, `dotmatrixFg`, `dotmatrixDim`, `dotmatrixMuted`,
  `dotmatrixLine`, `dotmatrixSurface`, `dotmatrixLit`, `dotmatrixSignal`, `dotmatrixDanger` in `dotmatrix.json`) can be
  a shell role, a key of the theme's `colors.toml` (`red`, `blue`, …) or hex. `default` is the automatic colour. `lit` —
  lit LEDs, sliders, active buttons (defaults to the text colour).
- In configs colours are written as roles `dotmatrix.bg`, `dotmatrix.fg`, `dotmatrix.line`, `dotmatrix.signal`,
  `dotmatrix.danger` — BarSkin, BarStyle, the bar preview and Glyph understand them.
- The Doto, Space Grotesk and Space Mono fonts (OFL) live in `kamradsmeshnyavy.customizer/fonts` and are linked into
  `~/.local/share/fonts/dotmatrix`; without them DOT-MATRIX components use the Omarchy font.

Drawers (dashboard, settings panel, OSD) take their fill from BarStyle — the bar colour. The seam with the frame is
drawn only when a drawer is attached to the bar (`*Attach`); otherwise it is a separate card with a closed outline.

## Tray and the Wi-Fi / Bluetooth / sound menus

Features come from Omarchy instead of being rewritten. The stock bar widgets are cloned (`omarchy plugin clone`) into
`apps/omarchy-shell/plugins/kamradsmeshnyavy.{tray,network,bluetooth,audio,monitor,agents}`; each panel is its own repo
`omarchy-dotmatrix-<name>` (a submodule). Changes are marked `// dotmatrix:`: colours and fonts from the panel's own
palette copy (`import "dotmatrix"`), the card via `Palette.restyleCard`.
The logic (`Model.js`, `omarchy-*` scripts) is stock: after an Omarchy update new versions are carried over with a diff
against `/usr/share/omarchy/shell/plugins/{bar/widgets,panels/*}`. IPC targets stay stock (`omarchy.network`,
`omarchy.audio`…), so Omarchy's binds (Super+Alt+A etc.) open the DOT-MATRIX panels.

- Tray: left click — activate, right click — the app menu with submenus, middle click — secondary action, wheel —
  scroll. Widget options: `collapse` (false — every icon visible, "⋯" opens the pin/hide manager; true — the stock
  drawer), `monochrome` (grey icons, colour on hover).
- Settings panel (Super+M): the expanded Wi-Fi / BT / sound sections (`widgets/dotmatrix/{Wifi,Bt,Audio}Section.qml`)
  mirror the Omarchy panels: connection details, speed (LED oscilloscope), ping, band, DNS, networks with password /
  802.1X / "forget", QR and speed test; pairing, connecting, "forget" and sending audio to a BT device; outputs and
  inputs, per-app volume. Sections use the clones' `Model.js`; the ⚙ button opens the panel at the bar icon.
  A new 802.1X network (here and in the Wi-Fi panel) also asks for the RADIUS server domain: the profile trusts only
  a system-CA-signed server matching it (`802-1x.system-ca-certs` + `domain-suffix-match`).

## Bar widgets in the Customizer

Customizer → Bar → "Bar widgets": every widget of the current layout by section, then "Not on the bar" and "Widget
options". h / l — move earlier / later (at the edge — into the next section, via `omarchy-shell shell
moveBarWidget`), ⏎ or x — remove from the bar / bring back. A removed widget with its settings and place is kept in
`~/.config/omarchy/customizer/bar-hidden.json`; stock ones are added via `putBarWidget`. A stock widget that has a
clone is not shown in "Not on the bar": enabling it would remove the clone. Changes go to the live `shell.json`; to
save the layout as your own — "Bar layout" → "Save".

## Fonts: DotMatrix Dot, DotMatrix Mono, DotMatrix Pixel and profiles

The generators live in `kamradsmeshnyavy.customizer/scripts/` and run via `uv run --with fonttools`. All of them are
modified OFL fonts, so they carry their own names (the sources' Reserved Font Names).

- **DotMatrix Dot** — Doto with Cyrillic and dotted ligatures (`fonts/DotMatrixDot.ttf`, `dotmatrix-dot.py`, in git).
  - Letters are assembled from Doto's dots together with their variations, so weight (`wght` 100–900) and roundness
    (`ROND`) work for Cyrillic too.
  - The ligatures `== === != !== -> <- => ::` are drawn with dots of the same grid.
  - Palette: `fontDot` = DotMatrix Dot → Doto → the Omarchy font.
- **DotMatrix Mono** (`dotmatrix-mono.py`) — the official Geist Mono with its ligatures (set `ss11`) also wired to
  `calt`, so they are on everywhere by default.
- **DotMatrix Pixel** (`dotmatrix-pixel.py`) — Terminess Nerd Font (Terminus).
  - Russian lowercase: "в д" from Terminus's official `alt/dv1` variant (by default Terminus has Bulgarian forms:
    "в" = small "B", "д" = "g"), "и й" built from "И" with a diagonal (they were "u ŭ").
  - Italic shifts pixel rows and stays inside the cell: the terminal no longer clips letters.
  - Pixel ligatures: `!= == === -> <- => <= >= -- :: // || ++ >> <<`.
  - The edits are made both in outlines and in the embedded 12–32 px bitmaps: at those sizes FreeType uses the bitmap.
    Ghostty at 12 pt with scale 2 is 32 px.
  - Terminus sources are downloaded from SourceForge (sha256 checked) into `~/.cache/dotmatrix-fonts`.
- **DotMatrix Board** (Mono and Sans, `dotmatrix-board.py`) — "dots everywhere" for the `dots-all-test-a…f` profiles.
  While choosing, six dot variants are built (`BOARD_VARIANTS` in `omarchy-font-profile`): families
  "DotMatrix Board A…F", A/B/C — round 65/72/80 % of the step, D/E/F — square (LCD) with the same sizes.
  - Source — [Matrix Sans / Matrix Mono](https://github.com/FriedOrange/MatrixSans) (FriedOrange, OFL 1.1, no Reserved
    Font Name): a 5×7 grid with lowercase and full Cyrillic. The release is downloaded into `~/.cache/dotmatrix-fonts`.
  - The Screen variant is used: each dot there is a separate square on a 100-unit grid. The generator takes the dot
    centres and puts its own `.dot` there: `--dot` — diameter as a share of the step (0.72), `--shape round|square`.
    Bold — a bigger dot, italic — shifted rows.
  - Own additions: box drawing, blocks and Braille (btop graphs) on the same grid, lines of neighbouring cells join.
    Everything else missing from Matrix (₽, ≠, arrows) comes from DejaVu Sans Mono at 8 ppem. Nerd Font icons are solid,
    from Symbols Nerd Font.
  - Why not DotMatrix LED: its Terminus 8×16 grid has 16 dots per em and a dot of 96 % of the step. At 14 pt with
    scale 2 the step is 2.3 px, the gap 0.1 px, and the eye sees plain Terminus. On 5×7 a dot is 10 % of the size: at
    the same 37 px the step is 3.7 px.
  - It looks best when the step is a whole number of physical pixels: 15 pt (40 px, step 4) in terminals, 20 px in
    VS Code, 11.25 pt (30 px, step 3) in GTK. The `dots-all-test-*` profiles set these sizes; the previous ones come back
    when the profile changes.
- **DotMatrix Lumen** — the "ideal" variant for the `dots-all-lumen` profile, same generator: a round 74 % dot, Sans
  with half-dot tracking (`--track 50`), Mono with `-> <- => == !=` ligatures in dots (`--ligatures`; `--> === <=>`
  deliberately without ligatures). Titles — DotMatrix Dot: Doto's fine grid only looks good large.
- **Lumen family** — the `lumen` profile on the same files: the grid depends on text size. Everything small is 5×7
  (interface and panel titles in Lumen Sans, code and labels in Lumen Mono), DotMatrix Dot only for big text (clocks,
  OSD, lock, h1–h2 on sites). The palette does not enable `dotLayer` (the name is not `dots-all*`): Omarchy panel titles
  are 14 px, and Doto smears there.
- fontconfig trap: the profile's `fonts.conf` (like `omarchy font set`'s) puts the profile's mono font in front of any
  request fontconfig tagged as `monospace` — `fc-match "JetBrains Mono"` returns the profile font. For "dots everywhere"
  that is even handy, but render samples of other mono fonts with a separate `FONTCONFIG_FILE` without the user rules.
- DotMatrix Mono and DotMatrix Pixel are built into `~/.local/share/fonts/dotmatrix-build` (not in git):
  `just dotmatrix-fonts`. A profile that needs them builds them itself. Terminals take Nerd Font icons from
  Symbols Nerd Font (`ttf-nerd-fonts-symbols`).
- **System font profiles** — `omarchy-font-profile` (`scripts/bin`), Customizer → Desktop → Widgets → "System fonts".
  State — `~/.config/omarchy/fonts.json`. `omarchy-font-profile list` shows all 21 profiles.

  | Profile | Text | Code / terminal | In dots |
  |---|---|---|---|
  | `stock` | Maple Mono NF CN | Maple Mono NF CN | only DOT-MATRIX widgets (clocks, numbers) |
  | `nothing` | Geist | DotMatrix Mono | clocks, numbers; h1–h2 in the browser |
  | `dot` | Geist | DotMatrix Mono | + notification and panel titles, track, launcher query; h1–h3, th in the browser |
  | `pixel` | Geist | DotMatrix Pixel | like `dot`; `code`/`pre` in the browser in DotMatrix Pixel |

  What a profile applies:
  - kitty and ghostty — **not** in the repo's `kitty.conf` / `config`: those keep the stock font (Maple with its
    ss01–ss04) and include a generated `fonts.conf` last (`globinclude fonts.conf` / `config-file = ?fonts.conf`,
    gitignored). The script writes it whole: family, variants (`auto`; for `dot-accents` bold is DotMatrix Dot Black),
    in ghostty a reset `font-family = ""` / `font-feature = ""` and `calt`, grid sizes. Switching profiles leaves no
    git diff;
  - alacritty, foot and fontconfig `monospace` — like `omarchy font set`, but without restarting the shell;
  - `omarchy font set` (the Omarchy menu) edits `font_family` right in `kitty.conf` — the `hooks/font-set` hook runs
    `omarchy-font-profile mono <font>`: the line goes back to stock and the font goes to `fonts.conf`;
  - fontconfig `sans-serif` (`conf.d/60-dotmatrix-fonts.conf`), GTK (`gsettings`);
  - VS Code — the first family in `editor`/`terminal`/`debug`/`markdown` fontFamily and the sizes. `settings.json` is
    tracked by git, so these keys and `workbench.colorTheme` (Omarchy writes it on a theme change) are hidden by the
    clean filter `scripts/git-filters/vscode-local` (`.gitattributes`, set up by `just link`): the index gets the
    canonical values from `CANON` in the filter. `vscode-local-refresh` (after a profile and in the `theme-set` hook)
    refreshes the index stat cache, otherwise `git status` would list the file because its size changed;
  - browsers: page fonts in Helium and Firefox, Dark Reader, Stylus (usercss "DOT-MATRIX fonts"), Surfingkeys, the
    Firefox UI (`omarchy-firefox-chrome`: stock — the old one, others — DOT-MATRIX);
  - the DOT-MATRIX palette (`dotLayer`, `fontSans`, `fontMono`).
- Geist is downloaded automatically (the official vercel/geist-font release, cached in `~/.cache/dotmatrix-fonts`);
  Terminess Nerd Font is the `ttf-terminus-nerd` package.

## DOT-MATRIX style and preset

Three axes: theme — colours and wallpapers, **style** — shape, preset — theme + style + wallpapers.

Customizer → Presets → **Style** → DOT-MATRIX (`styles/dotmatrix.json` in the customizer) — DOT-MATRIX on top of the
current theme: window geometry, bar, lock screen, launcher, widgets, OSD, notifications, animations, transparency,
blur, sounds, Glyph and the `pixel` font profile, plus the "no gaps" toggle (windows flush against the frame, no
window borders; other styles turn it off). Built from the `nothing-hacking` preset. Sections merge into the current
settings (which widgets are visible is left alone). Flat, Glass, Fluent, Paper, Neon, Neumorph, Brutal, Retro and your
own styles are in the same list; what to apply is set by the toggles under it
(`~/.config/omarchy/customizer/style-apply.json`).

Customizer → Presets → DOT-MATRIX refers to the style (`"style": "dotmatrix"`) and also sets the `dotmatrix` theme and
wallpapers. Preset toggles — `~/.config/omarchy/customizer/preset-apply.json`. "Restore the previous setup" is a
backup taken before the first preset or style. "Reset window geometry" removes gaps/borders/shadow.

**Window corners** (Customizer → Presets → "Window corners", `~/.config/omarchy/customizer/windows.json`):
- a Hyprland window rule from `hypr/customizer.lua`, not `decoration.rounding`. So rounding works with Omarchy's
  "no gaps" toggle too (Super+Shift+Backspace);
- `float` (default) — floating and pop-up windows. Tiled ones stay square: the screen frame rounds the outer corners,
  the seams stay solid. `all` — every window; with zero gaps the seams show gaps. `off` — as in the config;
- radius 16 (less than the frame's 20 and the DOT-MATRIX cards' 18). Shape `rounding_power` 2.5 — a soft squircle;
- the change is applied with `hyprctl reload`: a window rule cannot be removed otherwise.

## Omarchy compatibility

- Lock, log out, reboot and shut down go through `omarchy-system-*`, night light through `omarchy-toggle-nightlight`
  (the hyprsunset daemon is not killed).
- The `omarchy-themes/dot-matrix` theme is only colours and wallpapers; Plymouth and SDDM live separately in
  `omarchy-themes/dot-matrix-boot` and are installed by hand.
