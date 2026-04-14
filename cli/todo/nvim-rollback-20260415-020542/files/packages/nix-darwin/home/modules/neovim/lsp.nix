{ lib, config, pkgs, ... }:
let
  cfg = config.dotfiles.neovim;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "nixvim") {
    programs.nixvim = {
      plugins = {
        lsp = {
          enable = true;
          servers = {
            lua_ls.enable = true;
            dockerls.enable = true;
            gopls.enable = true;
            helm_ls.enable = true;
            jdtls.enable = true;
            jsonls.enable = true;
            marksman.enable = true;
            nushell.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            yamlls.enable = true;
          };
        };
      };

      extraPackages = with pkgs; [
        lua-language-server
        dockerfile-language-server
        gopls
        helm-ls
        jdt-language-server
        marksman
        vscode-langservers-extracted
        yaml-language-server
        rust-analyzer
      ];

      extraConfigLua = lib.mkAfter ''
        -- keep lua diagnostics compatible with local config style
        pcall(function()
          require("lspconfig").lua_ls.setup({
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
              },
            },
          })
        end)
      '';
    };
  };
}
