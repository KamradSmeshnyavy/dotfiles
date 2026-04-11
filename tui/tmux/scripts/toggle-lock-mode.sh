#!/usr/bin/env bash

set -euo pipefail

LOCK_STATE="$(tmux show-options -gqv @lock_mode || true)"

if [[ "$LOCK_STATE" == "on" ]]; then
  tmux set -gu @lock_mode
  tmux source-file "$XDG_CONFIG_HOME/tmux/tmux.conf"
  tmux display-message "LOCK_MODE: OFF"
  exit 0
fi

tmux set -g @lock_mode on
tmux set -g prefix None

# set -g mouse on
# set -g set-clipboard on
tmux bind -T copy-mode-vi v send-keys -X begin-selection
# bind -T copy-mode-vi y send-keys -X copy-pipe "pbcopy -i -selection clipboard"
tmux set -g mouse on
tmux set -g set-clipboard external
tmux bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe "pbcopy"

# Disable all global tmux keybinds (root table), then keep only unlock toggle.
tmux unbind-key -a -T root
tmux bind-key -n C-M-l run-shell "/bin/sh $XDG_CONFIG_HOME/tmux/scripts/toggle-lock-mode.sh"
# set -g status-right '#[fg=#282828,bg=#cc241d]LOCKED#[fg=#fabd2f,bg=default] %Y-%m-%d %H:%M '
tmux set -g status-right ""
tmux set -ga status-right "#[bg=#{@thm_bg},fg=#{@thm_maroon}]  #{pane_current_command} #[bg=#{@thm_bg},fg=#{@thm_maroon}]#LOCK_MODE #[bg=#1e2030,fg=#82aaff,nobold,nounderscore,noitalics] "
tmux display-message "LOCK_MODE: ON (C-M-l to unlock)"
