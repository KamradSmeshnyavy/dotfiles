#!/bin/bash
# grid-resize.sh - Ресайз окон по сетке 4x4

GRID_SIZE=4
WINDOW_ID=$(yabai -m query --windows --window | jq -r '.id')

case $1 in
    "left")
        yabai -m window --grid 4:4:0:0:2:4
        ;;
    "right")
        yabai -m window --grid 4:4:2:0:2:4
        ;;
    "top")
        yabai -m window --grid 4:4:0:0:4:2
        ;;
    "bottom")
        yabai -m window --grid 4:4:0:2:4:2
        ;;
    "top-left")
        yabai -m window --grid 4:4:0:0:2:2
        ;;
    "top-right")
        yabai -m window --grid 4:4:2:0:2:2
        ;;
    "bottom-left")
        yabai -m window --grid 4:4:0:2:2:2
        ;;
    "bottom-right")
        yabai -m window --grid 4:4:2:2:2:2
        ;;
    "center")
        yabai -m window --grid 4:4:1:1:2:2
        ;;
    "full")
        yabai -m window --grid 4:4:0:0:4:4
        ;;
esac