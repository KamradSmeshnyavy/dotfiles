-- Proxy (Vitreus) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#0b0d10", bg = "#ffd21f", gui = "bold" }, b = { fg = "#f2f6f8", bg = "#242b31" }, c = { fg = "#93a1ac", bg = "#121920" } },
  insert = { a = { fg = "#10161d", bg = "#8ee07a", gui = "bold" }, b = { fg = "#f2f6f8", bg = "#242b31" }, c = { fg = "#93a1ac", bg = "#121920" } },
  visual = { a = { fg = "#10161d", bg = "#ff4d6d", gui = "bold" }, b = { fg = "#f2f6f8", bg = "#242b31" }, c = { fg = "#93a1ac", bg = "#121920" } },
  replace = { a = { fg = "#10161d", bg = "#ff4d6d", gui = "bold" }, b = { fg = "#f2f6f8", bg = "#242b31" }, c = { fg = "#93a1ac", bg = "#121920" } },
  command = { a = { fg = "#10161d", bg = "#e8b04a", gui = "bold" }, b = { fg = "#f2f6f8", bg = "#242b31" }, c = { fg = "#93a1ac", bg = "#121920" } },
  terminal = { a = { fg = "#10161d", bg = "#5aa9ff", gui = "bold" }, b = { fg = "#f2f6f8", bg = "#242b31" }, c = { fg = "#93a1ac", bg = "#121920" } },
  inactive = { a = { fg = "#93a1ac", bg = "#121920" }, b = { fg = "#93a1ac", bg = "#121920" }, c = { fg = "#93a1ac", bg = "#121920" } },
}
