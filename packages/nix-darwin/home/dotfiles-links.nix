{ config, dotfilesRoot, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    ".config/aerospace".source = link "${dotfilesRoot}/apps/aerospace";
    ".config/atuin".source = link "${dotfilesRoot}/tui/atuin";
    ".config/bat".source = link "${dotfilesRoot}/tui/bat";
    ".config/borders".source = link "${dotfilesRoot}/apps/borders";
    ".config/btop".source = link "${dotfilesRoot}/tui/btop";
    ".config/carapace".source = link "${dotfilesRoot}/tui/carapace";
    ".config/cava".source = link "${dotfilesRoot}/tui/cava";
    ".config/dust".source = link "${dotfilesRoot}/tui/dust";
    ".config/fastfetch".source = link "${dotfilesRoot}/tui/fastfetch";
    ".config/fish".source = link "${dotfilesRoot}/shells/fish";
    ".config/ghostty".source = link "${dotfilesRoot}/apps/ghostty";
    ".config/git".source = link "${dotfilesRoot}/tui/git";
    ".config/helix".source = link "${dotfilesRoot}/tui/helix";
    ".config/karabiner".source = link "${dotfilesRoot}/apps/karabiner";
    ".config/kitty".source = link "${dotfilesRoot}/apps/kitty";
    ".config/lazygit".source = link "${dotfilesRoot}/tui/lazygit";
    ".config/lla".source = link "${dotfilesRoot}/tui/lla";
    ".config/mpd".source = link "${dotfilesRoot}/tui/mpd";
    ".config/nushell".source = link "${dotfilesRoot}/shells/nushell";
    ".config/nvim".source = link "${dotfilesRoot}/tui/nvim";
    ".config/ohmyposh".source = link "${dotfilesRoot}/shells/ohmyposh";
    ".config/procs".source = link "${dotfilesRoot}/tui/procs";
    ".config/rmpc".source = link "${dotfilesRoot}/tui/rmpc";
    ".config/scooter".source = link "${dotfilesRoot}/tui/scooter";
    ".config/sketchybar".source = link "${dotfilesRoot}/apps/sketchybar";
    ".config/skhd".source = link "${dotfilesRoot}/apps/skhd";
    ".config/television".source = link "${dotfilesRoot}/tui/television";
    ".config/tig".source = link "${dotfilesRoot}/tui/tig";
    ".config/tmux".source = link "${dotfilesRoot}/tui/tmux";
    ".config/wezterm".source = link "${dotfilesRoot}/apps/wezterm";
    ".config/yabai".source = link "${dotfilesRoot}/apps/yabai";
    ".config/yazi".source = link "${dotfilesRoot}/tui/yazi";
    ".config/zellij".source = link "${dotfilesRoot}/tui/zellij";

    ".config/starship.toml".source = link "${dotfilesRoot}/shells/starship.toml";
    ".zshrc".source = link "${dotfilesRoot}/shells/zshrc/.zshrc";

    "Library/Application Support/Code/User/settings.json" = {
      source = link "${dotfilesRoot}/apps/vscode/settings.json";
      force = true;
    };
    "Library/Application Support/Code/User/keybindings.json" = {
      source = link "${dotfilesRoot}/apps/vscode/keybindings.json";
      force = true;
    };
    "Library/Application Support/Code/User/snippets" = {
      source = link "${dotfilesRoot}/apps/vscode/snippets";
      force = true;
    };
  };
}