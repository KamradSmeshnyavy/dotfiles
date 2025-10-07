{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    #home-manager = {
    #  url = "github:nix-community/home-manager";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.vim
          pkgs.direnv
          pkgs.sshs
          pkgs.glow
          pkgs.nushell
          pkgs.carapace
        ];

      #services.nix-daemon.enable = true; # old nix
      nix.enable = true;

      nix.settings.experimental-features = "nix-command flakes";
      #system settings
      programs.zsh.enable = true;  # default shell on catalina
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;
      nixpkgs.hostPlatform = "aarch64-darwin";
      #security.pam.enableSudoTouchIdAuth = true;
      
      # ВАЖНО: Исправить GID mismatch
      ids.gids.nixbld = 350;


      users.users.kamradsmeshnyavy.home = "/Users/kamradsmeshnyavy";
      #home-manager.backupFileExtension = "backup";

      system.primaryUser = "kamradsmeshnyavy";
      #nix.configureBuildUsers = true; # old nix
      #nix.useDaemon = true; # old nix

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "kamradsmeshnyavy-create";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.casks = [
	            "wireshark"
              "google-chrome"
      ];
      homebrew.brews = [
	       "imagemagick"
      ];
    };
  in
  {
    darwinConfigurations."MacBook-Pro-Denis" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ 
	  configuration
#        home-manager.darwinModules.home-manager {
#          home-manager.useGlobalPkgs = true;
#          home-manager.useUserPackages = true;
#          home-manager.users.kamradsmeshnyavy = import ./home.nix;
#        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook-Pro-Denis".pkgs;
  };
}
