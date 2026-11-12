-- Glyph Light (glyph-rice) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d71921", gui = "bold" }, b = { fg = "#0b0b0b", bg = "#ffffff" }, c = { fg = "#4a4a4a", bg = "#f1f1f1" } },
  insert = { a = { fg = "#e9e9e9", bg = "#4a4a4a", gui = "bold" }, b = { fg = "#0b0b0b", bg = "#ffffff" }, c = { fg = "#4a4a4a", bg = "#f1f1f1" } },
  visual = { a = { fg = "#e9e9e9", bg = "#8a0f15", gui = "bold" }, b = { fg = "#0b0b0b", bg = "#ffffff" }, c = { fg = "#4a4a4a", bg = "#f1f1f1" } },
  replace = { a = { fg = "#e9e9e9", bg = "#b3121a", gui = "bold" }, b = { fg = "#0b0b0b", bg = "#ffffff" }, c = { fg = "#4a4a4a", bg = "#f1f1f1" } },
  command = { a = { fg = "#e9e9e9", bg = "#1c1c1c", gui = "bold" }, b = { fg = "#0b0b0b", bg = "#ffffff" }, c = { fg = "#4a4a4a", bg = "#f1f1f1" } },
  terminal = { a = { fg = "#e9e9e9", bg = "#0b0b0b", gui = "bold" }, b = { fg = "#0b0b0b", bg = "#ffffff" }, c = { fg = "#4a4a4a", bg = "#f1f1f1" } },
  inactive = { a = { fg = "#6e6e6e", bg = "#f1f1f1" }, b = { fg = "#6e6e6e", bg = "#f1f1f1" }, c = { fg = "#6e6e6e", bg = "#f1f1f1" } },
}
