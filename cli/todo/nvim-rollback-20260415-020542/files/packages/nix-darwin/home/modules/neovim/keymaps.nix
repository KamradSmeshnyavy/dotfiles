{ lib, config, ... }:
let
  cfg = config.dotfiles.neovim;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "nixvim") {
    programs.nixvim.keymaps = [
      {
        mode = [ "n" "v" "x" ];
        key = "<A-Left>";
        action = "^";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<A-Right>";
        action = "$";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<A-Up>";
        action = ":m .-2<CR>==";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<A-Down>";
        action = ":m .+1<CR>==";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-Left>";
        action = "b";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-Right>";
        action = "w";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-Delete>";
        action = "dw";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<C-s>";
        action = ":x<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-a>";
        action = "ggVG";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-c>";
        action = ''"+yy'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-x>";
        action = ''"+dd'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-v>";
        action = ''"+p'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = [ "n" "v" "x" ];
        key = "<C-z>";
        action = ":undo<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>Telescope help_tags<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "gd";
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "gr";
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "gi";
        action = "<cmd>lua vim.lsp.buf.implementation()<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "K";
        action = "<cmd>lua vim.lsp.buf.hover()<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>ca";
        action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>lua vim.lsp.buf.format()<CR>";
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = "y";
        action = ''"+y'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "v";
        key = "d";
        action = ''"+d'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "yy";
        action = ''"+yy'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "dd";
        action = ''"+dd'';
        options = {
          noremap = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "p";
        action = ''"+p'';
        options = {
          noremap = true;
          silent = true;
        };
      }
    ];

    programs.nixvim.extraConfigLua = ''
      vim.keymap.set("i", "jj", "<Esc>", { noremap = false })
      vim.keymap.set("i", "оо", "<Esc>", { noremap = false })

      vim.keymap.set("n", "<leader><C-l>l", function()
        if vim.fn.exists(":Lazy") == 2 then
          vim.cmd("Lazy")
        else
          vim.notify("Lazy is not installed in nixvim profile", vim.log.levels.WARN)
        end
      end, { desc = "Меню плагинов (Lazy)" })

      vim.keymap.set("n", "<leader><C-l>m", function()
        if vim.fn.exists(":Mason") == 2 then
          vim.cmd("Mason")
        else
          vim.notify("Mason is not used in this nixvim setup", vim.log.levels.INFO)
        end
      end, { desc = "Менеджер серверов (Mason)" })

      vim.keymap.set("n", "<leader>bx", function()
        local bufnr = 0
        local is_enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
        vim.diagnostic.enable(not is_enabled, { bufnr = bufnr })
      end, { desc = "Toggle diagnostics in buffer" })

      if vim.g.neovide then
        local function paste()
          vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
        end

        vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-v>", paste, { silent = true, desc = "Paste from system clipboard" })
        vim.keymap.set("v", "<D-c>", [["+y]], { desc = "Copy to system clipboard" })
      end
    '';
  };
}
