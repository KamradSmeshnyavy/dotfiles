#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "Type your search query..."
else
    xdg-open "https://google.com/search?q=$1"
fi
