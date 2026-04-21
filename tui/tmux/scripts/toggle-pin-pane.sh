#!/bin/sh

CURRENT_PANE="$(tmux display-message -p '#{pane_id}')"
PINNED_PANE="$(tmux show-options -gqv @pinned_pane_id)"

if [ "$PINNED_PANE" = "$CURRENT_PANE" ]; then
    tmux set-option -gu @pinned_pane_id
    tmux display-message "Pane unpinned"
    exit 0
fi

tmux set-option -g @pinned_pane_id "$CURRENT_PANE"
tmux display-message "Pane pinned: $CURRENT_PANE"
