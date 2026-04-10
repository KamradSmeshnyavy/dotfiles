{ pkgs, username, ... }:
{
  imports = [
    ./dotfiles-links.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

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