-- Rumda Dark — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#1c1612", bg = "#c47c4f", gui = "bold" }, b = { fg = "#f0c997", bg = "#3d2e21" }, c = { fg = "#a68a68", bg = "#2b221a" } },
  insert = { a = { fg = "#1c1612", bg = "#daa273", gui = "bold" }, b = { fg = "#f0c997", bg = "#3d2e21" }, c = { fg = "#a68a68", bg = "#2b221a" } },
  visual = { a = { fg = "#1c1612", bg = "#b5746a", gui = "bold" }, b = { fg = "#f0c997", bg = "#3d2e21" }, c = { fg = "#a68a68", bg = "#2b221a" } },
  replace = { a = { fg = "#1c1612", bg = "#b5746a", gui = "bold" }, b = { fg = "#f0c997", bg = "#3d2e21" }, c = { fg = "#a68a68", bg = "#2b221a" } },
  command = { a = { fg = "#1c1612", bg = "#f0c997", gui = "bold" }, b = { fg = "#f0c997", bg = "#3d2e21" }, c = { fg = "#a68a68", bg = "#2b221a" } },
  terminal = { a = { fg = "#1c1612", bg = "#e8b786", gui = "bold" }, b = { fg = "#f0c997", bg = "#3d2e21" }, c = { fg = "#a68a68", bg = "#2b221a" } },
  inactive = { a = { fg = "#7b674e", bg = "#2b221a" }, b = { fg = "#7b674e", bg = "#2b221a" }, c = { fg = "#7b674e", bg = "#2b221a" } },
}
