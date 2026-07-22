#!/bin/bash
DIR=$1

# Получаем текущий активный макет рабочего стола
LAYOUT=$(hyprctl activeworkspace | grep "tiledLayout" | awk '{print $2}')

if [ "$LAYOUT" = "scrolling" ]; then
    hyprctl dispatch layoutmsg "focus $DIR"
else
    hyprctl dispatch movefocus "$DIR"
fi
