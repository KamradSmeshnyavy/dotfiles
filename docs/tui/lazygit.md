# Lazygit

[🇷🇺 Русский](lazygit.ru.md)

The git TUI used day to day.

## Paths

- **In the repo:** `tui/lazygit`
- **Linked to:** `~/.config/lazygit`

## What differs from the defaults

- Nerd Fonts v3 and file icons.
- Diffs rendered by `delta --dark --paging=never`.
- Custom commands:
  - **Conventional Commits** — `<c-v>` opens a menu for the type (feat, fix, chore…), scope and message;
  - **Pull requests** — `<c-r>` runs `gh pr create --fill --web`;
  - **Tig** — `t` opens `tig` for the selected file's history.
- Copy to clipboard on `y`; `nvim` as the editor.
- **Colours follow the Omarchy theme:** `theme.yml` is a theme slot — a gitignored symlink that `omarchy-app-themes` points at the current theme (see `omarchy-themes/APP-THEMING.md`). Change colours inside the theme, not here.
