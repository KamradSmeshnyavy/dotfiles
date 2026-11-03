-- Nothing Signal — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d71921", gui = "bold" }, b = { fg = "#e8e6e3", bg = "#1a1a1a" }, c = { fg = "#a3a09c", bg = "#0b0b0b" } },
  insert = { a = { fg = "#000000", bg = "#9fd28a", gui = "bold" }, b = { fg = "#e8e6e3", bg = "#1a1a1a" }, c = { fg = "#a3a09c", bg = "#0b0b0b" } },
  visual = { a = { fg = "#000000", bg = "#c49bff", gui = "bold" }, b = { fg = "#e8e6e3", bg = "#1a1a1a" }, c = { fg = "#a3a09c", bg = "#0b0b0b" } },
  replace = { a = { fg = "#000000", bg = "#ff5d5d", gui = "bold" }, b = { fg = "#e8e6e3", bg = "#1a1a1a" }, c = { fg = "#a3a09c", bg = "#0b0b0b" } },
  command = { a = { fg = "#000000", bg = "#f2cc60", gui = "bold" }, b = { fg = "#e8e6e3", bg = "#1a1a1a" }, c = { fg = "#a3a09c", bg = "#0b0b0b" } },
  terminal = { a = { fg = "#000000", bg = "#7aa8ff", gui = "bold" }, b = { fg = "#e8e6e3", bg = "#1a1a1a" }, c = { fg = "#a3a09c", bg = "#0b0b0b" } },
  inactive = { a = { fg = "#6e6e6e", bg = "#0b0b0b" }, b = { fg = "#6e6e6e", bg = "#0b0b0b" }, c = { fg = "#6e6e6e", bg = "#0b0b0b" } },
}
