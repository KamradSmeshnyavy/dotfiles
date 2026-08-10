#!/bin/bash

# Получаем информацию об активном окне
is_float=$(hyprctl activewindow -j | jq -r '.floating')

# Если нет активного окна (например, фокус на пустом столе), просто пытаемся найти плавающее
if [ "$is_float" == "null" ]; then
    hyprctl dispatch cyclenext floating
    exit 0
fi

if [ "$is_float" == "true" ]; then
    # Если окно плавающее, переключаемся на следующее обычное (tiled)
    hyprctl dispatch cyclenext tiled
    # Чтобы окно позади визуально стало активным:
    hyprctl dispatch alterzorder bottom
else
    # Если окно обычное, переключаемся на ближайшее плавающее
    hyprctl dispatch cyclenext floating
    hyprctl dispatch alterzorder top
fi
