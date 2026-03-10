return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  dependencies = {
    { "zbirenbaum/copilot.lua" }, -- Необходим для аутентификации
    { "nvim-lua/plenary.nvim" }, -- Библиотека функций
  },
  build = "make utf8", -- Сборка для корректной работы с текстом
  opts = {
    debug = false, -- Включите, если возникнут проблемы
  },
  keys = {
    -- Быстрое открытие чата
    { "<leader>cii", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
    -- Объяснить выделенный код
    { "<leader>cie", "<cmd>CopilotChatExplain<cr>", mode = "v", desc = "CopilotChat - Explain code" },
  },
}
