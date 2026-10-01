#!/usr/bin/env bash
# Screen-shader switcher that also sets the damage-tracking mode each shader
# needs. The choice is saved to $STATE and looknfeel.lua re-applies it on
# every config load, so `hyprctl reload` / relogin keep it.
#
#   crt-toggle.sh            # on/off (turns on the last used shader)
#   crt-toggle.sh next       # switch to the next shader in this dir (turns on)
#   crt-toggle.sh <name>     # toggle a specific shader, e.g. crt-static
#   crt-toggle.sh on <name>  # always turn <name> on (used by omarchy-customizer)
#   crt-toggle.sh off
#
# Bound in bindings.lua: SUPER+ALT+C (toggle), SUPER+ALT+SHIFT+C (next).
#
# damage_tracking modes (hyprland src/render/types.hpp):
#   2 full    - default, redraw only changed boxes. Fine for flat shaders.
#   1 monitor - redraw the whole screen, but only when something changed.
#               Needed by warping shaders, otherwise parts go missing.
#   0 none    - redraw every frame forever. Only for shaders using `time`.
#
# `hyprctl keyword` doesn't work with the Lua config; `hyprctl eval` does.
set -euo pipefail

DIR="$HOME/.config/hypr/shaders"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
STATE="$STATE_DIR/screen-shader"   # "<path> <damage_tracking>" or empty = off
LAST="$STATE_DIR/screen-shader-last"
mkdir -p "$STATE_DIR"

damage_mode() {
    # Strip comments so a mention of `time` in the header doesn't count.
    local code
    code="$(sed 's://.*$::' "$1")"
    if grep -qE '\buniform\s+float\s+time\b' <<<"$code"; then
        echo 0
    elif grep -qE '\b(WARP|CURVATURE|BARREL)\s*=\s*0*\.?0*[1-9]' <<<"$code"; then
        echo 1
    else
        echo 2
    fi
}

name() { basename "$1" .frag; }

dt_label() {
    case "$1" in
    0) echo "damage_tracking = 0 (перерисовка каждый кадр, много энергии)" ;;
    1) echo "damage_tracking = 1 (весь экран при изменениях)" ;;
    2) echo "damage_tracking = 2 (только изменённые области)" ;;
    esac
}

notify() { # $1 = title, $2 = body
    # Omarchy's shell ignores the "synchronous" hint, so replace the previous
    # notification by its id - repeated presses update one toast, not a stack.
    local idf="$STATE_DIR/screen-shader-notify-id" id
    id="$(cat "$idf" 2>/dev/null || echo 0)"
    omarchy notification send -p -r "$id" -t 2000 -g 󰍹 --app-name "Screen shader" \
        "$1" "$2" >"$idf" 2>/dev/null || true
}

apply() { # $1 = shader path or "" for off
    local path="$1" dt=2
    [[ -n "$path" ]] && dt="$(damage_mode "$path")"
    hyprctl eval "hl.config({ decoration = { screen_shader = \"$path\" }, debug = { damage_tracking = $dt } })" >/dev/null

    if [[ -z "$path" ]]; then
        : >"$STATE"
        notify "Шейдер выключен: $(name "$current")" "$(dt_label "$dt")"
        return
    fi

    echo "$path $dt" >"$STATE"
    echo "$path" >"$LAST"
    if [[ -n "$current" ]]; then
        notify "Шейдер: $(name "$current") → $(name "$path")" "$(dt_label "$dt")"
    else
        notify "Шейдер включён: $(name "$path")" "$(dt_label "$dt")"
    fi
}

current="$(hyprctl getoption decoration:screen_shader -j | jq -r .str)"
current="${current/#\~/$HOME}"
[[ "$current" == "[[EMPTY]]" ]] && current=""

mapfile -t shaders < <(printf '%s\n' "$DIR"/*.frag | sort)

case "${1:-toggle}" in
toggle)
    if [[ -n "$current" ]]; then
        apply ""
    else
        last="$(cat "$LAST" 2>/dev/null || true)"
        [[ -f "$last" ]] || last="$DIR/bettercrt.frag"
        apply "$last"
    fi
    ;;
next)
    next="${shaders[0]}"
    for i in "${!shaders[@]}"; do
        if [[ "${shaders[$i]}" == "$current" ]]; then
            next="${shaders[$(( (i + 1) % ${#shaders[@]} ))]}"
            break
        fi
    done
    apply "$next"
    ;;
on)
    target="$DIR/${2:-}.frag"
    [[ -f "$target" ]] || { notify "Шейдер не найден" "$target"; exit 1; }
    [[ "$current" == "$target" ]] || apply "$target"
    ;;
off)
    [[ -z "$current" ]] || apply ""
    ;;
*)
    target="$DIR/$1.frag"
    [[ -f "$target" ]] || { notify "Шейдер не найден" "$target"; exit 1; }
    if [[ "$current" == "$target" ]]; then apply ""; else apply "$target"; fi
    ;;
esac
