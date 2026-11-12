-- Glyph Dark (glyph-rice) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d71921", gui = "bold" }, b = { fg = "#f2f2f2", bg = "#1a1a1a" }, c = { fg = "#8c8c8c", bg = "#0e0e0e" } },
  insert = { a = { fg = "#000000", bg = "#9bb59a", gui = "bold" }, b = { fg = "#f2f2f2", bg = "#1a1a1a" }, c = { fg = "#8c8c8c", bg = "#0e0e0e" } },
  visual = { a = { fg = "#000000", bg = "#b79bc2", gui = "bold" }, b = { fg = "#f2f2f2", bg = "#1a1a1a" }, c = { fg = "#8c8c8c", bg = "#0e0e0e" } },
  replace = { a = { fg = "#000000", bg = "#f0434b", gui = "bold" }, b = { fg = "#f2f2f2", bg = "#1a1a1a" }, c = { fg = "#8c8c8c", bg = "#0e0e0e" } },
  command = { a = { fg = "#000000", bg = "#d9c38a", gui = "bold" }, b = { fg = "#f2f2f2", bg = "#1a1a1a" }, c = { fg = "#8c8c8c", bg = "#0e0e0e" } },
  terminal = { a = { fg = "#000000", bg = "#8ea3c2", gui = "bold" }, b = { fg = "#f2f2f2", bg = "#1a1a1a" }, c = { fg = "#8c8c8c", bg = "#0e0e0e" } },
  inactive = { a = { fg = "#6e6e6e", bg = "#0e0e0e" }, b = { fg = "#6e6e6e", bg = "#0e0e0e" }, c = { fg = "#6e6e6e", bg = "#0e0e0e" } },
}
