#!/usr/bin/env bash
# Backend for the Customizer overlay (Customizer.qml). Same actions as the old
# fzf script scripts/bin/omarchy-customizer, split into list/preview/apply so
# the overlay can drive them.
#
#   customizer.sh list <category>          TSV: label, value, preview path, current(0/1), note
#   customizer.sh anim-preview <file>      load an animation set without committing
#   customizer.sh anim-restore             undo previews (back to what `list anims` saw)
#   customizer.sh apply <category> <value>
#
# Categories: anims layouts themes theme-walls walls shaders
set -uo pipefail

ANIM_DIR="$HOME/dotfiles/apps/hyprland/animations_lua"
ANIM_ACTIVE="$HOME/dotfiles/apps/hyprland/active_animations.lua"
LAYOUT_DIR="$HOME/.config/omarchy"
SHADER_DIR="$HOME/.config/hypr/shaders"
TOGGLE="$SHADER_DIR/crt-toggle.sh"
RUN_DIR="${XDG_RUNTIME_DIR:-/tmp}/omarchy-customizer"
ANIM_BACKUP="$RUN_DIR/active_animations.lua"

theme_name() { cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || echo default; }

images_in() {
  find -L "$1" -maxdepth "$2" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort
}

# Same lookup as omarchy-theme-switcher: preview.* first, then the first background.
theme_preview() {
  local p
  shopt -s nullglob nocaseglob
  for p in "$1"/preview.{png,jpg,jpeg,webp} "$1"/backgrounds/*.{jpg,jpeg,png,webp}; do
    [[ -f $p ]] && { echo "$p"; break; }
  done
  shopt -u nullglob nocaseglob
}

walls_dir() {
  if [[ -d $HOME/Wallpapers ]]; then echo "$HOME/Wallpapers"; else echo "$HOME/Pictures"; fi
}

# Recolor every image directly in <src> into the current theme, then set the
# background when there was exactly one image.
recolor() {
  local src=$1 theme_dir files
  theme_dir="$HOME/.config/omarchy/themes/$(theme_name)"
  if [[ ! -d $theme_dir ]]; then
    notify-send "Wallpaper" "Cannot recolor stock Omarchy theme. Please use a custom theme."
    exit 1
  fi
  mapfile -t files < <(images_in "$src" 1)
  if ((${#files[@]} == 0)); then
    notify-send "Wallpaper" "No images in $src"
    exit 1
  fi
  if ((${#files[@]} == 1)); then
    notify-send -t 3000 "Wallpaper" "Recoloring $(basename "${files[0]}") with Lutgen..."
  else
    notify-send -t 3000 "Wallpaper" "Recoloring ${#files[@]} images from $(basename "$src") with Lutgen..."
  fi
  if ! "$HOME/dotfiles/omarchy-themes/scripts/omarchy-lutgen-wallpapers" "$theme_dir" "$src"; then
    notify-send -u critical "Wallpaper" "Lutgen failed"
    exit 1
  fi
  if ((${#files[@]} == 1)); then
    omarchy theme bg set "$theme_dir/backgrounds/$(basename "${files[0]}")"
    notify-send -t 3000 "Wallpaper" "Applied $(basename "${files[0]}")!"
  else
    notify-send -t 5000 "Wallpaper" "Added ${#files[@]} recolored wallpapers to $(theme_name). Pick one in Theme Wallpaper (4)."
  fi
}

# Copy the given files into a fresh dir so recolor() sees only them.
recolor_files() {
  local src
  src=$(mktemp -d "${TMPDIR:-/tmp}/omarchy-lutgen-src.XXXXXX")
  cp -- "$@" "$src/"
  recolor "$src"
}

current_shader() {
  local cur
  cur=$(hyprctl getoption decoration:screen_shader -j 2>/dev/null | jq -r '.str // empty')
  if [[ -z $cur || $cur == "[[EMPTY]]" ]]; then echo off; else basename "$cur" .frag; fi
}

list() {
  case "$1" in
  anims)
    # Snapshot what is in use; previews overwrite it until anim-restore.
    cp "$ANIM_ACTIVE" "$ANIM_BACKUP" 2>/dev/null
    for f in "$ANIM_DIR"/*.lua; do
      [[ -f $f ]] || continue
      local cur=0
      cmp -s "$f" "$ANIM_ACTIVE" && cur=1
      printf '%s\t%s\t%s\t%s\n' "$(basename "$f" .lua)" "$f" "$f" "$cur"
    done
    ;;
  layouts)
    local f
    for f in "$LAYOUT_DIR"/shell-*.json; do
      [[ -f $f ]] || continue
      local cur=0
      cmp -s "$f" "$LAYOUT_DIR/shell.json" && cur=1
      printf '%s\t%s\t%s\t%s\n' "$(basename "$f" .json)" "$f" "$f" "$cur"
    done
    ;;
  themes)
    local current dir slug label
    current=$(theme_name)
    {
      find -L "$HOME/.config/omarchy/themes" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null
      find "$OMARCHY_PATH/themes" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null
    } | sort -u | while read -r slug; do
      dir="$HOME/.config/omarchy/themes/$slug"
      [[ -d $dir ]] || dir="$OMARCHY_PATH/themes/$slug"
      label=$(sed -E 's/(^|-)([a-z])/\1\u\2/g; s/-/ /g' <<<"$slug")
      printf '%s\t%s\t%s\t%s\n' "$label" "$slug" "$(theme_preview "$dir")" "$([[ $slug == "$current" ]] && echo 1 || echo 0)"
    done
    ;;
  theme-walls)
    local bg cur_bg
    bg="$HOME/.config/omarchy/themes/$(theme_name)/backgrounds"
    [[ -d $bg ]] || bg="$HOME/.local/state/omarchy/current/theme/backgrounds"
    cur_bg=$(readlink -f "$HOME/.local/state/omarchy/current/background" 2>/dev/null)
    images_in "$bg" 1 | while read -r f; do
      printf '%s\t%s\t%s\t%s\n' "$(basename "$f")" "$f" "$f" "$([[ $(readlink -f "$f") == "$cur_bg" ]] && echo 1 || echo 0)"
    done
    ;;
  walls)
    local dir
    dir=$(walls_dir)
    printf '%s\t%s\t\t0\t%s\n' "📂 Recolor a whole folder…  (O)" "pick-dir" \
      "Pick a folder; every image directly in it is recolored into the theme's backgrounds."
    printf '%s\t%s\t\t0\t%s\n' "🖼 Recolor image(s) from anywhere…  (o)" "pick-files" \
      "Pick one or more images (Ctrl/Shift-click) from any folder."
    images_in "$dir" 10 | while read -r f; do
      printf '%s\t%s\t%s\t0\n' "${f#"$dir"/}" "$f" "$f"
    done
    ;;
  shaders)
    local cur
    cur=$(current_shader)
    printf '%s\t%s\t\t0\n' "⏻ Toggle shader (now: $cur)" "toggle"
    printf '%s\t%s\t\t0\n' "⏭ Next shader" "next"
    for f in "$SHADER_DIR"/*.frag; do
      [[ -f $f ]] || continue
      local n
      n=$(basename "$f" .frag)
      printf '%s\t%s\t%s\t%s\n' "$n" "$n" "$f" "$([[ $n == "$cur" ]] && echo 1 || echo 0)"
    done
    ;;
  esac
}

apply() {
  local category=$1 value=$2
  case "$category" in
  anims)
    cp "$value" "$ANIM_ACTIVE"
    cp "$value" "$ANIM_BACKUP"
    hyprctl reload >/dev/null 2>&1
    notify-send -t 2000 "Animations" "Loaded: $(basename "$value" .lua)"
    ;;
  layouts)
    # shell.json hot-reloads, so no shell restart (it would kill this overlay too).
    cp "$value" "$LAYOUT_DIR/shell.json"
    notify-send -t 2000 "Shell Layout" "Applied: $(basename "$value")"
    ;;
  themes)
    notify-send -t 3000 "Theme" "Applying $value..."
    omarchy theme set "$value"
    notify-send -t 3000 "Theme" "Applied $value!"
    ;;
  theme-walls)
    omarchy theme bg set "$value"
    notify-send -t 3000 "Wallpaper" "Applied $(basename "$value")!"
    ;;
  walls)
    local picked
    case "$value" in
    pick-dir)
      picked=$(zenity --file-selection --directory --title="Folder to recolor" \
        --filename="$(walls_dir)/" 2>/dev/null) || exit 0
      recolor "$picked"
      ;;
    pick-files)
      picked=$(zenity --file-selection --multiple --separator=$'\n' --title="Image(s) to recolor" \
        --filename="$(walls_dir)/" \
        --file-filter="Images | *.jpg *.jpeg *.png *.webp *.JPG *.JPEG *.PNG *.WEBP" 2>/dev/null) || exit 0
      local -a list
      mapfile -t list <<<"$picked"
      recolor_files "${list[@]}"
      ;;
    *) recolor_files "$value" ;;
    esac
    ;;
  shaders)
    case "$value" in
    toggle) "$TOGGLE" ;;
    next) "$TOGGLE" next ;;
    *) "$TOGGLE" on "$value" ;;
    esac
    ;;
  esac
}

mkdir -p "$RUN_DIR"
case "${1:-}" in
list) list "${2:-}" ;;
anim-preview)
  cp "$2" "$ANIM_ACTIVE"
  hyprctl reload >/dev/null 2>&1
  ;;
anim-restore)
  # The overlay only calls this after a preview, so the backup is fresh.
  if [[ -f $ANIM_BACKUP ]] && ! cmp -s "$ANIM_BACKUP" "$ANIM_ACTIVE"; then
    cp "$ANIM_BACKUP" "$ANIM_ACTIVE"
    hyprctl reload >/dev/null 2>&1
  fi
  ;;
apply) apply "$2" "$3" ;;
*)
  echo "usage: $0 list|anim-preview|anim-restore|apply ..." >&2
  exit 1
  ;;
esac
