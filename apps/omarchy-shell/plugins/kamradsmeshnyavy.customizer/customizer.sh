#!/usr/bin/env bash
# Backend for the Customizer overlay (Customizer.qml). Same actions as the old
# fzf script scripts/bin/omarchy-customizer, split into list/preview/apply so
# the overlay can drive them.
#
#   customizer.sh list <category>          TSV: label, value, preview path, current(0/1), note[, sub — подпись под строкой]
#   customizer.sh anim-preview <file>      load an animation set without committing
#   customizer.sh anim-restore             undo previews (back to what `list anims` saw)
#   customizer.sh apply <category> <value>
#   customizer.sh thumbs <category>        fill the thumbnail cache for an image category
#   customizer.sh status                   TSV: key, value (header chips)
#   customizer.sh opacity-preview <name>   apply a transparency preset without saving
#   customizer.sh opacity-restore          back to the saved preset
#   customizer.sh blur-preview <name>      same pair for the blur presets
#   customizer.sh blur-restore
#   customizer.sh bar-skins-preview <file> примерить скин бара, не сохраняя
#   customizer.sh bar-skins-restore        вернуть скин, который видел `list bar-skins`
#   customizer.sh tweak <key> <+|-|pick|reset>  шаг / сброс одного параметра скина (Bar Tweaks)
#
# Categories: anims bar-layouts bar-skins bar-tweaks themes theme-walls walls shaders opacity blur
set -uo pipefail

ANIM_DIR="$HOME/dotfiles/apps/hyprland/animations_lua"
ANIM_ACTIVE="$HOME/dotfiles/apps/hyprland/active_animations.lua"
# Бар (плагин kamradsmeshnyavy.bar): пресеты в репо, активный скин и shell.json — в ~/.config.
BAR_DIR="$HOME/dotfiles/apps/omarchy-shell/bar"
BAR_SKIN="$HOME/.config/omarchy/bar-skin.json"
# Экран блокировки (плагин kamradsmeshnyavy.lock): выбор и настройки — lock-design.json.
LOCK_PLUGIN="$HOME/dotfiles/apps/omarchy-shell/plugins/kamradsmeshnyavy.lock"
LOCK_CFG="$HOME/.config/omarchy/lock-design.json"
LOCK_USER_DIR="$HOME/.config/omarchy/lock-designs"
LOCK_THUMBS="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-customizer/lock"
# Переходы обоев (kamradsmeshnyavy.background) и вид пикера тем/обоев (kamradsmeshnyavy.image-picker).
FX_CFG="$HOME/.config/omarchy/wallpaper-transition.json"
PICKER_CFG="$HOME/.config/omarchy/image-picker.json"
PICKER_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/image-selector"
# Файл, который правят твики (bar-skin.json или lock-design.json), — см. tweak_file.
TW_FILE="$BAR_SKIN"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
SHADER_DIR="$HOME/.config/hypr/shaders"
TOGGLE="$SHADER_DIR/crt-toggle.sh"
OPACITY="$HOME/.config/hypr/opacity.sh"
BLUR="$HOME/.config/hypr/blur.sh"
RUN_DIR="${XDG_RUNTIME_DIR:-/tmp}/omarchy-customizer"
ANIM_BACKUP="$RUN_DIR/active_animations.lua"
SKIN_BACKUP="$RUN_DIR/bar-skin.json"
TRANSPARENT_BACKUP="$RUN_DIR/bar-transparent"
# Thumbnails are named md5(<source path>).jpg, the same Qt.md5() the overlay uses.
THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy-customizer/thumbs"

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

