{ config, dotfilesRoot, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    ".config/aerospace".source = link "${dotfilesRoot}/aerospace";
    ".config/atuin".source = link "${dotfilesRoot}/atuin";
    ".config/bat".source = link "${dotfilesRoot}/bat";
    ".config/borders".source = link "${dotfilesRoot}/borders";
    ".config/btop".source = link "${dotfilesRoot}/btop";
    ".config/carapace".source = link "${dotfilesRoot}/carapace";
    ".config/cava".source = link "${dotfilesRoot}/cava";
    ".config/dust".source = link "${dotfilesRoot}/dust";
    ".config/fastfetch".source = link "${dotfilesRoot}/fastfetch";
    ".config/fish".source = link "${dotfilesRoot}/fish";
    ".config/ghostty".source = link "${dotfilesRoot}/ghostty";
    ".config/git".source = link "${dotfilesRoot}/git";
    ".config/helix".source = link "${dotfilesRoot}/helix";
    ".config/karabiner".source = link "${dotfilesRoot}/karabiner";
    ".config/kitty".source = link "${dotfilesRoot}/kitty";
    ".config/lazygit".source = link "${dotfilesRoot}/lazygit";
    ".config/lla".source = link "${dotfilesRoot}/lla";
    ".config/mpd".source = link "${dotfilesRoot}/mpd";
    ".config/nushell".source = link "${dotfilesRoot}/nushell";
    ".config/nvim".source = link "${dotfilesRoot}/nvim";
    ".config/ohmyposh".source = link "${dotfilesRoot}/ohmyposh";
    ".config/procs".source = link "${dotfilesRoot}/procs";
    ".config/rmpc".source = link "${dotfilesRoot}/rmpc";
    ".config/scooter".source = link "${dotfilesRoot}/scooter";
    ".config/sketchybar".source = link "${dotfilesRoot}/sketchybar";
    ".config/skhd".source = link "${dotfilesRoot}/skhd";
    ".config/television".source = link "${dotfilesRoot}/television";
    ".config/tig".source = link "${dotfilesRoot}/tig";
    ".config/tmux".source = link "${dotfilesRoot}/tmux";
    ".config/wezterm".source = link "${dotfilesRoot}/wezterm";
    ".config/yabai".source = link "${dotfilesRoot}/yabai";
    ".config/yazi".source = link "${dotfilesRoot}/yazi";
    ".config/zellij".source = link "${dotfilesRoot}/zellij";

    ".config/starship.toml".source = link "${dotfilesRoot}/starship.toml";
    ".zshrc".source = link "${dotfilesRoot}/zshrc/.zshrc";

    "Library/Application Support/Code/User/settings.json".source = link "${dotfilesRoot}/vscode/settings.json";
    "Library/Application Support/Code/User/keybindings.json".source = link "${dotfilesRoot}/vscode/keybindings.json";
    "Library/Application Support/Code/User/snippets".source = link "${dotfilesRoot}/vscode/snippets";
  };
}