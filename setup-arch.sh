#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ ! -d ".dotbot" ]]; then
  git submodule update --init --recursive
else
  git submodule update --init --recursive .dotbot
fi

PYTHON_BIN="${PYTHON_BIN:-}"
if [[ -z "$PYTHON_BIN" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN=python3
  elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN=python
  else
    echo "Python not found. Install python and retry." >&2
    exit 1
  fi
fi

DOTBOT="$ROOT/.dotbot/bin/dotbot"
if [[ ! -x "$DOTBOT" ]]; then
  echo "dotbot not found at $DOTBOT" >&2
  exit 1
fi

"$PYTHON_BIN" "$DOTBOT" -d "$ROOT" -c install.conf.yaml

# VS Code (Linux) config links
VSCODE_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code/User"
if [[ -d "$ROOT/apps/vscode" ]]; then
  mkdir -p "$VSCODE_USER_DIR"
  if [[ -f "$ROOT/apps/vscode/settings.json" ]]; then
    ln -sfn "$ROOT/apps/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
  fi
  if [[ -f "$ROOT/apps/vscode/keybindings.json" ]]; then
    ln -sfn "$ROOT/apps/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
  fi
  if [[ -d "$ROOT/apps/vscode/snippets" ]]; then
    ln -sfn "$ROOT/apps/vscode/snippets" "$VSCODE_USER_DIR/snippets"
  fi
fi

echo "Arch dotfiles setup complete."
