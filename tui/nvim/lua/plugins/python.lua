-- ruff при сохранении: fixAll + organizeImports (как в VS Code)
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
    },
  },
}
