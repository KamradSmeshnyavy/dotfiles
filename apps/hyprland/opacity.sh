#!/usr/bin/env bash
# System-wide window transparency presets (decoration active/inactive_opacity).
# The choice is saved to $STATE as "<name> <active> <inactive>" and
# looknfeel.lua re-applies those values on every config load, so
# `hyprctl reload` / relogin keep it.
#
#   opacity.sh               # next preset (same as `next`)
#   opacity.sh next | prev   # cycle through PRESETS
#   opacity.sh set <name>    # apply a preset by name (used by the customizer)
#   opacity.sh preview <name>  # apply without saving or notifying (customizer hover)
#   opacity.sh restore       # re-apply the saved preset silently
#   opacity.sh list          # "<name> <active> <inactive> <current 0/1>" per line
#   opacity.sh current       # name of the preset in use
#
# Bound in bindings.lua: SUPER+ALT+O (next), SUPER+ALT+SHIFT+O (prev).
set -euo pipefail

# name active inactive
PRESETS=(
    "solid   1.00 1.00"
    "subtle  1.00 0.90"
    "soft    0.95 0.85"
    "glass   0.90 0.80"
    "frosted 0.85 0.70"
)
DEFAULT=subtle

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
STATE="$STATE_DIR/opacity"
mkdir -p "$STATE_DIR"

names() { local p; for p in "${PRESETS[@]}"; do echo "${p%% *}"; done; }

lookup() { # $1 = name -> "active inactive", fails when unknown
    local p n a i
    for p in "${PRESETS[@]}"; do
        read -r n a i <<<"$p"
        [[ $n == "$1" ]] && { echo "$a $i"; return 0; }
    done
    return 1
}

current() {
    local c
    read -r c _ <"$STATE" 2>/dev/null || true
    lookup "${c:-}" >/dev/null 2>&1 && echo "$c" || echo "$DEFAULT"
}

notify() { # $1 = title, $2 = body
    # Replace the previous toast by id so repeated presses update one toast.
    local idf="$STATE_DIR/opacity-notify-id" id
    id="$(cat "$idf" 2>/dev/null || echo 0)"
    omarchy notification send -p -r "$id" -t 1500 -g 󰂵 --app-name "Opacity" \
        "$1" "$2" >"$idf" 2>/dev/null || true
}

set_opacity() { # $1 = name; fails when unknown
    local a i
    read -r a i < <(lookup "$1") || return 1
    hyprctl eval "hl.config({ decoration = { active_opacity = $a, inactive_opacity = $i } })" >/dev/null
}

apply() { # $1 = name
    local a i
    set_opacity "$1" || { notify "Нет такого пресета" "$1"; exit 1; }
    read -r a i < <(lookup "$1")
    echo "$1 $a $i" >"$STATE"
    notify "Прозрачность: $1" "активное окно $a · неактивные $i"
}

step() { # $1 = +1 / -1
    local -a list
    mapfile -t list < <(names)
    local cur n=${#list[@]} k
    cur="$(current)"
    for k in "${!list[@]}"; do
        [[ ${list[$k]} == "$cur" ]] && { apply "${list[$(( (k + $1 + n) % n ))]}"; return; }
    done
    apply "$DEFAULT"
}

case "${1:-next}" in
next) step 1 ;;
prev) step -1 ;;
set) apply "${2:?preset name}" ;;
preview) set_opacity "${2:?preset name}" ;;
restore) set_opacity "$(current)" ;;
current) current ;;
list)
    cur="$(current)"
    for p in "${PRESETS[@]}"; do
        read -r n a i <<<"$p"
        echo "$n $a $i $([[ $n == "$cur" ]] && echo 1 || echo 0)"
    done
    ;;
*) echo "usage: $0 [next|prev|set <name>|preview <name>|restore|list|current]" >&2; exit 1 ;;
esac
