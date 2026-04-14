{ pkgs, username, inputs, ... }:
{
  imports = [
    ./dotfiles-links.nix
    inputs.catppuccin.homeModules.catppuccin
    ./modules/theme.nix
    ./modules/neovim
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Declarative global theme configuration (similar to Isabel's dotfiles).
  dotfiles.theme = {
    # Temporarily disabled: current catppuccin/nix revision removed gtk options
    # and breaks evaluation for this host.
    enable = false;
    flavor = "mocha";
    accent = "pink";
  };

  # Neovim module:
  # - backend = "compat": exact old LazyVim config from ~/dotfiles/home/nvim (1:1 behavior)
  # - backend = "nixvim": fully rewritten nixvim config
  dotfiles.neovim = {
    enable = true;
    backend = "compat";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Ensure user profile binaries (including nixvim's wrapped nvim)
  # are resolved before Homebrew binaries in interactive shells.
  home.sessionPath = [
    "/etc/profiles/per-user/${username}/bin"
  ];

  home.packages = with pkgs; [
    atuin
    btop
    carapace
    neovim
    gh
    glow
    jq
    yazi
    zellij
    tmux
  ];
}