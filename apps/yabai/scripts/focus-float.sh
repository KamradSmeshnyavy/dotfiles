#!/usr/bin/env sh
focus="$(yabai -m query --windows --window | jq '.id')"

yabai -m query --windows --space | \
  jq -r '.[] | select(."is-floating" == true) | .id' | \
  while read -r id; do
    if [ "$id" = "$focus" ]; then
      yabai -m window "$id" --layer above
    else
      yabai -m window "$id" --layer below
    fi
  done