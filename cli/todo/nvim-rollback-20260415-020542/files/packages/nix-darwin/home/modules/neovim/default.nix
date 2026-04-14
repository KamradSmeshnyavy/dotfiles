{ lib, config, inputs, dotfilesRoot, ... }:
let
  cfg = config.dotfiles.neovim;
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./options.nix
    ./keymaps.nix
    ./plugins.nix
    ./lsp.nix
  ];

  options.dotfiles.neovim = {
    enable = lib.mkEnableOption "modular declarative neovim (nixvim)";

    backend = lib.mkOption {
      type = lib.types.enum [ "compat" "nixvim" ];
      default = "compat";
      description = "Neovim backend: compat (exact old LazyVim) or nixvim (full Nix rewrite).";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.backend == "compat") {
      # Exact behavior mode: reuse existing LazyVim tree as-is.
      home.file.".config/nvim" = {
        source = link "${dotfilesRoot}/home/nvim";
        force = true;
      };
    })

    (lib.mkIf (cfg.enable && cfg.backend == "nixvim") {
      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        globals = {
          mapleader = " ";
        };
      };
    })
  ];
}
