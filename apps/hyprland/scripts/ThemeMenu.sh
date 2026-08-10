#!/usr/bin/env bash

# Ask for the mode
OPTIONS="1. Select Static Omarchy Theme\n2. Set Wallpaper (Auto-recolored via Lutgen)"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Theme Mode:" -theme-str 'window {width: 400px;}')

if [[ "$CHOICE" == *"1. Select Static"* ]]; then
    # Helper script for theme previews
    cat << 'SCR' > /tmp/rofi_theme_list.sh
#!/usr/bin/env bash
if [ -z "$1" ]; then
    for theme in "$HOME"/.config/omarchy/themes/*; do
        if [ -d "$theme" ]; then
            tname=$(basename "$theme")
            # Try to find a background image to use as a preview
            icon_path=""
            if [ -d "$theme/backgrounds" ]; then
                icon_path=$(find "$theme/backgrounds" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -n 1)
            fi
            if [ -z "$icon_path" ] && [ -d "$theme/backgrounds-low-quality" ]; then
                icon_path=$(find "$theme/backgrounds-low-quality" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -n 1)
            fi
            
            if [ -n "$icon_path" ]; then
                echo -en "${tname}\0icon\x1f${icon_path}\n"
            else
                echo "${tname}"
            fi
        fi
    done
else
    echo "$1"
fi
SCR
    chmod +x /tmp/rofi_theme_list.sh

    THEME=$(rofi -show custom -modi custom:/tmp/rofi_theme_list.sh -show-icons -theme-str 'window {width: 80%; height: 70%;} listview {columns: 4; lines: 3;} element {orientation: vertical;} element-icon {size: 10em;} element-text {horizontal-align: 0.5;}' -p "Omarchy Themes:")
    
    if [ -n "$THEME" ]; then
        omarchy theme set "$THEME"
        ~/.config/hypr/scripts/UpdateRofiColors.py "$THEME"
        ~/.config/hypr/scripts/Refresh.sh
    fi

elif [[ "$CHOICE" == *"2. Set Wallpaper"* ]]; then
    
    # Helper script for wallpaper previews
    cat << 'SCR' > /tmp/rofi_wallpaper_list.sh
#!/usr/bin/env bash
if [ -z "$1" ]; then
    find "$HOME/Wallpapers" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | while read -r file; do
        bname=$(basename "$file")
        echo -en "${bname}\0icon\x1f${file}\n"
    done
else
    echo "$1"
fi
SCR
    chmod +x /tmp/rofi_wallpaper_list.sh

    WP=$(rofi -show custom -modi custom:/tmp/rofi_wallpaper_list.sh -show-icons -theme-str 'window {width: 80%; height: 70%;} listview {columns: 4; lines: 3;} element {orientation: vertical;} element-icon {size: 10em;} element-text {horizontal-align: 0.5;}' -p "Select Wallpaper:")
    
    if [ -n "$WP" ]; then
        CURRENT_THEME_NAME=$(omarchy theme current | tr 'A-Z' 'a-z' | tr ' ' '-')
        THEME_DIR="$HOME/.config/omarchy/themes/$CURRENT_THEME_NAME"
        
        if [ ! -d "$THEME_DIR" ]; then
            THEME_DIR=$(dirname $(dirname $(readlink -f ~/.config/omarchy/state/background)))
        fi

        TMP_SRC="/tmp/omarchy_lutgen_src"
        mkdir -p "$TMP_SRC"
        rm -f "$TMP_SRC"/*
        cp "$HOME/Wallpapers/$WP" "$TMP_SRC/"
        
        notify-send -t 3000 "Theme Menu" "Recoloring $WP with Lutgen..."

        ~/dotfiles/omarchy-themes/scripts/omarchy-lutgen-wallpapers "$THEME_DIR" "$TMP_SRC"

        ln -sf "$THEME_DIR/backgrounds/$WP" ~/.config/omarchy/state/background
        pkill -x swaybg
        setsid uwsm-app -- swaybg -i "$THEME_DIR/backgrounds/$WP" -m fill >/dev/null 2>&1 &
        
        ~/.config/hypr/scripts/UpdateRofiColors.py "$(basename $THEME_DIR)"
        ~/.config/hypr/scripts/Refresh.sh
        notify-send -t 3000 "Theme Menu" "Wallpaper applied!"
    fi
fi
