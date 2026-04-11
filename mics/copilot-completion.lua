return {
  "saghen/blink.cmp",
  event = { "BufReadPost", "BufNewFile" },
  version = "1.*",
  dependencies = {
    "xzbdmw/colorful-menu.nvim",
    opts = {},
    "giuxtaposition/blink-cmp-copilot", -- Добавляем адаптер
    {
      "zbirenbaum/copilot.lua", -- Добавляем сам движок
      opts = {
        suggestion = { enabled = true }, -- Отключаем ghost text, чтобы не мешал меню
        panel = { enabled = false },
      },
    },
  },
  opts = {
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
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
    },
    keymap = {
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      -- ["<Tab>"] = { "accept", "accept_ghost_text" },
    },
    signature = { enabled = true },
    cmdline = { completion = { menu = { auto_show = true } } },
    -- НАСТРОЙКА ИСТОЧНИКОВ:
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "copilot" },
      providers = {
        snippets = { score_offset = 5 },
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100, -- Ставим выше, чтобы Copilot был в приоритете
          async = true,
          transform_items = function(_, items)
            -- Добавляем иконку робота для визуального отличия
            for _, item in ipairs(items) do
              item.kind = "Copilot"
            end
            return items
          end,
        },
      },
    },
  },
}
