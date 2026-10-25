-- Форматтеры как у Efterklang (tui_cli/nvim/lua/plugins/conform.lua), но дописываются к настройкам
-- LazyVim и других файлов, а не заменяют их: python — в python.lua (ruff fix + imports + format).
-- less/sass убраны: biome их не знает и отдаёт предупреждение вместо кода.
return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = function(_, opts)
      local sh = { "shfmt" }
      local biome = { "biome" }

      local formatters = {
        bash = sh,
        sh = sh,
        zsh = sh,
        lua = { "stylua" },
        go = { "goimports" },
        javascript = biome,
        typescript = biome,
        javascriptreact = biome,
        typescriptreact = biome,
        json = biome,
        jsonc = biome,
        yaml = biome,
        html = biome,
        css = biome,
        toml = { "taplo" },
        markdown = { "rumdl" },
      }

      opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, formatters)
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        biome = {
          args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
        },
        rumdl = {
          command = "rumdl",
          args = { "fmt", "--stdin", "--silent" },
          stdin = true,
        },
        injected = {
          options = {
            ignore_errors = false,
            lang_to_formatters = formatters,
          },
        },
      })
    end,
  },
}
