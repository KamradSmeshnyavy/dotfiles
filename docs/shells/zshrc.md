# Zsh (.zshrc)

[🇷🇺 Русский](zshrc.ru.md)

The Zsh config: completions, shortcuts, aliases and the look. Nushell is the main shell; Zsh is the fallback and the
macOS default.

## Paths

- **In the repo:** `shells/zshrc/.zshrc`
- **Linked to:** `~/.zshrc`

## What differs from the defaults

A big config (~24 KB) for a full developer environment.

### Plugins

- **Oh My Zsh** as the base.
- **zsh-autosuggestions** (from `/usr/share/zsh/...`): `Ctrl+E` — accept the whole suggestion, `Ctrl+W` — execute,
  `Ctrl+L` — accept word by word.
- Completions for `kubectl`, `aws_completer`, case-insensitive Tab completion (`zstyle ':completion:*' matcher-list`).
- `Ctrl+K` / `Ctrl+J` — history search, Vim style.
- Colours follow the Omarchy theme (`omarchy-zsh-colors` on every theme change).

### Prompt

Starship (see [starship.md](starship.md)); the old Powerlevel10k config is still in `cli/p10k`.

### Aliases

Modern (TUI / Rust) replacements for classic tools:
- `ping` → `gping` (ping with a graph), `cat` → `bat`, `la` → `tree`, `n` → `nnn`;
- `wifi` → `impala`, `btui` → `bluetui`;
- archives via `7zz` (`unzipall`, `peek`, `quickzip`);
- a large git set: `gc`, `gp`, `gst`, `gco`, `gdiff` and a pretty graph log `glog`;
- package managers: `buu` (`brew update && brew upgrade`).

### Environment

System paths (`/opt/homebrew/bin`, `/usr/local/bin`) and macOS- / Omarchy-specific variables, chosen by `is_macos()`.
