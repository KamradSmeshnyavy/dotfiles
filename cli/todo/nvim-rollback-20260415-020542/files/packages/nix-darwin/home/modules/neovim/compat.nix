{ lib, config, dotfilesRoot, ... }:
let
  cfg = config.dotfiles.neovim;
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "compat") {
    # Exact behavior mode: reuse existing LazyVim tree as-is.
    home.file.".config/nvim" = {
      source = link "${dotfilesRoot}/home/nvim";
      force = true;
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
