# shellcheck shell=bash
# Translations for the Customizer scripts. Source it, then `t "English text" [args…]`.
# Strings are written in English; i18n/<lang>.json maps them to another language.
# Language: "lang" in ~/.config/omarchy/customizer.json, otherwise $LC_ALL / $LC_MESSAGES / $LANG
# (ru* → ru, anything else → en). Arguments are substituted printf-style (%s).

CUSTOMIZER_DIR=${CUSTOMIZER_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}

ui_lang() {
  local l
  l=$(jq -r '.lang // empty' "$HOME/.config/omarchy/customizer.json" 2>/dev/null)
  [[ -n $l ]] || l=${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}
  case $l in ru*) echo ru ;; *) echo en ;; esac
}

declare -gA I18N=()
UI_LANG=$(ui_lang)
if [[ $UI_LANG != en && -f $CUSTOMIZER_DIR/i18n/$UI_LANG.json ]]; then
  # \x1f between key and value, \x1e after each pair: values may hold \n and tabs.
  while IFS=$'\x1f' read -r -d $'\x1e' k v; do
    I18N[$k]=$v
  done < <(jq -j 'to_entries[] | .key, "\u001f", .value, "\u001e"' "$CUSTOMIZER_DIR/i18n/$UI_LANG.json")
fi

t() {
  local s=${I18N[$1]:-$1}
  shift
  if (($#)); then
    # %s only; escape everything else so a stray % or backslash stays literal.
    s=${s//\\/\\\\}
    s=${s//%/%%}
    s=${s//%%s/%s}
    # shellcheck disable=SC2059
    printf -- "$s" "$@"
  else
    printf '%s' "$s"
  fi
}
