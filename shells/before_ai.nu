let primary_autoload_dir = ($nu.data-dir | path join "vendor" "autoload")
let fallback_autoload_dir = ($env.HOME | path join ".cache" "nushell" "autoload")

let autoload_dir = (try {
  mkdir $primary_autoload_dir
  $primary_autoload_dir
} catch {
  try { mkdir $fallback_autoload_dir } catch { }
  $fallback_autoload_dir
})

# Prompt Theme, use oh-my-posh or starship
let ohmyposh_autoload = ($autoload_dir | path join "oh-my-posh.nu")
let starship_autoload = ($autoload_dir | path join "starship.nu")

let PROMPT_THEME = "starship"
let OH_MY_POSH_THEME = "zen.toml"

match $PROMPT_THEME {
  "oh-my-posh" => {
    try { rm --force $starship_autoload } catch { }
    oh-my-posh init nu --config $"~/.config/ohmyposh/($OH_MY_POSH_THEME)"
  }
  "starship" => {
    try { rm --force $ohmyposh_autoload } catch { }
    try { starship init nu | save -f $starship_autoload } catch { }
  }
}

source ./tv.nu
source ./atuin.nu
source ./zoxide.nu


# plugins.nu
#
#
# env.nu










$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""

# let starship_cache_dir = ($env.HOME | path join ".cache" "starship")
# let init_path = ($starship_cache_dir | path join "init.nu")

# try { mkdir $starship_cache_dir } catch { }
# try { starship init nu | save -f $init_path } catch { }

# if ("~/.cache/starship/init.nu" | path expand | path exists) {
# 	try { source ~/.cache/starship/init.nu } catch { }
# }

