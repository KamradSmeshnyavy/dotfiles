-- Blood (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#c4161c", gui = "bold" }, b = { fg = "#e9dbda", bg = "#241314" }, c = { fg = "#937576", bg = "#180d0d" } },
  insert = { a = { fg = "#0f0808", bg = "#9cbf7c", gui = "bold" }, b = { fg = "#e9dbda", bg = "#241314" }, c = { fg = "#937576", bg = "#180d0d" } },
  visual = { a = { fg = "#0f0808", bg = "#c45c60", gui = "bold" }, b = { fg = "#e9dbda", bg = "#241314" }, c = { fg = "#937576", bg = "#180d0d" } },
  replace = { a = { fg = "#0f0808", bg = "#e5484d", gui = "bold" }, b = { fg = "#e9dbda", bg = "#241314" }, c = { fg = "#937576", bg = "#180d0d" } },
  command = { a = { fg = "#0f0808", bg = "#d6c27a", gui = "bold" }, b = { fg = "#e9dbda", bg = "#241314" }, c = { fg = "#937576", bg = "#180d0d" } },
  terminal = { a = { fg = "#0f0808", bg = "#8fb3d9", gui = "bold" }, b = { fg = "#e9dbda", bg = "#241314" }, c = { fg = "#937576", bg = "#180d0d" } },
  inactive = { a = { fg = "#6f5758", bg = "#180d0d" }, b = { fg = "#6f5758", bg = "#180d0d" }, c = { fg = "#6f5758", bg = "#180d0d" } },
}
