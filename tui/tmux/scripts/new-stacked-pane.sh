#!/bin/sh

PWD_IN_PANE="$(tmux display-message -p '#{pane_current_path}')"
STACK_MODE="$(tmux show-options -wqv @zj_stack_mode)"

if [ "$STACK_MODE" != "on" ]; then
    tmux set-option -w @zj_prev_layout "$(tmux display-message -p '#{window_layout}')"
    tmux set-option -w @zj_stack_mode on
fi

tmux split-window -v -c "$PWD_IN_PANE"
tmux set-option -w main-pane-height 75%
tmux select-layout main-horizontal
tmux display-message "New stacked pane"
