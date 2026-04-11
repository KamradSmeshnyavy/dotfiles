#!/bin/bash
# smart_focus.sh - Фокус на окно с учетом направления

DIRECTION=$1

# Пытаемся найти окно в указанном направлении
yabai -m window --focus "$DIRECTION" 2>/dev/null

# Если не получилось, ищем в соседнем display
if [ $? -ne 0 ]; then
    case $DIRECTION in
        "west"|"left")
            yabai -m display --focus prev 2>/dev/null
            yabai -m window --focus east 2>/dev/null || yabai -m window --focus last
            ;;
        "east"|"right")
            yabai -m display --focus next 2>/dev/null
            yabai -m window --focus west 2>/dev/null || yabai -m window --focus first
            ;;
        "north"|"up")
            yabai -m window --focus last 2>/dev/null
            ;;
        "south"|"down")
            yabai -m window --focus first 2>/dev/null
            ;;
    esac
fi