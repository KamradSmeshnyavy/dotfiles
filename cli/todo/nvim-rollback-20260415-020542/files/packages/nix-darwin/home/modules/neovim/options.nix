{ lib, config, ... }:
let
  cfg = config.dotfiles.neovim;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "nixvim") {
    programs.nixvim = {
      opts = {
        number = true;
        relativenumber = true;

        tabstop = 2;
        shiftwidth = 2;
        expandtab = true;

        mouse = "a";
        ignorecase = true;
        smartcase = true;
        termguicolors = true;
        signcolumn = "yes";
        updatetime = 200;
        timeoutlen = 500;

        winborder = "rounded";
      };

      colorschemes.catppuccin.enable = true;

      extraConfigLua = ''
        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        })

        local function my_paste(_)
          return function(_)
            local content = vim.fn.getreg('"')
            return vim.split(content, "\n")
          end
        end

        vim.opt.clipboard:append("unnamedplus")
        if os.getenv("SSH_TTY") ~= nil then
          vim.g.clipboard = {
            name = "OSC 52",
            copy = {
              ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
              ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
            },
            paste = {
              ["+"] = my_paste("+"),
              ["*"] = my_paste("*"),
            },
          }
        end
      '';
    };
  };
}
