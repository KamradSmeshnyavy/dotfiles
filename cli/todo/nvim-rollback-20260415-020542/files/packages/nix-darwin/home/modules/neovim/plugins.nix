{ lib, config, pkgs, ... }:
let
  cfg = config.dotfiles.neovim;
  snacksConfig = builtins.readFile ./lua/snacks.lua;
  renderMarkdownConfig = builtins.readFile ./lua/render-markdown.lua;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "nixvim") {
    programs.nixvim = {
      plugins = {
        lualine.enable = true;
        web-devicons.enable = true;
        which-key.enable = true;

        telescope = {
          enable = true;
          extensions.fzf-native.enable = true;
          settings = {
            defaults = {
              layout_strategy = "horizontal";
              sorting_strategy = "ascending";
              winblend = 0;
              file_ignore_patterns = [ "node_modules" ".git/" ];
            };
          };
        };

        treesitter = {
          enable = true;
          settings = {
            ensure_installed = [
              "bash"
              "dockerfile"
              "go"
              "helm"
              "java"
              "json"
              "lua"
              "markdown"
              "markdown_inline"
              "nix"
              "nu"
              "python"
              "rust"
              "toml"
              "vim"
              "yaml"
            ];
            highlight.enable = true;
            indent.enable = true;
          };
        };

        gitsigns = {
          enable = true;
          settings = {
            signs = {
              add.text = "+";
              change.text = "~";
              delete.text = "-";
              topdelete.text = "‾";
              changedelete.text = "=";
              untracked.text = "?";
            };
          };
        };

        oil.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins; [
        catppuccin-nvim
        snacks-nvim
        mini-nvim
        blink-cmp
        colorful-menu-nvim
        copilot-vim
        copilot-lua
        CopilotChat-nvim
        symbols-outline-nvim
        yazi-nvim
        multicursor-nvim
        nvim-colorizer-lua
        switch-vim
        bullets-vim
        img-clip-nvim
        vim-wakatime
        zellij-nav-nvim
        leetcode-nvim
        kitty-scrollback-nvim
        render-markdown-nvim
        telescope-fzf-native-nvim
        nui-nvim
        plenary-nvim
        nvim-lint
        vim-tmux-navigator
        none-ls-nvim
      ];

      extraConfigLua = lib.mkAfter ''
        -- Snacks dashboard + picker config
        ${snacksConfig}

        -- Render Markdown full config
        ${renderMarkdownConfig}

        -- symbols-outline
        vim.keymap.set("n", "<leader>cs", "<cmd>SymbolsOutline<cr>", { desc = "Symbols Outline" })

        -- telescope fzf extension
        pcall(function()
          require("telescope").load_extension("fzf")
        end)

        -- telescope plugin-files key from old config
        vim.keymap.set(
          "n",
          "<leader>fp",
          function()
            local root = vim.fn.stdpath("data")
            pcall(function()
              root = require("lazy.core.config").options.root
            end)
            require("telescope.builtin").find_files({ cwd = root })
          end,
          { desc = "Find Plugin File" }
        )

        -- yazi
        pcall(function()
          require("yazi").setup({
            open_for_directories = true,
            keymaps = { show_help = "<f1>" },
          })
        end)
        vim.keymap.set("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })
        vim.keymap.set("n", "<leader>E", "<cmd>Yazi cwd<cr>", { desc = "Open the file manager in nvim's working directory" })
        vim.keymap.set("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" })

        -- nvim-colorizer
        pcall(function()
          require("colorizer").setup({
            "lua",
            "html",
            "xml",
            "python",
            "kitty",
            "tmux",
            "toml",
            "json",
          }, {
            names = false,
          })
        end)

        -- switch.vim custom definitions
        vim.g.switch_custom_definitions = {
          { "> [!TODO]", "> [!WIP]", "> [!DONE]", "> [!FAIL]" },
        }
        vim.keymap.set("n", "`", function()
          vim.cmd([[Switch]])
        end, { desc = "Switch strings" })

        -- img-clip
        pcall(function()
          require("img-clip").setup({
            default = {
              dir_path = "assets",
              use_absolute_path = false,
              copy_images = true,
              prompt_for_file_name = false,
              file_name = "%y%m%d-%H%M%S",
              extension = "avif",
              process_cmd = "magick convert - -quality 75 avif:-",
            },
            filetypes = {
              markdown = {
                template = "![image$CURSOR]($FILE_PATH)",
              },
              tex = {
                dir_path = "./figs",
                extension = "png",
                process_cmd = "",
                template = [[
  \begin{figure}[h]
    \centering
    \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \end{figure}
                ]],
              },
              typst = {
                dir_path = "./figs",
                extension = "png",
                process_cmd = "magick convert - -density 300 png:-",
                template = [[
                #align(center)[#image("$FILE_PATH", height: auto)]
                ]],
              },
            },
          })
        end)
        vim.keymap.set("n", "<leader>P", "<cmd>PasteImage<cr>", { desc = "Paste image from system clipboard" })

        -- vim-tmux-navigator
        vim.g.tmux_navigator_no_mappings = 1
        vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true, desc = "Navigate Left" })
        vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true, desc = "Navigate Down" })
        vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true, desc = "Navigate Up" })
        vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true, desc = "Navigate Right" })
        vim.keymap.set("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", { silent = true, desc = "Navigate Previous" })
        vim.keymap.set("t", "<C-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", { silent = true, desc = "Navigate Left" })
        vim.keymap.set("t", "<C-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", { silent = true, desc = "Navigate Down" })
        vim.keymap.set("t", "<C-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", { silent = true, desc = "Navigate Up" })
        vim.keymap.set("t", "<C-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", { silent = true, desc = "Navigate Right" })
        vim.keymap.set("t", "<C-\\>", "<C-\\><C-n><cmd>TmuxNavigatePrevious<cr>", { silent = true, desc = "Navigate Previous" })

        -- zellij-nav
        vim.keymap.set("n", "<C-h>", "<cmd>ZellijNavigateLeft<cr>", { silent = true, desc = "Move left" })
        vim.keymap.set("n", "<C-j>", "<cmd>ZellijNavigateDown<cr>", { silent = true, desc = "Move down" })
        vim.keymap.set("n", "<C-k>", "<cmd>ZellijNavigateUp<cr>", { silent = true, desc = "Move up" })
        vim.keymap.set("n", "<C-l>", "<cmd>ZellijNavigateRight<cr>", { silent = true, desc = "Move right" })

        -- kitty scrollback
        pcall(function()
          require("kitty-scrollback").setup()
        end)

        -- leetcode
        pcall(function()
          local leet = require("leetcode")
          leet.setup({
            lang = "python",
            cn = {
              enabled = true,
              translator = false,
              translate_problems = true,
            },
            storage = {
              home = vim.fn.expand("~/Projects/code_draft/leetcode"),
              cache = vim.fn.stdpath("cache") .. "/leetcode",
            },
          })
        end)

        -- copilot chat keymaps from old config
        vim.keymap.set("n", "<leader>cii", "<cmd>CopilotChatToggle<cr>", { desc = "CopilotChat - Toggle" })
        vim.keymap.set("v", "<leader>cie", "<cmd>CopilotChatExplain<cr>", { desc = "CopilotChat - Explain code" })

        -- blink.cmp setup from old config
        pcall(function()
          require("blink.cmp").setup({
            completion = {
              menu = {
                draw = {
                  columns = { { "kind_icon" }, { "label", gap = 1 } },
                  components = {
                    label = {
                      text = function(ctx)
                        return require("colorful-menu").blink_components_text(ctx)
                      end,
                      highlight = function(ctx)
                        return require("colorful-menu").blink_components_highlight(ctx)
                      end,
                    },
                  },
                },
              },
              documentation = {
                auto_show = true,
                auto_show_delay_ms = 500,
              },
            },
            keymap = {
              ["<C-u>"] = { "scroll_documentation_up", "fallback" },
              ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },
            signature = {
              enabled = true,
            },
            cmdline = {
              completion = {
                menu = {
                  auto_show = true,
                },
              },
            },
            sources = {
              providers = {
                snippets = { score_offset = 5 },
              },
            },
          })
        end)

        -- multicursor setup from old config
        pcall(function()
          local mc = require("multicursor-nvim")
          mc.setup()

          local set = vim.keymap.set
          set({ "n", "x" }, "<C-A-up>", function() mc.lineAddCursor(-1) end)
          set({ "n", "x" }, "<C-A-down>", function() mc.lineAddCursor(1) end)
          set({ "n", "x" }, "<S-C-A-up>", function() mc.lineSkipCursor(-1) end)
          set({ "n", "x" }, "<S-C-A-down>", function() mc.lineSkipCursor(1) end)
          set({ "n", "x" }, "<leader><C-C>n", function() mc.matchAddCursor(1) end, { desc = "Add cursor match 1" })
          set({ "n", "x" }, "<leader><C-C>s", function() mc.matchSkipCursor(1) end, { desc = "Skip cursor match 1" })
          set({ "n", "x" }, "<leader><C-C>N", function() mc.matchAddCursor(-1) end, { desc = "Add cursor match -1" })
          set({ "n", "x" }, "<leader><C-C>S", function() mc.matchSkipCursor(-1) end, { desc = "Skip cursor match -1" })
          set("n", "<c-leftmouse>", mc.handleMouse)
          set("n", "<c-leftdrag>", mc.handleMouseDrag)
          set("n", "<c-leftrelease>", mc.handleMouseRelease)
          set({ "n", "x" }, "<c-q>", mc.toggleCursor)

          mc.addKeymapLayer(function(layerSet)
            layerSet({ "n", "x" }, "<C-A-left>", mc.prevCursor)
            layerSet({ "n", "x" }, "<C-A-right>", mc.nextCursor)
            layerSet({ "n", "x" }, "<leader><C-x>", mc.deleteCursor)
            layerSet("n", "<esc>", function()
              if not mc.cursorsEnabled() then
                mc.enableCursors()
              else
                mc.clearCursors()
              end
            end)
          end)

          local hl = vim.api.nvim_set_hl
          hl(0, "MultiCursorCursor", { reverse = true })
          hl(0, "MultiCursorVisual", { link = "Visual" })
          hl(0, "MultiCursorSign", { link = "SignColumn" })
          hl(0, "MultiCursorMatchPreview", { link = "Search" })
          hl(0, "MultiCursorDisabledCursor", { reverse = true })
          hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
          hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
        end)

        -- oil.nvim custom behavior from old config
        function _G.get_oil_winbar()
          local dir = require("oil").get_current_dir()
          if dir then
            return vim.fn.fnamemodify(dir, ":~")
          else
            return vim.api.nvim_buf_get_name(0)
          end
        end

        local detail = false
        require("oil").setup({
          default_file_explorer = true,
          keymaps = {
            ["<C-h>"] = false,
            ["<C-l>"] = false,
            ["<C-k>"] = false,
            ["<C-j>"] = false,
            ["<C-r>"] = "actions.refresh",
            ["<leader>y"] = "actions.yank_entry",
            ["g."] = false,
            ["zh"] = "actions.toggle_hidden",
            ["-"] = "actions.close",
            ["<BS>"] = "actions.parent",
            ["gd"] = {
              desc = "Toggle file detail view",
              callback = function()
                detail = not detail
                if detail then
                  require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
                else
                  require("oil").set_columns({ "icon" })
                end
              end,
            },
          },
          win_options = {
            winbar = "%!v:lua.get_oil_winbar()",
          },
        })

        -- snacks picker keymaps from old config
        local map = function(key, func, desc)
          vim.keymap.set("n", key, func, { desc = desc })
        end

        -- mini.surround from old config
        pcall(function()
          require("mini.surround").setup({
            mappings = {
              add = "ra",
              delete = "rd",
              find = "gsf",
              find_left = "gsF",
              highlight = "gsh",
              replace = "gsr",
              update_n_lines = "gsn",
            },
          })
        end)

        -- nvim-lint from old config
        pcall(function()
          local lint = require("lint")
          local home = vim.env.HOME or ""
          lint.linters["markdownlint-cli2"] = lint.linters["markdownlint-cli2"] or {}
          lint.linters["markdownlint-cli2"].args = {
            "--config",
            home .. "/.config/.markdownlint-cli2.yaml",
            "--",
          }
        end)

        pcall(function()
          map("<leader>ff", Snacks.picker.smart, "Smart find file")
          map("<leader>fr", Snacks.picker.recent, "Find recent file")
          map("<leader>fw", Snacks.picker.grep, "Find content")
          map("<leader>fh", function() Snacks.picker.help({ layout = "dropdown" }) end, "Find in help")
          map("<leader>fk", function() Snacks.picker.keymaps({ layout = "dropdown" }) end, "Find keymap")
          map("<leader>fm", Snacks.picker.marks, "Find mark")
          map("<leader>fn", function() Snacks.picker.notifications({ layout = "dropdown" }) end, "Find notification")
          map("grr", Snacks.picker.lsp_references, "Find lsp references")
          map("<leader>fS", Snacks.picker.lsp_workspace_symbols, "Find workspace symbol")
          map("<leader>fs", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_clients({ bufnr = bufnr })

            local function has_lsp_symbols()
              for _, client in ipairs(clients) do
                if client.server_capabilities.documentSymbolProvider then
                  return true
                end
              end
              return false
            end

            if has_lsp_symbols() then
              Snacks.picker.lsp_symbols({ tree = true })
            else
              Snacks.picker.treesitter()
            end
          end, "Find symbol in current buffer")
          map("<leader>fd", Snacks.picker.diagnostics_buffer, "Find diagnostic in current buffer")
          map("<leader>fH", Snacks.picker.highlights, "Find highlight")
          map("<leader>f/", Snacks.picker.search_history, "Find search history")
          map("<leader>fj", Snacks.picker.jumps, "Find jump")
          map("<leader>bc", Snacks.bufdelete.delete, "Delete buffers")
          map("<leader>bC", Snacks.bufdelete.other, "Delete other buffers")
          map("<leader>gg", function() Snacks.lazygit({ cwd = Snacks.git.get_root() }) end, "Open lazygit")
          map("<leader>n", Snacks.notifier.show_history, "Notification history")
          map("<leader><C-l>d", function() Snacks.dashboard.open() end, "Открыть Dashboard")
        end)
      '';
    };

    # tools expected by plugin configs
    home.packages = with pkgs; [
      imagemagick
      markdownlint-cli2
    ];
  };
}
