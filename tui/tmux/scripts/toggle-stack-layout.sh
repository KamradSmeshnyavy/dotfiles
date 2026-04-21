#!/bin/sh

STACK_MODE="$(tmux show-options -wqv @zj_stack_mode)"
CURRENT_LAYOUT="$(tmux display-message -p '#{window_layout}')"

if [ "$STACK_MODE" = "on" ]; then
    PREV_LAYOUT="$(tmux show-options -wqv @zj_prev_layout)"
    if [ -n "$PREV_LAYOUT" ]; then
        tmux select-layout "$PREV_LAYOUT" 2>/dev/null || tmux select-layout tiled
    else
        tmux select-layout tiled
    fi

    tmux set-option -wu @zj_stack_mode
    tmux set-option -wu @zj_prev_layout
    tmux display-message "Stack layout: OFF"
    exit 0
fi

tmux set-option -w @zj_prev_layout "$CURRENT_LAYOUT"
tmux set-option -w @zj_stack_mode on
tmux set-option -w main-pane-height 75%
tmux select-layout main-horizontal
tmux display-message "Stack layout: ON"
