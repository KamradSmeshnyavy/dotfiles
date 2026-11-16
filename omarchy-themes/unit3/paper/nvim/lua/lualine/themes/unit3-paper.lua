-- Unit-3 Paper — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#d6cfb5", bg = "#6e2a2a", gui = "bold" }, b = { fg = "#2e2a1f", bg = "#b8af93" }, c = { fg = "#5a5541", bg = "#ccc4a6" } },
  insert = { a = { fg = "#d6cfb5", bg = "#4f5a2e", gui = "bold" }, b = { fg = "#2e2a1f", bg = "#b8af93" }, c = { fg = "#5a5541", bg = "#ccc4a6" } },
  visual = { a = { fg = "#d6cfb5", bg = "#6e2a2a", gui = "bold" }, b = { fg = "#2e2a1f", bg = "#b8af93" }, c = { fg = "#5a5541", bg = "#ccc4a6" } },
  replace = { a = { fg = "#d6cfb5", bg = "#6e2a2a", gui = "bold" }, b = { fg = "#2e2a1f", bg = "#b8af93" }, c = { fg = "#5a5541", bg = "#ccc4a6" } },
  command = { a = { fg = "#d6cfb5", bg = "#2e2a1f", gui = "bold" }, b = { fg = "#2e2a1f", bg = "#b8af93" }, c = { fg = "#5a5541", bg = "#ccc4a6" } },
  terminal = { a = { fg = "#d6cfb5", bg = "#3a4a5a", gui = "bold" }, b = { fg = "#2e2a1f", bg = "#b8af93" }, c = { fg = "#5a5541", bg = "#ccc4a6" } },
  inactive = { a = { fg = "#766f5a", bg = "#ccc4a6" }, b = { fg = "#766f5a", bg = "#ccc4a6" }, c = { fg = "#766f5a", bg = "#ccc4a6" } },
}
