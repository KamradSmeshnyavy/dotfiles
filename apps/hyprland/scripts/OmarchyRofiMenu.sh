#!/usr/bin/env bash

# A Rofi replacement for the Walker-based Omarchy Menu

OPTIONS="󰕾 Audio\n Wifi\n󰂯 Bluetooth\n󱐋 Power Profile\n󰍹 Monitors"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Omarchy Menu:" -theme-str 'window {width: 400px;}')

case "$CHOICE" in
    *"Audio"*)
        # Using standard pulse audio tools or just opening pavucontrol
        pavucontrol &
        ;;
    *"Wifi"*)
        # Assuming networkmanager is used, an nmtui terminal could be launched, or if a GUI exists
        alacritty -e nmtui &
        ;;
    *"Bluetooth"*)
        blueman-manager &
        ;;
    *"Power Profile"*)
        PROFILES="performance\nbalanced\npower-saver"
        P_CHOICE=$(echo -e "$PROFILES" | rofi -dmenu -i -p "Select Profile:")
        if [ -n "$P_CHOICE" ]; then
            powerprofilesctl set "$P_CHOICE"
            notify-send "Power Profile" "Set to $P_CHOICE"
        fi
        ;;
    *"Monitors"*)
        wdisplays &
        ;;
esac
