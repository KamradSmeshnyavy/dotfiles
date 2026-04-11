return {
  "swaits/zellij-nav.nvim",
  lazy = true,
  event = "VeryLazy",
  keys = {
    { "<C-h>", "<cmd>ZellijNavigateLeft<cr>", silent = true, desc = "Move left" },
    { "<C-j>", "<cmd>ZellijNavigateDown<cr>", silent = true, desc = "Move down" },
    { "<C-k>", "<cmd>ZellijNavigateUp<cr>", silent = true, desc = "Move up" },
    { "<C-l>", "<cmd>ZellijNavigateRight<cr>", silent = true, desc = "Move right" },
  },
  opts = {},
}
