-- Инструменты для conform.lua (как у Efterklang) + rumdl для markdown
return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      "shfmt",
      "stylua",
      "goimports",
      "ruff",
      "biome",
      "rumdl",
    },
  },
}
