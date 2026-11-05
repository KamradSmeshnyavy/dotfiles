# Ghidra

[🇷🇺 Русский](ghidra.ru.md)

A theme for the Ghidra reverse-engineering framework that follows the Omarchy theme.

## Paths

- **In the repo:** `apps/ghidra`
- **Generated:** `omarchy-themes/scripts/omarchy-ghidra-theme <theme dir> <output .theme>` builds a `.theme` from the
  theme's `colors.toml` and the current fonts (`fonts.json` / fontconfig); `omarchy-app-themes` runs it on every theme
  or font change. Import it once in Ghidra's theme settings.

## What it sets

- FlatLaf system colours on a dark base (`Flat Dark`, `useDarkDefaults = true`).
- Listing, decompiler (variable highlight, search, paths, source/sink nodes), bookmarks, overview, ByteViewer and Code
  Compare colours, the current line, P-code graph colours.
- `font.standard` / `font.monospaced` from the font profile.
