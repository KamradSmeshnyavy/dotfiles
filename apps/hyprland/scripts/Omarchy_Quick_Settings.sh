#!/usr/bin/env bash

# Rofi menu for Settings (called by Waybar gear icon)

OPTIONS="1. Change Animations\n2. Change Wallpaper (Theme Menu)\n3. Omarchy Menu (System)\n4. Waybar Styles\n5. Waybar Layout"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Settings:" -theme-str 'window {width: 400px;}')

case "$CHOICE" in
    *"Animations"*)
        ~/.config/hypr/scripts/Animations.sh
        ;;
    *"Wallpaper"*)
        ~/.config/hypr/scripts/ThemeMenu.sh
        ;;
    *"Omarchy Menu"*)
        ~/.config/hypr/scripts/OmarchyRofiMenu.sh
        ;;
    *"Waybar Styles"*)
        ~/.config/hypr/scripts/WaybarStyles.sh
        ;;
    *"Waybar Layout"*)
        ~/.config/hypr/scripts/WaybarLayout.sh
        ;;
esac
