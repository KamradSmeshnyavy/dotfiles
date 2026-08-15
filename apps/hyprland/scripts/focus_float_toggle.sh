#!/bin/bash

is_float=$(hyprctl activewindow -j | jq -r '.floating')

if [ "$is_float" == "null" ]; then
    hyprctl dispatch "hl.dsp.window.focus({ next = true, floating = true })"
    exit 0
fi

if [ "$is_float" == "true" ]; then
    hyprctl dispatch "hl.dsp.window.focus({ next = true, floating = false })"
    hyprctl dispatch "hl.dsp.window.alter_z_order(\"bottom\")"
else
    hyprctl dispatch "hl.dsp.window.focus({ next = true, floating = true })"
    hyprctl dispatch "hl.dsp.window.alter_z_order(\"top\")"
fi
