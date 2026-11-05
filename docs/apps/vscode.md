# VS Code

[🇷🇺 Русский](vscode.ru.md)

Visual Studio Code configuration: fonts, theme, snippets, key bindings and settings.

## Paths

- **In the repo:** `apps/vscode`
- **Linked to:**
  - Linux: `~/.config/Code/User/` (settings.json, keybindings.json, snippets)
  - macOS: `~/Library/Application Support/Code/User/` (the same files)
  - `~/.config/vscode/markdown-preview-enhanced` (Markdown Preview Enhanced config)

## What differs from the defaults

1. **Theme and look**
   - The colour theme follows Omarchy (`omarchy-theme-set-vscode` writes `workbench.colorTheme` on every theme change).
   - File icons: `catppuccin noctis icons`; product icons: `fluent-icons`.
   - Custom colours for the cursor, indent guides and Markdown tokens (bold, link underline, list colour).
   - Custom CSS for the workbench (see the screenshots in `assets/vsc_*.webp`).

2. **Fonts and editor**
   - Editor font: **Maple Mono NF CN** with a long fallback stack, ligatures on, size 16. The font profile
     (`omarchy-font-profile`) swaps the first family and the sizes.
   - Relative line numbers, format on paste / save / type.
   - No minimap, no navigation controls; a block cursor with smooth blinking.

3. **Integrated terminal**
   - Default shell: `zsh` (macOS), `nu` (Windows); images in the terminal enabled; copy on selection.

4. **Key bindings (keybindings.json)** — Vim-like file operations in the Explorer (when no input is focused):
   `c` / `shift+c` — copy absolute / relative path, `x` — cut, `y` — copy, `p` / `v` — paste, `q` — focus the editor.

5. **Snippets and associations** — snippets for `c`, `java`, `json`, `jsonc`, `markdown`, `mdx`, `nushell`, `python`
   (`snippets/`); file associations (`*.copilotmd`, `{hexdiff}`, `*.png` and `*.pdf` open in the matching extensions).

## Git and local values

`settings.json` is tracked, but the font, size and colour-theme keys change on every font profile / theme switch. The
git clean filter `scripts/git-filters/vscode-local` (set up by `just link`, see `.gitattributes`) puts canonical values
into the index, so these switches leave no diff. To change those values in the repo, edit `CANON` in the filter.