# Swatches for the overlay: background foreground accent + five hues.
theme_palette() {
  [[ -f $1/colors.toml ]] || return 0
  awk -F'"' '/^(background|foreground|accent|red|yellow|green|blue|magenta) *=/ { sub(/ .*/, "", $1); c[$1] = $2 }
    END { n = split("background foreground accent red yellow green blue magenta", k, " ")
          for (i = 1; i <= n; i++) if (c[k[i]] != "") printf "%s%s", (o++ ? " " : ""), c[k[i]] }' "$1/colors.toml"
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

# ── Бар ────────────────────────────────────────────────────────────────
# Файлы пишем на месте (cp поверх), а не mv: бар и шелл следят за ними через
# FileView, и подмена inode может оборвать слежку. Временные файлы — с
# фиксированными именами в $RUN_DIR, их просто перезаписывает следующий вызов.

# jq-фильтр поверх $TW_FILE (нет файла — начинаем с {}).
skin_edit() {
  local tmp="$RUN_DIR/tweak.tmp"
  { [[ -s $TW_FILE ]] && cat "$TW_FILE" || echo '{}'; } | jq "$@" >"$tmp" && cp "$tmp" "$TW_FILE"
}

shell_edit() {
  local tmp="$RUN_DIR/shell.tmp"
  jq "$@" "$SHELL_JSON" >"$tmp" && cp "$tmp" "$SHELL_JSON"
}

# Стоковый флаг transparent живёт в shell.json; пишем, только если он меняется,
# чтобы зря не дёргать перечитывание всего конфига шелла.
set_transparent() {
  [[ $(jq -r '.bar.transparent // false' "$SHELL_JSON") == "$1" ]] && return 0
  shell_edit --argjson t "$1" '.bar.transparent = $t'
}

skin_canon() { jq -S 'del(.note)' "$1" 2>/dev/null; }

# Имя пресета, совпадающего с активным скином, иначе custom (stock, если файла нет).
current_skin() {
  [[ -s $BAR_SKIN ]] || { echo stock; return; }
  local f cur
  cur=$(skin_canon "$BAR_SKIN")
  for f in "$BAR_DIR"/skins/*.json; do
    [[ $(skin_canon "$f") == "$cur" ]] && { basename "$f" .json; return; }
  done
  echo custom
}

layout_canon() { jq -S '{position: (.position // "top"), centerAnchor: (.centerAnchor // ""), layout}' "$@" 2>/dev/null; }

current_layout() {
  local f cur
  cur=$(jq '.bar' "$SHELL_JSON" | layout_canon)
  for f in "$BAR_DIR"/layouts/*.json; do
    [[ $(layout_canon "$f") == "$cur" ]] && { basename "$f" .json; return; }
  done
  echo custom
}

# Краткая сводка раскладки для заметки: "top · L: menu workspaces · C: clock · R: …".
layout_summary() {
  jq -r '[(.position // "top"),
          ("L: " + ([.layout.left[]?.id | sub("^[a-z]+\\."; "")] | join(" "))),
          ("C: " + ([.layout.center[]?.id | sub("^[a-z]+\\."; "")] | join(" "))),
          ("R: " + ([.layout.right[]?.id | sub("^[a-z]+\\."; "")] | join(" ")))] | join("  ·  ")' "$1"
}

# Параметры Bar Tweaks: ключ|тип|аргументы|подпись. Дефолты совпадают с BarSkin.qml:
# у num последнее число, у enum первое слово, у color/bool — сами аргументы.
TWEAKS=(
  "shape|enum|full floating pill islands notch underline hug|Форма"
  "height|num|0 48 2 0|Высота"
  "gap|num|0 24 2 0|Отступ от края экрана"
  "margin|num|0 300 10 0|Поля слева/справа"
  "width|num|0.3 1 0.05 1|Ширина (floating/pill/notch)"
  "radius|num|0 24 2 0|Скругление (hug: углы)"
  "padding|num|-1 40 2 -1|Отступ модулей от краёв"
  "islandGap|num|0 20 2 0|Поля островов"
  "background|color|bar|Фон"
  "backgroundAlpha|num|-1 1 0.05 -1|Альфа фона"
  "gradient|color|none|Градиент: второй цвет"
  "border|color|accent|Рамка"
  "borderWidth|num|0 4 1 0|Толщина рамки"
  "borderAlpha|num|0 1 0.1 1|Альфа рамки"
  "text|color|bar|Текст"
  "active|color|bar|Цвет «внимания» (запись, апдейты)"
  "moduleStyle|enum|plain pills hover|Подложка модулей"
  "moduleBackground|color|foreground|Цвет подложки модулей"
  "moduleAlpha|num|0 1 0.02 0.08|Альфа подложки модулей"
  "spacing|num|0 20 2 0|Зазор между модулями"
  "shadow|bool|false|Тень"
  "glow|bool|false|Свечение цветом рамки"
  "autoHide|bool|false|Авто-скрытие (выезжает по наведению)"
  "transparent|bool|false|Прозрачный (сток, текст по обоям)"
  "font|font||Шрифт"
  "wsLabelStyle|enum|omarchy numbers circled circled-filled circled-sans circled-sans-filled parens fullwidth superscript roman roman-small kanji greek cyrillic braille dots squares diamonds stars triangles hearts hexagons bars none|Workspaces: подписи"
  "wsWindowIcons|bool|false|Workspaces: иконки окон"
  "wsIconStyle|enum|color mono tinted accent bubble faded glyph letter dots count|Workspaces: стиль иконок окон"
  "wsMaxIcons|num|1 8 1 3|Workspaces: иконок на workspace (дальше +N)"
  "wsDedupe|bool|true|Workspaces: одно приложение — одна иконка"
  "wsShown|num|1 10 1 5|Workspaces: сколько видно всегда"
  "wsShowEmpty|bool|true|Workspaces: показывать пустые"
  "wsActivePill|bool|false|Workspaces: плашка под активным"
  "compact|enum|off single fullscreen always|Compact: когда сжимать"
  "compactHeight|num|0 40 2 22|Compact: высота"
  "compactModules|enum|essentials all center minimal|Compact: какие модули видны"
  "compactShape|enum|full same floating pill notch underline hug|Compact: форма"
  "compactAlpha|num|-1 1 0.05 -1|Compact: альфа фона"
  "compactReserve|enum|keep shrink|Compact: место под баром"
  "compactExpandOnHover|bool|true|Compact: разворачивать по наведению"
)

# Как показывать дефолт в подписи: особые значения — словами.
default_label() {
  case "$1:$2" in
  height:0) echo "авто" ;;
  ownerMessage:) echo "Привет, $USER" ;;
  avatar:) echo "~/.face (или первая буква имени)" ;;
  wallpaperBlur:1) echo "1 (как в стоке)" ;;
  expandedWidth:0 | expandedHeight:0 | sliceWidth:0 | sliceHeight:0) echo "из стиля" ;;
  cardRadius:-1) echo "из стиля" ;;
  scrimAlpha:-1) echo "из темы" ;;
  duration:420) echo "420 (как в стоке)" ;;
  compactHeight:0) echo "не менять" ;;
  compactAlpha:-1) echo "как обычно" ;;
  compact:off) echo "выкл" ;;
  compact:single) echo "одно окно на workspace" ;;
  compact:fullscreen) echo "полноэкранное окно" ;;
  compact:always) echo "всегда" ;;
  compactModules:essentials) echo "essentials (меню, workspaces, часы, сеть, звук, питание)" ;;
  compactModules:center) echo "center (только центр)" ;;
  compactModules:minimal) echo "minimal (workspaces + часы)" ;;
  compactModules:all) echo "all (все)" ;;
  compactShape:same) echo "same (как обычно)" ;;
  compactReserve:keep) echo "keep (прежнее, окна не дёргаются)" ;;
  compactReserve:shrink) echo "shrink (окна получают место)" ;;
  padding:-1) echo "сток" ;;
  backgroundAlpha:-1) echo "из темы" ;;
  gradient:none) echo "нет" ;;
  font:) echo "системный" ;;
  *:bar) echo "bar (цвет темы)" ;;
  *) echo "$2" ;;
  esac
}

# Параметры экрана блокировки (Lock Tweaks) — те же типы, файл lock-design.json.
LOCK_TWEAKS=(
  "clock24|bool|true|Часы: 24 часа"
  "showSeconds|bool|false|Часы: секунды"
  "showDate|bool|true|Дата"
  "wallpaperBlur|num|0 1 0.1 1|Обои: размытие"
  "wallpaperDim|num|0 0.9 0.05 0|Обои: затемнение"
  "reduceMotion|bool|false|Меньше анимации"
  "ownerMessage|text||Приветствие"
  "avatar|file||Аватар"
)

# Настройки переходов обоев — строки tweak:<key> в категории Wallpaper FX.
FX_TWEAKS=(
  "duration|num|100 3000 50 420|Длительность, мс"
  "easing|enum|InOutCubic InOutQuad InOutQuart InOutSine InOutExpo OutCubic OutExpo OutQuint OutBack OutBounce OutElastic InCubic InExpo Linear|Кривая"
  "angle|num|0 345 15 0|Угол (wipe, wave, slide)"
  "origin|enum|center cursor random|Откуда круг/капля"
  "softness|num|0 0.2 0.01 0.02|Мягкость края"
)

# Вид пикера тем и обоев — строки tweak:<key> в категории Theme Switcher.
# 0 / -1 = значение из стиля-пресета или темы (ключ в файле тогда не хранится).
PICKER_TWEAKS=(
  "expandedWidth|num|0 1600 20 0|Ширина выбранной"
  "expandedHeight|num|0 1000 20 0|Высота выбранной"
  "sliceWidth|num|0 600 10 0|Ширина соседних"
  "sliceHeight|num|0 900 10 0|Высота соседних"
  "cardRadius|num|-1 40 2 -1|Скругление"
  "dim|num|0 0.9 0.05 0.42|Затемнение соседних"
  "selectedBorder|num|0 8 1 3|Рамка выбранной"
  "animMs|num|0 600 20 160|Анимация перелистывания, мс"
  "scrimAlpha|num|-1 1 0.05 -1|Затемнение фона"
  "labels|bool|false|Подписи всегда"
  "autoCache|bool|false|Кэшировать обои при смене темы"
)

tweak_spec() {
  local t
  for t in "${TWEAKS[@]}" "${LOCK_TWEAKS[@]}" "${FX_TWEAKS[@]}" "${PICKER_TWEAKS[@]}"; do [[ ${t%%|*} == "$1" ]] && { echo "$t"; return; }; done
  return 1
}

# Какой файл правит параметр: lock-design.json для LOCK_TWEAKS, иначе bar-skin.json.
tweak_file() {
  local t
  for t in "${LOCK_TWEAKS[@]}"; do [[ ${t%%|*} == "$1" ]] && { echo "$LOCK_CFG"; return; }; done
  for t in "${FX_TWEAKS[@]}"; do [[ ${t%%|*} == "$1" ]] && { echo "$FX_CFG"; return; }; done
  for t in "${PICKER_TWEAKS[@]}"; do [[ ${t%%|*} == "$1" ]] && { echo "$PICKER_CFG"; return; }; done
  echo "$BAR_SKIN"
}

# Роли для цветовых параметров: стоковый цвет бара, роли шелла и ключи colors.toml темы.
color_roles() {
  local colors="$HOME/.local/state/omarchy/current/theme/colors.toml"
  printf '%s\n' bar background foreground accent muted urgent
  awk -F'=' '/^[a-z_]+ *= *"#/ { gsub(/ /, "", $1); print $1 }' "$colors" 2>/dev/null |
    grep -vxE 'background|foreground|accent|muted'
}

font_list() {
  echo ""
  fc-list : family | tr ',' '\n' | grep -iE 'nerd font$|( |^)NF$' | sort -u
}

tweak_value() {
  local key=$1 def=$2
  if [[ $key == transparent ]]; then jq -r '.bar.transparent // false' "$SHELL_JSON"; return; fi
  { [[ -s $TW_FILE ]] && cat "$TW_FILE" || echo '{}'; } |
    jq -r --arg k "$key" --arg d "$def" 'if has($k) and .[$k] != null then .[$k] | tostring else $d end'
}

# Следующий элемент списка по кругу: $1 = текущее, $2 = +1/-1, остальное — список.
cycle() {
  local cur=$1 dir=$2 i n
  shift 2
  local -a list=("$@")
  n=${#list[@]}
  for ((i = 0; i < n; i++)); do [[ ${list[i]} == "$cur" ]] && break; done
  # Не нашли (значение задано руками): вперёд — первый, назад — последний.
  if ((i == n)); then
    if ((dir > 0)); then i=$((n - 1)); else i=0; fi
  fi
  echo "${list[((i + dir + n) % n)]}"
}

tweak() {
  local key=$1 how=$2 spec kind args cur next dir=1
  spec=$(tweak_spec "$key") || exit 1
  TW_FILE=$(tweak_file "$key")
  IFS='|' read -r _ kind args _ <<<"$spec"
  [[ $how == - ]] && dir=-1
  if [[ $how == reset ]]; then
    if [[ $key == transparent ]]; then
      set_transparent false
    fi
    skin_edit --arg k "$key" 'del(.[$k])'
    return
  fi
  case "$kind" in
  enum)
    read -ra list <<<"$args"
    next=$(cycle "$(tweak_value "$key" "${list[0]}")" "$dir" "${list[@]}")
    skin_edit --arg k "$key" --arg v "$next" '.[$k] = $v'
    ;;
  font)
    mapfile -t list < <(font_list)
    next=$(cycle "$(tweak_value "$key" "")" "$dir" "${list[@]}")
    skin_edit --arg k "$key" --arg v "$next" '.[$k] = $v'
    ;;
  bool)
    cur=$(tweak_value "$key" "$args")
    next=$([[ $cur == true ]] && echo false || echo true)
    if [[ $key == transparent ]]; then
      set_transparent "$next"
      skin_edit --argjson v "$next" '.transparent = $v'
    else
      skin_edit --arg k "$key" --argjson v "$next" '.[$k] = $v'
    fi
    ;;
  num)
    local lo hi step def
    read -r lo hi step def <<<"$args"
    cur=$(tweak_value "$key" "$def")
    next=$(awk -v c="$cur" -v d="$dir" -v lo="$lo" -v hi="$hi" -v s="$step" 'BEGIN {
      # -1 = «как в стоке»: шаг вверх от него сразу на ноль.
      if (lo == -1 && c < 0) { v = d > 0 ? 0 : -1 }
      else { v = c + d * s; v = int(v / s + (v >= 0 ? 0.5 : -0.5)) * s; if (lo == -1 && v < 0) v = -1 }
      if (v < lo) v = lo; if (v > hi) v = hi
      if (s == int(s)) printf "%d", v; else { out = sprintf("%.2f", v); sub(/0+$/, "", out); sub(/\.$/, "", out); print out }
    }')
    # Заглушка «из стиля / из темы» — ключ убираем, чтобы работал пресет пикера.
    if [[ $TW_FILE == "$PICKER_CFG" && $next == "$def" && ($def == 0 || $def == -1) ]]; then
      skin_edit --arg k "$key" 'del(.[$k])'
    else
      skin_edit --arg k "$key" --argjson v "$next" '.[$k] = $v'
    fi
    ;;
  text)
    # Только ⏎ (pick): строку вводят в zenity; h/l ничего не делают.
    [[ $how == pick ]] || return 0
    next=$(zenity --entry --title="$key" --text="Текст (пусто — по умолчанию):" \
      --entry-text="$(tweak_value "$key" "")" 2>/dev/null) || exit 0
    if [[ -z $next ]]; then skin_edit --arg k "$key" 'del(.[$k])'; else skin_edit --arg k "$key" --arg v "$next" '.[$k] = $v'; fi
    ;;
  file)
    [[ $how == pick ]] || return 0
    next=$(zenity --file-selection --title="Аватар" --filename="$HOME/" \
      --file-filter="Images | *.jpg *.jpeg *.png *.webp *.JPG *.JPEG *.PNG *.WEBP" 2>/dev/null) || exit 0
    skin_edit --arg k "$key" --arg v "$next" '.[$k] = $v'
    ;;
  color)
    if [[ $how == pick ]]; then
      local picked
      picked=$(zenity --color-selection --title="Bar: $key" 2>/dev/null) || exit 0
      # zenity отдаёт rgb(r,g,b) — переводим в #rrggbb.
      next=$(sed -E 's/rgba?\(([0-9]+),([0-9]+),([0-9]+).*/\1 \2 \3/' <<<"$picked" | xargs printf '#%02x%02x%02x')
    else
      mapfile -t list < <( [[ $key == gradient ]] && echo none; color_roles)
      next=$(cycle "$(tweak_value "$key" "$args")" "$dir" "${list[@]}")
    fi
    if [[ $next == none ]]; then
      skin_edit --arg k "$key" 'del(.[$k])'
    else
      skin_edit --arg k "$key" --arg v "$next" '.[$k] = $v'
    fi
    ;;
  esac
}

# Строки Bar Tweaks / Lock Tweaks: $1 — имя массива параметров, $2 — файл настроек.
list_tweaks() {
  local -n table=$1
  TW_FILE=$2
  local t key kind args label def v hint mark long deflong
  for t in "${table[@]}"; do
    IFS='|' read -r key kind args label <<<"$t"
    case "$kind" in
    num) def=${args##* } hint="h/l или −/+ — шаг $(awk '{print $3}' <<<"$args"), пределы $(awk '{print $1 " … " $2}' <<<"$args")" ;;
    enum) def=${args%% *} hint="h/l — по кругу: $args" ;;
    color) def=$args hint="h/l — роли темы (bar = стоковый цвет бара) · ⏎ — свой цвет" ;;
    bool) def=$args hint="h/l или ⏎ — вкл/выкл" ;;
    font) def="" hint="h/l — Nerd-шрифты из fc-list; пусто = системный" ;;
    text) def="" hint="⏎ — ввести текст" ;;
    file) def="" hint="⏎ — выбрать картинку" ;;
    esac
    v=$(tweak_value "$key" "$def")
    mark=""
    [[ $v != "$def" ]] && mark="●  "
    long=$(default_label "$key" "$v")
    deflong=$(default_label "$key" "$def")
    # В строке списка — короткое значение (до скобки), полностью — в превью.
    # Заметка: литеральные \n, overlay превращает их в переводы строк.
    # 6-е поле — подпись под строкой в списке (по умолчанию).
    printf '%s\t%s\t%s\t0\t%s\t%s\n' "$mark$label:  ${long%% (*}" "$key" "$TW_FILE" \
      "Сейчас: $long"'\n'"По умолчанию: $deflong"'\n\n'"$hint · x — сбросить к умолчанию" \
      "по умолчанию: ${deflong%% (*}"
  done
}

