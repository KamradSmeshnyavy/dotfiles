#!/usr/bin/env bash
# System-wide background blur presets (decoration.blur). Works on every
# translucent window, so it shows together with the opacity.sh presets.
# The choice is saved to $STATE as "<name> <size> <passes> <vibrancy> <noise>"
# and the Customizer re-applies it after every config reload (customizer.sh restore,
# or hypr/customizer.lua when it is loaded from the Hyprland config).
#
#   blur.sh                  # next preset (same as `next`)
#   blur.sh next | prev      # cycle through PRESETS
#   blur.sh set <name>       # apply a preset by name (used by the customizer)
#   blur.sh preview <name>   # apply without saving or notifying (customizer hover)
#   blur.sh restore          # re-apply the saved preset silently (none saved: hyprctl reload)
#   blur.sh list             # "<name> <size> <passes> <vibrancy> <noise> <current 0/1>"
#   blur.sh current          # name of the preset in use
#
# Bind it if you like, e.g. SUPER+ALT+U (next), SUPER+ALT+SHIFT+U (prev).
set -euo pipefail
# shellcheck source=i18n.sh
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/i18n.sh"

# name size passes vibrancy noise   (size 0 = blur off)
PRESETS=(
    "off      0  1 0.00 0.000"
    "light    3  2 0.10 0.010"
    "medium   6  3 0.17 0.012"
    "strong  10  4 0.20 0.015"
    "frosted 14  4 0.30 0.030"
)
DEFAULT=medium

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
STATE="$STATE_DIR/blur"
mkdir -p "$STATE_DIR"

names() { local p; for p in "${PRESETS[@]}"; do echo "${p%% *}"; done; }

lookup() { # $1 = name -> "size passes vibrancy noise", fails when unknown
    local p n rest
    for p in "${PRESETS[@]}"; do
        read -r n rest <<<"$p"
        [[ $n == "$1" ]] && { echo "$rest"; return 0; }
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
    local idf="$STATE_DIR/blur-notify-id" id
    id="$(cat "$idf" 2>/dev/null || echo 0)"
    omarchy notification send -p -r "$id" -t 1500 -g 󰂷 --app-name "Blur" \
        "$1" "$2" >"$idf" 2>/dev/null || true
}

set_blur() { # $1 = name; fails when unknown
    local s p v n on=true
    read -r s p v n < <(lookup "$1") || return 1
    ((s == 0)) && on=false
    hyprctl eval "hl.config({ decoration = { blur = { enabled = $on, size = $((s > 0 ? s : 1)), passes = $p, vibrancy = $v, noise = $n } } })" >/dev/null
}

apply() { # $1 = name
    local s p v n
    set_blur "$1" || { notify "$(t "No such preset")" "$1"; exit 1; }
    read -r s p v n < <(lookup "$1")
    echo "$1 $s $p $v $n" >"$STATE"
    if ((s == 0)); then
        notify "$(t "Blur: off")" "$(t "windows show through without blur")"
    else
        notify "$(t "Blur: %s" "$1")" "size $s · passes $p · vibrancy $v"
    fi
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
preview) set_blur "${2:?preset name}" ;;
restore) if [[ -s $STATE ]]; then set_blur "$(current)"; else hyprctl reload >/dev/null; fi ;;
current) current ;;
list)
    cur="$(current)"
    for p in "${PRESETS[@]}"; do
        read -r n s ps v no <<<"$p"
        echo "$n $s $ps $v $no $([[ $n == "$cur" ]] && echo 1 || echo 0)"
    done
    ;;
*) echo "usage: $0 [next|prev|set <name>|preview <name>|restore|list|current]" >&2; exit 1 ;;
esac
