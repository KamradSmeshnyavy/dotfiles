#!/bin/bash

# Получаем текущий space
CURRENT_SPACE=$(yabai -m query --spaces --space | jq -r '.index')

# Check if there are hidden floating windows in current space
HIDDEN_FLOATS=$(yabai -m query --windows | jq --arg space "$CURRENT_SPACE" '[.[] | select(."is-floating" == true and ."is-minimized" == true and .space == ($space | tonumber))] | length')

if [ "$HIDDEN_FLOATS" -gt 0 ]; then
    # Show all hidden floating windows in current space
    yabai -m query --windows | jq -r --arg space "$CURRENT_SPACE" '.[] | select(."is-floating" == true and ."is-minimized" == true and .space == ($space | tonumber)) | .id' | xargs -I {} yabai -m window --deminimize {}
    echo "Restored $HIDDEN_FLOATS floating windows in space $CURRENT_SPACE"
else
    # Hide all visible floating windows in current space
    VISIBLE_FLOATS=$(yabai -m query --windows | jq -r --arg space "$CURRENT_SPACE" '.[] | select(."is-floating" == true and ."is-minimized" == false and .space == ($space | tonumber)) | .id')
    COUNT=$(echo "$VISIBLE_FLOATS" | wc -l | tr -d ' ')

    if [ "$COUNT" -gt 0 ]; then
        echo "$VISIBLE_FLOATS" | xargs -I {} yabai -m window --minimize {}
        echo "Minimized $COUNT floating windows in space $CURRENT_SPACE"
    else
        echo "No floating windows found in space $CURRENT_SPACE"
    fi
fi