lock_current() { jq -r '.design // "classic"' "$LOCK_CFG" 2>/dev/null || echo classic; }

# Имя файла превью: "my:Foo.qml" -> "my-Foo.qml".
lock_thumb_name() { tr -c 'A-Za-z0-9._\n-' '-' <<<"$1"; }

lock_edit() {
  TW_FILE="$LOCK_CFG"
  skin_edit "$@"
}

# Снимает каждый дизайн через превью экрана блокировки (без блокировки).
lock_thumbs() {
  mkdir -p "$LOCK_THUMBS"
  notify-send -t 3000 "Lock" "Снимаю превью дизайнов…"
  local id
  {
    jq -r '.[].id' "$LOCK_PLUGIN/designs/designs.json"
    for f in "$LOCK_USER_DIR"/*.qml; do [[ -f $f ]] && echo "my:$(basename "$f")"; done
  } | while read -r id; do
    omarchy-shell lock previewDesign "$id" >/dev/null
    sleep 1.5
    grim -s 1 -t jpeg -q 90 "$LOCK_THUMBS/$(lock_thumb_name "$id").jpg"
  done
  omarchy-shell lock hidePreview >/dev/null
  notify-send -t 3000 "Lock" "Превью обновлены"
}

# Миниатюры пикеров заранее: theme switcher (все темы) и обои текущей темы.
# Каталоги — ровно те же, что передают omarchy-theme-switcher / omarchy-theme-bg-switcher:
# ключ кэша строк omarchy-menu-images — md5 списка каталогов.
picker_cache() {
  local start before after theme
  start=$(date +%s)
  before=$(find "$PICKER_CACHE" -maxdepth 1 -name '*.jpg' 2>/dev/null | wc -l)
  notify-send -t 3000 "Theme Switcher" "Кэширую миниатюры…"
  # --preload готовит previews/ (по превью на тему) и прогревает overlay.
  omarchy-theme-switcher --preload >/dev/null 2>&1
  omarchy-menu-images --cache-only "${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/theme-selector/previews" >/dev/null 2>&1
  theme=$(theme_name)
  omarchy-menu-images --cache-only "$HOME/.local/state/omarchy/current/theme/backgrounds" \
    "$HOME/.config/omarchy/backgrounds/$theme" >/dev/null 2>&1
  after=$(find "$PICKER_CACHE" -maxdepth 1 -name '*.jpg' 2>/dev/null | wc -l)
  notify-send -t 4000 "Theme Switcher" "Готово за $(($(date +%s) - start)) с: новых миниатюр $((after - before))"
}

# Миниатюры, чей исходник исчез или изменился (размер:mtime не совпадает с index.tsv),
# удаляются; индекс переписывается. --dry-run только считает. Работает строго внутри
# $PICKER_CACHE (realpath-проверка).
picker_prune() {
  python3 - "$PICKER_CACHE" "${1:-}" <<'PRUNE'
import os, sys
cache = os.path.realpath(sys.argv[1])
dry = sys.argv[2] == "--dry-run"
index = os.path.join(cache, "index.tsv")
keep, lines = set(), []
try:
    for line in open(index, encoding="utf-8", errors="replace"):
        parts = line.rstrip("\n").split("\t")
        if len(parts) != 3:
            continue
        path, sig, h = parts
        try:
            st = os.stat(path)
        except OSError:
            continue
        if f"{st.st_size}:{int(st.st_mtime)}" == sig:
            keep.add(h + ".jpg")
            lines.append(line if line.endswith("\n") else line + "\n")
except FileNotFoundError:
    pass
# Всё, на что ссылаются кэши строк (*.rows), тоже оставляем.
for name in os.listdir(cache):
    if name.endswith(".rows"):
        for row in open(os.path.join(cache, name), encoding="utf-8", errors="replace"):
            cols = row.rstrip("\n").split("\t")
            if len(cols) == 2:
                keep.add(os.path.basename(cols[1]))
count = size = 0
for name in os.listdir(cache):
    if not name.endswith(".jpg") or name in keep:
        continue
    full = os.path.join(cache, name)
    if not os.path.realpath(full).startswith(cache + os.sep) or not os.path.isfile(full):
        continue
    count += 1
    size += os.path.getsize(full)
    if not dry:
        os.remove(full)
if not dry:
    tmp = index + ".prune.tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.writelines(dict.fromkeys(lines))
    os.replace(tmp, index)
verb = "Можно удалить" if dry else "Удалено"
print(f"{verb}: {count} миниатюр, {size / 1024**3:.1f} ГБ; останется {len(keep)}")
PRUNE
}

bar_skin_preview() {
  cp "$1" "$BAR_SKIN"
  set_transparent "$(jq -r '.transparent // false' "$1")"
}

bar_skin_restore() {
  # Overlay зовёт это только после превью, так что снимок свежий.
  [[ -f $SKIN_BACKUP ]] && cp "$SKIN_BACKUP" "$BAR_SKIN"
  [[ -f $TRANSPARENT_BACKUP ]] && set_transparent "$(cat "$TRANSPARENT_BACKUP")"
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
  bar-layouts)
    local f cur
    cur=$(current_layout)
    printf '%s\t%s\t\t0\t%s\n' "💾 Сохранить текущую как пресет…" "save" \
      "Записать раскладку из shell.json в apps/omarchy-shell/bar/layouts/<имя>.json."
    for f in "$BAR_DIR"/layouts/*.json; do
      [[ -f $f ]] || continue
      printf '%s\t%s\t%s\t%s\t%s\n' "$(basename "$f" .json)" "$f" "$f" \
        "$([[ $(basename "$f" .json) == "$cur" ]] && echo 1 || echo 0)" \
        "$(jq -r '.note // ""' "$f")  ·  $(layout_summary "$f")"
    done
    ;;
  bar-skins)
    # Снимок того, что сейчас на баре; превью перезаписывают его до bar-skins-restore.
    if [[ -s $BAR_SKIN ]]; then cp "$BAR_SKIN" "$SKIN_BACKUP"; else echo '{}' >"$SKIN_BACKUP"; fi
    jq -r '.bar.transparent // false' "$SHELL_JSON" >"$TRANSPARENT_BACKUP"
    local f cur
    cur=$(current_skin)
    for f in "$BAR_DIR"/skins/*.json; do
      [[ -f $f ]] || continue
      printf '%s\t%s\t%s\t%s\t%s\n' "$(basename "$f" .json)" "$f" "$f" \
        "$([[ $(basename "$f" .json) == "$cur" ]] && echo 1 || echo 0)" "$(jq -r '.note // ""' "$f")"
    done
    ;;
  bar-tweaks) list_tweaks TWEAKS "$BAR_SKIN" ;;
  lock-tweaks) list_tweaks LOCK_TWEAKS "$LOCK_CFG" ;;
  wallpaper-fx)
    # Сначала настройки (строки tweak:<key>), потом эффекты.
    list_tweaks FX_TWEAKS "$FX_CFG" | awk -F'\t' 'BEGIN { OFS = "\t" } { $2 = "tweak:" $2; print }'
    local cur e desc
    cur=$(jq -r '.type // "slant"' "$FX_CFG" 2>/dev/null || echo slant)
    while IFS='|' read -r e desc; do
      printf '%s\t%s\t\t%s\t%s\n' "$e" "$e" "$([[ $e == "$cur" ]] && echo 1 || echo 0)" "$desc"'\n\n'"⏎ — выбрать · p — проиграть на рабочем столе"
    done <<'EFFECTS'
slant|Косая шторка от центра — как в стоке Omarchy
fade|Плавное растворение
wipe|Шторка по направлению «Угол»
wave|Шторка с волнистым краем
grow|Круг растёт из точки (center / cursor / random)
outer|Круг сжимается к точке — новые обои приходят с краёв
diamond|Ромб из точки
clock|Радиальная развёртка, как стрелка часов
blinds|Жалюзи
doors|Двери: раскрытие от середины
mosaic|Квадраты в случайном порядке
dissolve|Пиксельный шум
pixelize|Укрупнение пикселей и обратно
ripple|Круги на воде
swirl|Закрутка к центру
crosszoom|Радиальное размытие с приближением
slide|Новые обои выталкивают старые (по «Углу»)
zoom|Старые улетают вперёд, новые проявляются
glitch|Рваные полосы и разъезд каналов
burn|Прогорание пятнами с раскалённым краем
waterdrop|Капля: волны от точки с затуханием
hexagon|Соты открываются от центра
random|Каждый раз случайный эффект
none|Без анимации
EFFECTS
    ;;
  theme-switcher)
    printf '%s\t%s\t\t0\t%s\n' "⚡ Закэшировать миниатюры" "cache" \
      "Сделать миниатюры для theme switcher (все темы) и для обоев текущей темы заранее, чтобы пикеры открывались сразу."'\n\n'"Кэш: $PICKER_CACHE ($(du -sh "$PICKER_CACHE" 2>/dev/null | cut -f1))"
    printf '%s\t%s\t\t0\t%s\n' "🧹 Очистить неиспользуемые миниатюры" "prune" \
      "Удалить миниатюры картинок, которых больше нет или которые изменились. Миниатюры существующих картинок остаются."'\n\n'"$(picker_prune --dry-run 2>/dev/null)"
    list_tweaks PICKER_TWEAKS "$PICKER_CFG" | awk -F'\t' 'BEGIN { OFS = "\t" } { $2 = "tweak:" $2; print }'
    local cur st desc
    cur=$(jq -r '.style // "slices"' "$PICKER_CFG" 2>/dev/null || echo slices)
    while IFS='|' read -r st desc; do
      printf '%s\t%s\t\t%s\t%s\n' "$st" "style:$st" "$([[ $st == "$cur" ]] && echo 1 || echo 0)" "$desc"'\n\n'"⏎ — выбрать · p — открыть theme switcher"
    done <<'STYLES'
slices|Скошенные ломтики — как в стоке Omarchy
cards|Ровные карточки со скруглением
coverflow|Соседи повёрнуты в 3D, как в iTunes
strip|Лента одинаковых карточек, выбранная крупнее
wide|Огромное превью и тонкие ломтики
polaroid|Карточки в белой рамке с подписью
STYLES
    ;;
  lock)
    local cur id name file thumb
    cur=$(lock_current)
    printf '%s\t%s\t\t0\t%s\n' "🔄 Обновить превью всех дизайнов  (T)" "regen-thumbs" \
      "Дизайны по очереди покажутся на экране (≈1,5 с каждый) и снимутся в цветах текущей темы."
    jq -r '.[] | [.id, .name, .description, (.tags | join(" · "))] | @tsv' "$LOCK_PLUGIN/designs/designs.json" |
      while IFS=$'\t' read -r id name desc tags; do
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$id" "$LOCK_THUMBS/$(lock_thumb_name "$id").jpg" \
          "$([[ $id == "$cur" ]] && echo 1 || echo 0)" "$desc"'\n\n'"p — показать вживую · ⏎ — выбрать" "$tags"
      done
    # Свои дизайны: ~/.config/omarchy/lock-designs/*.qml, id my:<файл>.
    for file in "$LOCK_USER_DIR"/*.qml; do
      [[ -f $file ]] || continue
      name=$(basename "$file")
      id="my:$name"
      printf '%s\t%s\t%s\t%s\t%s\t%s\n' "${name%.qml}" "$id" "$LOCK_THUMBS/$(lock_thumb_name "$id").jpg" \
        "$([[ $id == "$cur" ]] && echo 1 || echo 0)" "Свой дизайн: $file"'\n\n'"p — показать вживую · ⏎ — выбрать" "custom"
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
      printf '%s\t%s\t%s\t%s\t%s\n' "$label" "$slug" "$(theme_preview "$dir")" "$([[ $slug == "$current" ]] && echo 1 || echo 0)" "$(theme_palette "$dir")"
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
  opacity)
    local n a i cur
    "$OPACITY" list | while read -r n a i cur; do
      printf '%s\t%s\t\t%s\t%s\n' "$n  ($a / $i)" "$n" "$cur" \
        "active_opacity = $a · inactive_opacity = $i"
    done
    ;;
  blur)
    local n sz ps v no cur
    "$BLUR" list | while read -r n sz ps v no cur; do
      if ((sz == 0)); then
        printf '%s\t%s\t\t%s\t%s\n' "$n  (no blur)" "$n" "$cur" "size 0 passes 0 vibrancy 0 noise 0"
      else
        printf '%s\t%s\t\t%s\t%s\n' "$n  ($sz × $ps)" "$n" "$cur" "size $sz passes $ps vibrancy $v noise $no"
      fi
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
  bar-layouts)
    if [[ $value == save ]]; then
      local name
      name=$(zenity --entry --title="Bar layout" --text="Имя пресета:" 2>/dev/null) || exit 0
      name=$(tr -cs 'A-Za-z0-9_-' '-' <<<"$name" | sed 's/^-*//; s/-*$//')
      [[ -n $name ]] || exit 0
      jq --arg n "Сохранено $(date +%F)" '.bar | {note: $n, position, centerAnchor, layout}' "$SHELL_JSON" \
        >"$BAR_DIR/layouts/$name.json"
      notify-send -t 2000 "Bar Layout" "Saved: $name"
      exit 0
    fi
    # shell.json перечитывается на лету, рестарт шелла не нужен (он убил бы и overlay).
    # Остальное (plugins, idle, bar.id, transparent) не трогаем.
    shell_edit --slurpfile p "$value" '.bar += ($p[0] | del(.note))'
    notify-send -t 2000 "Bar Layout" "Applied: $(basename "$value" .json)"
    ;;
  bar-skins)
    bar_skin_preview "$value"
    cp "$BAR_SKIN" "$SKIN_BACKUP"
    notify-send -t 2000 "Bar Skin" "Applied: $(basename "$value" .json)"
    ;;
  bar-tweaks | lock-tweaks) tweak "$value" pick ;;
  wallpaper-fx)
    if [[ $value == tweak:* ]]; then tweak "${value#tweak:}" pick; exit 0; fi
    TW_FILE="$FX_CFG"
    skin_edit --arg t "$value" '.type = $t'
    notify-send -t 2000 "Wallpaper FX" "Переход: $value"
    ;;
  theme-switcher)
    case "$value" in
    tweak:*) tweak "${value#tweak:}" pick ;;
    cache) picker_cache ;;
    prune)
      local info
      info=$(picker_prune --dry-run)
      zenity --question --title="Кэш миниатюр" --text="$info\n\nУдалить?" 2>/dev/null || exit 0
      notify-send -t 4000 "Theme Switcher" "$(picker_prune)"
      ;;
    style:*)
      TW_FILE="$PICKER_CFG"
      skin_edit --arg s "${value#style:}" '.style = $s'
      notify-send -t 2000 "Theme Switcher" "Стиль: ${value#style:}"
      ;;
    esac
    ;;
  lock)
    if [[ $value == regen-thumbs ]]; then lock_thumbs; exit 0; fi
    lock_edit --arg d "$value" '.design = $d'
    notify-send -t 2000 "Lock" "Дизайн: $value"
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
  opacity) "$OPACITY" set "$value" ;;
  blur) "$BLUR" set "$value" ;;
  esac
}

