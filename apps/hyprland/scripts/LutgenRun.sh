#!/usr/bin/env bash
WP="$1"
CURRENT_THEME_NAME=$(omarchy theme current | tr 'A-Z' 'a-z' | tr ' ' '-')
THEME_DIR="$HOME/.config/omarchy/themes/$CURRENT_THEME_NAME"
if [ ! -d "$THEME_DIR" ]; then
    THEME_DIR=$(dirname $(dirname $(readlink -f ~/.config/omarchy/state/background)))
fi

TMP_SRC="/tmp/omarchy_lutgen_src"
mkdir -p "$TMP_SRC"
rm -f "$TMP_SRC"/*
cp "$WP" "$TMP_SRC/"

notify-send -t 3000 "Wallpaper" "Recoloring $(basename "$WP") with Lutgen..."
~/dotfiles/omarchy-themes/scripts/omarchy-lutgen-wallpapers "$THEME_DIR" "$TMP_SRC"

ln -sf "$THEME_DIR/backgrounds/$(basename "$WP")" ~/.config/omarchy/state/background
pkill -x swaybg
setsid uwsm-app -- swaybg -i "$THEME_DIR/backgrounds/$(basename "$WP")" -m fill >/dev/null 2>&1 &

~/.config/hypr/scripts/UpdateRofiColors.py "$(basename $THEME_DIR)"
~/.config/hypr/scripts/Refresh.sh
notify-send -t 3000 "Wallpaper" "Applied $(basename "$WP")!"
