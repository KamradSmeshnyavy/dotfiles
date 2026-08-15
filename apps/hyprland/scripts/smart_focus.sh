#!/bin/bash
DIR=$1

LAYOUT=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')

if [ "$LAYOUT" = "scrolling" ]; then
    hyprctl dispatch "hl.dsp.layout(\"focus $DIR\")"
else
    hyprctl dispatch "hl.dsp.focus({ direction = \"$DIR\" })"
fi
