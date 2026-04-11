{ lib, config, ... }:
let
  cfg = config.dotfiles.theme;
in
{
  options.dotfiles.theme = {
    enable = lib.mkEnableOption "declarative Catppuccin theming";

    flavor = lib.mkOption {
      type = lib.types.enum [ "latte" "frappe" "macchiato" "mocha" ];
      default = "mocha";
      description = "Catppuccin flavor";
    };

    accent = lib.mkOption {
      type = lib.types.enum [
        "rosewater"
        "flamingo"
        "pink"
        "mauve"
        "red"
        "maroon"
        "peach"
        "yellow"
        "green"
        "teal"
        "sky"
        "sapphire"
        "blue"
        "lavender"
      ];
      default = "pink";
      description = "Catppuccin accent color";
    };
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = cfg.flavor;
      accent = cfg.accent;
    };
  };
}
