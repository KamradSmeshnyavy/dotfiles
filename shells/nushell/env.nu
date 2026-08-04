$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# Импорт переменных из systemd user environment
def --env import_systemd_env [] {
  let ppid = ($env | get -o PPID | default "")
  if ($ppid | is-empty) { return }
  let env_file = $"/proc/($ppid)/environ"
  if ($env_file | path exists) {
    open $env_file | split row "\0" | each { |line|
      let parts = ($line | split column "=" key value)
      if ($parts | length) > 0 and ($parts.key.0 | is-not-empty) and ($parts.key.0 not-in $env) {
        load-env {($parts.key.0): ($parts.value.0)}
      }
    }
  }
}
import_systemd_env

# Принудительный запуск Firefox в нативной среде Wayland
$env.MOZ_ENABLE_WAYLAND = "1"

# Использование драйвера intel-media-driver для VA-API (важно для Lunar Lake)
$env.LIBVA_DRIVER_NAME = "iHD"
# Переменные окружения из Zsh
$env.EDITOR = "nvim"
$env.GOPATH = $"($env.HOME)/go"
$env.MOZ_ENABLE_WAYLAND = "1"
$env._JAVA_OPTIONS = "-Dsun.java2d.uiScale=2"
$env.OMARCHY_PATH = $"($env.HOME)/.local/share/omarchy"
$env.BAT_THEME = "ansi"
$env.MANPAGER = "sh -c 'col -bx | bat -l man -p'"
$env.KUBECONFIG = $"($env.HOME)/.kube/config"
$env.EZA_CONFIG_DIR = $"($env.HOME)/.config/eza"
$env.YAZI_CONFIG_HOME = $"($env.HOME)/.config/yazi"
$env.NIX_CONF_DIR = $"($env.HOME)/.config/nix"
$env.FUNCNEST = "700"
$env.LANG = "en_US.UTF-8"

# Добавление путей из Zsh в Nushell PATH
$env.PATH = ($env.PATH | prepend [
    "/sbin"
    "/usr/sbin"
] | append [
    "/home/kamradsmeshnyavy/.local/bin"
    "/home/kamradsmeshnyavy/.pyenv/shims"
    "/home/kamradsmeshnyavy/.nix-profile/bin"
    "/run/current-system/sw/bin"
    "/home/kamradsmeshnyavy/.cargo/bin"
    "/bin"
    "/usr/bin"
    "/usr/local/bin"
    "/home/kamradsmeshnyavy/.local/share/mise/shims"
    "/home/kamradsmeshnyavy/.local/share/omarchy/bin"
    "/usr/local/sbin"
    "/usr/lib/jvm/default/bin"
    "/usr/bin/site_perl"
    "/usr/bin/vendor_perl"
    "/usr/bin/core_perl"
    "/home/kamradsmeshnyavy/.spoofdpi/bin"
]) | uniq

# Mise integration
source ./mise.nu

# Используем встроенные в систему цвета dircolors
if ('/usr/bin/dircolors' | path exists) {
    # $env.LS_COLORS = (dircolors -b | lines | first | str replace 'LS_COLORS=' '' | str replace -r ';$' '' | str replace -r '^[\x27"]' '' | str replace -r '[\x27"]$' '')
    $env.LS_COLORS = (($env.LS_COLORS? | default "") + ":ow=97;100:tw=97;100:")
    # $env.LS_COLORS = (($env.LS_COLORS? | default "") + ":ow=01;34:tw=01;34:")
}

