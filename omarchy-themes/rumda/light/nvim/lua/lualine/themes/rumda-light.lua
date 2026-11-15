-- Rumda Light — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#fff3e6", bg = "#a1694d", gui = "bold" }, b = { fg = "#4e2e1f", bg = "#f0bb90" }, c = { fg = "#71594a", bg = "#f2cdac" } },
  insert = { a = { fg = "#f5dcc6", bg = "#784c36", gui = "bold" }, b = { fg = "#4e2e1f", bg = "#f0bb90" }, c = { fg = "#71594a", bg = "#f2cdac" } },
  visual = { a = { fg = "#f5dcc6", bg = "#9a4235", gui = "bold" }, b = { fg = "#4e2e1f", bg = "#f0bb90" }, c = { fg = "#71594a", bg = "#f2cdac" } },
  replace = { a = { fg = "#f5dcc6", bg = "#9a4235", gui = "bold" }, b = { fg = "#4e2e1f", bg = "#f0bb90" }, c = { fg = "#71594a", bg = "#f2cdac" } },
  command = { a = { fg = "#f5dcc6", bg = "#4e2e1f", gui = "bold" }, b = { fg = "#4e2e1f", bg = "#f0bb90" }, c = { fg = "#71594a", bg = "#f2cdac" } },
  terminal = { a = { fg = "#f5dcc6", bg = "#5e3928", gui = "bold" }, b = { fg = "#4e2e1f", bg = "#f0bb90" }, c = { fg = "#71594a", bg = "#f2cdac" } },
  inactive = { a = { fg = "#8d7666", bg = "#f2cdac" }, b = { fg = "#8d7666", bg = "#f2cdac" }, c = { fg = "#8d7666", bg = "#f2cdac" } },
}
