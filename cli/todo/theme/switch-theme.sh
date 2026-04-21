#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

apply_edit() {
  local file="$1"
  local expr="$2"
  if [[ -f "$file" ]]; then
    perl -0777 -i -pe "$expr" "$file"
  fi
}

apply_profile_current() {
  apply_edit "$ROOT_DIR/apps/sketchybar/settings.lua" 's/THEME\s*=\s*".*?"/THEME = "catppuccin_mocha"/g'
  apply_edit "$ROOT_DIR/apps/ghostty/config" 's/^theme\s*=\s*.*$/theme = dark:Catppuccin Mocha, light:TokyoNight/m'
  apply_edit "$ROOT_DIR/apps/ghostty/config-b" 's/^theme\s*=\s*.*$/theme = dark:Catppuccin Mocha, light:TokyoNight/m'
  apply_edit "$ROOT_DIR/apps/vscode/settings.json" 's/"catppuccin\.accentColor"\s*:\s*".*?"/"catppuccin.accentColor": "lavender"/g'
  apply_edit "$ROOT_DIR/apps/vscode/settings-back-from-dots.json" 's/"catppuccin\.accentColor"\s*:\s*".*?"/"catppuccin.accentColor": "lavender"/g'
  apply_edit "$ROOT_DIR/tui/tmux/tmux.conf" 's|set -g window-status-current-style ".*"|set -g window-status-current-style "bg=#{@thm_blue},fg=#{@thm_bg},bold"|g'
  apply_edit "$ROOT_DIR/shells/starship.toml" 's/\[directory\]\nstyle\s*=\s*".*?"/[directory]\nstyle = "blue"/s'
  apply_edit "$ROOT_DIR/shells/starship.toml" 's/vimcmd_symbol\s*=\s*"\[❮\]\(.*?\)"/vimcmd_symbol = "[❮](sky)"/g'
  apply_edit "$ROOT_DIR/tui/nvim/lua/config/theme_profile.lua" 's/M\.profile\s*=\s*".*?"/M.profile = "current"/g'
  apply_edit "$ROOT_DIR/tui/zellij/config.kdl" 's/theme\s+".*?"/theme "ctp"/g'
  if [[ -f "$ROOT_DIR/tui/eza/themes/theme-current.yml" ]]; then
    cp "$ROOT_DIR/tui/eza/themes/theme-current.yml" "$ROOT_DIR/tui/eza/theme.yml"
  fi
}

apply_profile_pink() {
  apply_edit "$ROOT_DIR/apps/sketchybar/settings.lua" 's/THEME\s*=\s*".*?"/THEME = "catppuccin_mocha_pink"/g'
  apply_edit "$ROOT_DIR/apps/ghostty/config" 's/^theme\s*=\s*.*$/theme = Catppuccin Mocha/m'
  apply_edit "$ROOT_DIR/apps/ghostty/config-b" 's/^theme\s*=\s*.*$/theme = Catppuccin Mocha/m'
  apply_edit "$ROOT_DIR/apps/vscode/settings.json" 's/"catppuccin\.accentColor"\s*:\s*".*?"/"catppuccin.accentColor": "pink"/g'
  apply_edit "$ROOT_DIR/apps/vscode/settings-back-from-dots.json" 's/"catppuccin\.accentColor"\s*:\s*".*?"/"catppuccin.accentColor": "pink"/g'
  apply_edit "$ROOT_DIR/tui/tmux/tmux.conf" 's|set -g window-status-current-style ".*"|set -g window-status-current-style "bg=#{@thm_pink},fg=#{@thm_bg},bold"|g'
  apply_edit "$ROOT_DIR/shells/starship.toml" 's/\[directory\]\nstyle\s*=\s*".*?"/[directory]\nstyle = "pink"/s'
  apply_edit "$ROOT_DIR/shells/starship.toml" 's/vimcmd_symbol\s*=\s*"\[❮\]\(.*?\)"/vimcmd_symbol = "[❮](pink)"/g'
  apply_edit "$ROOT_DIR/tui/nvim/lua/config/theme_profile.lua" 's/M\.profile\s*=\s*".*?"/M.profile = "pink"/g'
  apply_edit "$ROOT_DIR/tui/zellij/config.kdl" 's/theme\s+".*?"/theme "ctp_pink"/g'
  if [[ -f "$ROOT_DIR/tui/eza/themes/theme-pink.yml" ]]; then
    cp "$ROOT_DIR/tui/eza/themes/theme-pink.yml" "$ROOT_DIR/tui/eza/theme.yml"
  fi
}

cat <<'EOF'
Выбери тему для всех dotfiles:
  1) current
  2) catppuccin-mocha-pink
EOF

read -r -p "Номер профиля [1/2]: " choice

case "$choice" in
  1) profile="current" ;;
  2) profile="catppuccin-mocha-pink" ;;
  *)
    echo "Неверный выбор: $choice"
    exit 1
    ;;
esac

read -r -p "Подтвердить применение профиля '$profile' ко всем поддерживаемым приложениям? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Отменено."
  exit 0
fi

if [[ "$profile" == "current" ]]; then
  apply_profile_current
else
  apply_profile_pink
fi

echo "Готово: профиль '$profile' применён."
