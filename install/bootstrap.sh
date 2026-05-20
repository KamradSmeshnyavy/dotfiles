#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$ROOT/packages"

info() { echo "[INFO] $*"; }
error() { echo "[ERROR] $*" >&2; }
warn() { echo "[WARN] $*" >&2; }

read_list() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  grep -Ehv '^[[:space:]]*#' "$file" | awk 'NF'
}

require_os() {
  if [[ "$OSTYPE" == darwin* ]]; then
    echo "macos"
    return 0
  fi

  if [[ "$OSTYPE" == linux* ]]; then
    if [[ -f /etc/os-release ]]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      local id_lower="${ID,,}"
      local like_lower="${ID_LIKE:-}"; like_lower="${like_lower,,}"
      local name_lower="${NAME:-}"; name_lower="${name_lower,,}"

      if [[ "$id_lower" == "omarchy" || "$name_lower" == *"omarchy"* || "$id_lower" == "arch" || "$like_lower" == *"arch"* ]]; then
        echo "omarchy"
        return 0
      fi
    fi
  fi

  return 1
}

install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew update

  local brew_list="$PACKAGES_DIR/brew.txt"
  local cask_list="$PACKAGES_DIR/brew-cask.txt"

  mapfile -t brews < <(read_list "$brew_list" || true)
  mapfile -t casks < <(read_list "$cask_list" || true)

  if (( ${#brews[@]} )); then
    info "Installing brew packages..."
    for pkg in "${brews[@]}"; do
      if ! brew install "$pkg"; then
        warn "Failed to install brew package: $pkg"
      fi
    done
  else
    info "No brew packages to install."
  fi

  if (( ${#casks[@]} )); then
    info "Installing brew casks..."
    for cask in "${casks[@]}"; do
      if ! brew install --cask "$cask"; then
        warn "Failed to install brew cask: $cask"
      fi
    done
  else
    info "No brew casks to install."
  fi
}

install_pacman_yay() {
  local pacman_list="$PACKAGES_DIR/pacman.txt"
  local yay_list="$PACKAGES_DIR/yay.txt"

  mapfile -t pacman_pkgs < <(read_list "$pacman_list" || true)
  mapfile -t yay_pkgs < <(read_list "$yay_list" || true)

  if (( ${#pacman_pkgs[@]} )); then
    info "Installing pacman packages..."
    sudo pacman -Syu --needed
    for pkg in "${pacman_pkgs[@]}"; do
      if ! sudo pacman -S --needed "$pkg"; then
        warn "Failed to install pacman package: $pkg"
      fi
    done
  else
    info "No pacman packages to install."
  fi

  if (( ${#yay_pkgs[@]} )); then
    if ! command -v yay >/dev/null 2>&1; then
      info "yay not found. Installing..."
      sudo pacman -S --needed git base-devel
      tmpdir="$(mktemp -d)"
      git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
      pushd "$tmpdir/yay" >/dev/null
      makepkg -si
      popd >/dev/null
      rm -rf "$tmpdir"
    fi

    info "Installing yay (AUR) packages..."
    for pkg in "${yay_pkgs[@]}"; do
      if ! yay -S --needed "$pkg"; then
        warn "Failed to install yay package: $pkg"
      fi
    done
  else
    info "No yay packages to install."
  fi
}

apply_dotfiles() {
  info "Applying dotfiles..."
  if command -v python3 >/dev/null 2>&1; then
    python3 "$ROOT/install.py"
  elif command -v python >/dev/null 2>&1; then
    python "$ROOT/install.py"
  else
    error "Python not found. Install python and retry."
    exit 1
  fi
}

main() {
  if ! os="$(require_os)"; then
    error "Supported OS: macOS and Omarchy (Arch-based)."
    exit 1
  fi

  info "Detected OS: $os"

  echo "Select action:"
  echo "1) Install packages"
  echo "2) Apply dotfiles"
  echo "3) Install packages then apply dotfiles"
  read -r -p "> " choice

  case "$choice" in
    1)
      if [[ "$os" == "macos" ]]; then
        install_brew
      else
        install_pacman_yay
      fi
      ;;
    2)
      apply_dotfiles
      ;;
    3)
      if [[ "$os" == "macos" ]]; then
        install_brew
      else
        install_pacman_yay
      fi
      apply_dotfiles
      ;;
    *)
      error "Unknown option."
      exit 1
      ;;
  esac
}

main "$@"
