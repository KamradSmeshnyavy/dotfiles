#!/usr/bin/env bash

CHOICE=$(echo -e "1. Select Static Omarchy Theme\n2. Set Wallpaper (Auto-recolored via Lutgen)" | walker --dmenu --minheight 100 -p "Theme Mode:")

if [[ "$CHOICE" == *"1. Select Static"* ]]; then
    omarchy-launch-walker -m menus:omarchythemes --width 800 --minheight 400
elif [[ "$CHOICE" == *"2. Set Wallpaper"* ]]; then
    omarchy-launch-walker -m menus:lutgenWallpapers --width 800 --minheight 400
fi
