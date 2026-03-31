#!/usr/bin/env bash

set -euo pipefail

LOCK_STATE="$(tmux show-options -gqv @lock_mode || true)"

if [[ "$LOCK_STATE" == "on" ]]; then
  tmux set -gu @lock_mode
  tmux source-file "$XDG_CONFIG_HOME/tmux/tmux.binds.conf"
  tmux display-message "LOCK_MODE: OFF"
  exit 0
fi

tmux set -g @lock_mode on
tmux set -g prefix None

# Disable all global tmux keybinds (root table), then keep only unlock toggle.
tmux unbind-key -a -T root
tmux bind-key -n C-M-l run-shell "/bin/sh $XDG_CONFIG_HOME/tmux/scripts/toggle-lock-mode.sh"

tmux display-message "LOCK_MODE: ON (C-M-l to unlock)"
