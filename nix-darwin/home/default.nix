{ pkgs, username, inputs, ... }:
{
  imports = [
    ./dotfiles-links.nix
    inputs.catppuccin.homeModules.catppuccin
    ./modules/theme.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Declarative global theme configuration (similar to Isabel's dotfiles).
  dotfiles.theme = {
    enable = true;
    flavor = "mocha";
    accent = "pink";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [
    atuin
    btop
    carapace
    gh
    glow
    jq
    yazi
    zellij
    tmux
  ];
}