-- Nothing Glyph White — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d71921", gui = "bold" }, b = { fg = "#111111", bg = "#ffffff" }, c = { fg = "#4a4a48", bg = "#e9e9e6" } },
  insert = { a = { fg = "#f4f4f2", bg = "#2f7a1f", gui = "bold" }, b = { fg = "#111111", bg = "#ffffff" }, c = { fg = "#4a4a48", bg = "#e9e9e6" } },
  visual = { a = { fg = "#f4f4f2", bg = "#7a35a8", gui = "bold" }, b = { fg = "#111111", bg = "#ffffff" }, c = { fg = "#4a4a48", bg = "#e9e9e6" } },
  replace = { a = { fg = "#f4f4f2", bg = "#c41e24", gui = "bold" }, b = { fg = "#111111", bg = "#ffffff" }, c = { fg = "#4a4a48", bg = "#e9e9e6" } },
  command = { a = { fg = "#f4f4f2", bg = "#7d6200", gui = "bold" }, b = { fg = "#111111", bg = "#ffffff" }, c = { fg = "#4a4a48", bg = "#e9e9e6" } },
  terminal = { a = { fg = "#f4f4f2", bg = "#1f5fa8", gui = "bold" }, b = { fg = "#111111", bg = "#ffffff" }, c = { fg = "#4a4a48", bg = "#e9e9e6" } },
  inactive = { a = { fg = "#7c7c78", bg = "#e9e9e6" }, b = { fg = "#7c7c78", bg = "#e9e9e6" }, c = { fg = "#7c7c78", bg = "#e9e9e6" } },
}
