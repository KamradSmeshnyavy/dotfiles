return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    ---@diagnostic disable-next-line: undefined-global
    vim.g.tmux_navigator_no_mappings = 1 -- use custom keymaps for predictable terminal behavior
  end,
  keys = {
    { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",                mode = "n", silent = true, desc = "Navigate Left" },
    { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",                mode = "n", silent = true, desc = "Navigate Down" },
    { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",                  mode = "n", silent = true, desc = "Navigate Up" },
    { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",               mode = "n", silent = true, desc = "Navigate Right" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>",            mode = "n", silent = true, desc = "Navigate Previous" },
    { "<C-h>",  "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>",     mode = "t", silent = true, desc = "Navigate Left" },
    { "<C-j>",  "<C-\\><C-n><cmd>TmuxNavigateDown<cr>",     mode = "t", silent = true, desc = "Navigate Down" },
    { "<C-k>",  "<C-\\><C-n><cmd>TmuxNavigateUp<cr>",       mode = "t", silent = true, desc = "Navigate Up" },
    { "<C-l>",  "<C-\\><C-n><cmd>TmuxNavigateRight<cr>",    mode = "t", silent = true, desc = "Navigate Right" },
    { "<C-\\>", "<C-\\><C-n><cmd>TmuxNavigatePrevious<cr>", mode = "t", silent = true, desc = "Navigate Previous" },
  },
}
