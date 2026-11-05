# Git

[🇷🇺 Русский](git.ru.md)

## Paths

- **In the repo:** `tui/git`
- **Linked to:** `~/.config/git`

## What differs from the defaults

- A global `.gitignore` at `~/.config/git/.gitignore`.
- `delta` as the pager; `nvim` as `core.editor` and `merge.tool`; `zdiff3` conflict style.
- `git-lfs` set up.
- URL shortcuts: `gh:` → `git@github.com:`, `ghh:` → `https://github.com/`, `my:` → `git@github.com:KamradSmeshnyavy/`.
- Commits are signed with an SSH key.
- `safe.directory = *`, `push.autoSetupRemote = true`, default branch `main`.
- In the dotfiles repo itself `just link` also sets `core.hooksPath .githooks` (gitleaks pre-commit) and the
  `vscode-local` clean filter.
