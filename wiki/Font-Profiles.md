**English** · [Русский](Font-Profiles-ru)

# Font profiles

`omarchy-font-profile` changes the type of the **whole system** in one go: terminals (kitty, ghostty, alacritty, foot),
fontconfig `monospace` / `sans-serif`, GTK, VS Code, page fonts in Firefox and Helium (plus Dark Reader, Stylus,
Surfingkeys and the Firefox UI), and the shell plugins' DOT-MATRIX palette.

```sh
omarchy-font-profile             # the current profile
omarchy-font-profile list        # every profile with a description
omarchy-font-profile nothing     # apply one
```

Or in the Customizer: Desktop → Widgets → **System fonts**. Styles set a profile too (DOT-MATRIX → `pixel`, Retro →
`retro`, Paper → the paper ones).

> The script and the DotMatrix fonts live in the full dotfiles (`scripts/bin/omarchy-font-profile`); with only the
> plugins installed the Customizer row is hidden.

## Profiles

| Profile | Text | Code / terminal | Idea |
|---|---|---|---|
| `stock` | Maple Mono NF CN | Maple Mono NF CN | as Omarchy; dots only in DOT-MATRIX widgets |
| `nothing` | Geist | DotMatrix Mono | like Nothing OS: dots only for clocks, numbers, big titles |
| `dot` | Geist | DotMatrix Mono | a dot layer on every big short text (bar, titles, launcher, lock, OSD, page headings) |
| `pixel` | Geist | DotMatrix Pixel | `dot` plus a pixel terminal with ligatures |
| `dot-accents` | Geist | DotMatrix Pixel | `pixel` plus dotted site headings and controls, bold terminal text and shell labels |
| `dots-all` | DotMatrix LED | DotMatrix LED | every character in dots |
| `lumen` | DotMatrix Lumen Sans | DotMatrix Lumen Mono | 5×7 dots for small text, DotMatrix Dot only for big text |
| `dots-all-lumen` | DotMatrix Lumen Sans | DotMatrix Lumen Mono | tuned "dots everywhere" with grid-aligned sizes |
| `dots-all-test-a…f` | DotMatrix Board A…F | DotMatrix Board A…F Mono | six dot shapes to compare (round / square, 65–80 %) |
| `paper-shell` / `paper-ui` / `paper-hand` / `paper-all` | Maple → Pangolin → Caveat | Maple → Monaspace Radon → Caveat | from "handwriting only in the shell" to "everything handwritten" |
| `retro` | Pixelify Sans | DotMatrix Pixel | pixel everything |
| `nothing-os-test`, `ndot-test` | NType 82 / Ndot 57 | Lettera Mono / Board Mono | tests with Nothing's own fonts (install them yourself; not shipped) |

## The DotMatrix fonts

Built from open (OFL) sources by scripts in the Customizer: **DotMatrix Dot** (Doto + Cyrillic + dotted ligatures),
**DotMatrix Mono** (Geist Mono with ligatures always on), **DotMatrix Pixel** (Terminus with fixed Cyrillic, in-cell
italics, pixel ligatures), **DotMatrix Board / Lumen** (Matrix Sans re-drawn with real round dots on a 5×7 grid).
A profile that needs them builds them on first use; to build by hand — `just dotmatrix-fonts`.

Dots look best when the dot step is a whole number of screen pixels, so the grid profiles set terminals to 15 pt, VS Code
to 20 px and GTK to 11.25 pt (at scale 2); the previous sizes come back when you leave the profile.

## Git stays clean

Terminal fonts go to generated, gitignored `fonts.conf` files that `kitty.conf` / the ghostty config include last; VS
Code font keys are hidden from git by a clean filter. Switching profiles never leaves diffs in the dotfiles repo.

Reference: [docs/apps/omarchy-shell-dotmatrix.md](https://github.com/KamradSmeshnyavy/dotfiles/blob/main/docs/apps/omarchy-shell-dotmatrix.md#fonts-dotmatrix-dot-dotmatrix-mono-dotmatrix-pixel-and-profiles).
