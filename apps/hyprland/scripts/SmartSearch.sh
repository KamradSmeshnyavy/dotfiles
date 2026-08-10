#!/usr/bin/env bash

# A rofi dmenu wrapper that intercepts ? and @
# It doesn't update live while typing, but if you type "?something" and hit enter, it switches modes.

QUERY=$(rofi -dmenu -p "󰣇 Search / ? (Clip) / @ (Web)" -theme-str 'window {width: 40%;} entry {placeholder: "Type app name, ? for clipboard, @ for web...";}')

if [[ -z "$QUERY" ]]; then
    exit 0
fi

if [[ "$QUERY" == \?* ]]; then
    # Clipboard mode
    SEARCH_TERM="${QUERY:1}"
    # Open cliphist with this search term pre-filled or just open cliphist
    res=$(cliphist list | rofi -dmenu -p "Clipboard" -filter "$SEARCH_TERM")
    if [ -n "$res" ]; then
        echo "$res" | cliphist decode | wl-copy
    fi
elif [[ "$QUERY" == \@* ]]; then
    # Web search mode
    SEARCH_TERM="${QUERY:1}"
    # Use xdg-open to search Google
    xdg-open "https://google.com/search?q=$SEARCH_TERM"
else
    # App launch mode
    # Since they hit enter on a dmenu, we didn't run drun. 
    # To properly run the app, we can just run rofi drun pre-filtered, but that requires another enter.
    # It's better to just launch drun initially with a custom script, but Rofi doesn't intercept characters well.
    # Actually, Rofi has a built in run/drun. If we just pass the query to drun:
    rofi -show drun -filter "$QUERY"
fi
