{ pkgs, username, hostname, ... }:
{
  networking.hostName = hostname;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };

  nix.package = pkgs.lixPackageSets.stable.lix;

  programs.zsh.enable = true;

  users.users.${username}.home = "/Users/${username}";
  system.primaryUser = username;

  # Fix for existing Nix installation where nixbld group is already created.
  # Prevents: "Build user group has mismatching GID" during activation.
  ids.gids.nixbld = 350;

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    neovim
    ripgrep
    fd
    fzf
    bat
    eza
    lazygit
    zoxide
    starship
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };

    brews = [
      "imagemagick"
    ];

    casks = [
      "google-chrome"
      "visual-studio-code"
      "ghostty"
    ];

    taps = [ ];
    masApps = { };
  };

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
  };

  system.configurationRevision = null;
  system.stateVersion = 4;
}