# One worker per source: $1 = image path. Skips thumbs newer than the source.
thumb_one() {
  local t
  t="$THUMB_DIR/$(printf %s "$1" | md5sum | cut -d' ' -f1).jpg"
  [[ -f $t && ! $1 -nt $t ]] && return 0
  vipsthumbnail "$1" --size 320x200 -o "$t[Q=82]" 2>/dev/null
}

thumbs() {
  mkdir -p "$THUMB_DIR"
  export THUMB_DIR
  export -f thumb_one
  list "$1" | cut -f3 | grep -v '^$' | xargs -d '\n' -P "$(nproc)" -I{} bash -c 'thumb_one "$1"' _ {}
}

status() {
  local anim=custom f
  for f in "$ANIM_DIR"/*.lua; do
    [[ -f $f ]] && cmp -s "$f" "$ANIM_ACTIVE" && { anim=$(basename "$f" .lua); break; }
  done
  printf 'theme\t%s\n' "$(theme_name)"
  printf 'wallpaper\t%s\n' "$(readlink -f "$HOME/.local/state/omarchy/current/background" 2>/dev/null)"
  printf 'anims\t%s\n' "$anim"
  printf 'shader\t%s\n' "$(current_shader)"
  printf 'opacity\t%s\n' "$("$OPACITY" current 2>/dev/null)"
  printf 'blur\t%s\n' "$("$BLUR" current 2>/dev/null)"
  printf 'bar-skin\t%s\n' "$(current_skin)"
  printf 'bar-layout\t%s\n' "$(current_layout)"
  printf 'lock\t%s\n' "$(lock_current)"
  printf 'fx\t%s\n' "$(jq -r '.type // "slant"' "$FX_CFG" 2>/dev/null || echo slant)"
  # Для макетов в превью: вторые обои темы и 7 превью тем вокруг текущей.
  local cur_bg
  cur_bg=$(readlink -f "$HOME/.local/state/omarchy/current/background" 2>/dev/null)
  printf 'wallpaper-next\t%s\n' "$(images_in "$(dirname "$cur_bg")" 1 | grep -vxF "$cur_bg" | head -n 1)"
  printf 'picker-previews\t%s\n' "$(find -L "${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/theme-selector/previews" -maxdepth 1 -type f 2>/dev/null |
    sort | awk -v cur="$(theme_name)" '{ a[NR] = $0; n = $0; sub(/.*\//, "", n); sub(/\.[^.]+$/, "", n); if (n == cur) c = NR }
      END { if (!c) c = 4; s = c - 3; if (s < 1) s = 1; e = s + 6; if (e > NR) e = NR
            for (i = s; i <= e; i++) printf "%s%s", (i > s ? "|" : ""), a[i] }')"
  # Numbers for the preview stage: "active inactive" / "size passes vibrancy noise".
  printf 'opacity-values\t%s\n' "$("$OPACITY" list 2>/dev/null | awk '$4 == 1 { print $2, $3 }')"
  printf 'blur-values\t%s\n' "$("$BLUR" list 2>/dev/null | awk '$6 == 1 { print $2, $3, $4, $5 }')"
}

mkdir -p "$RUN_DIR"
case "${1:-}" in
list) list "${2:-}" ;;
status) status ;;
thumbs) thumbs "${2:-}" ;;
opacity-preview) "$OPACITY" preview "$2" ;;
opacity-restore) "$OPACITY" restore ;;
blur-preview) "$BLUR" preview "$2" ;;
blur-restore) "$BLUR" restore ;;
bar-skins-preview) bar_skin_preview "$2" ;;
bar-skins-restore) bar_skin_restore ;;
tweak) tweak "$2" "${3:-+}" ;;
lock-preview) omarchy-shell lock previewDesign "${2:-}" >/dev/null ;;
lock-thumbs) lock_thumbs ;;
fx-replay) omarchy-shell background replay >/dev/null ;;
picker-cache) picker_cache ;;
picker-open) setsid -f omarchy-theme-switcher >/dev/null 2>&1 ;;
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
  echo "usage: $0 list|status|thumbs|anim-preview|anim-restore|opacity-preview|opacity-restore|blur-preview|blur-restore|bar-skins-preview|bar-skins-restore|tweak|apply ..." >&2
  exit 1
  ;;
esac
