-- Dusk (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#0b0909", bg = "#8a5cf0", gui = "bold" }, b = { fg = "#e6dee5", bg = "#1f1925" }, c = { fg = "#8c7d8f", bg = "#151019" } },
  insert = { a = { fg = "#0d0a0f", bg = "#9cbf7c", gui = "bold" }, b = { fg = "#e6dee5", bg = "#1f1925" }, c = { fg = "#8c7d8f", bg = "#151019" } },
  visual = { a = { fg = "#0d0a0f", bg = "#8864d7", gui = "bold" }, b = { fg = "#e6dee5", bg = "#1f1925" }, c = { fg = "#8c7d8f", bg = "#151019" } },
  replace = { a = { fg = "#0d0a0f", bg = "#e5484d", gui = "bold" }, b = { fg = "#e6dee5", bg = "#1f1925" }, c = { fg = "#8c7d8f", bg = "#151019" } },
  command = { a = { fg = "#0d0a0f", bg = "#d6c27a", gui = "bold" }, b = { fg = "#e6dee5", bg = "#1f1925" }, c = { fg = "#8c7d8f", bg = "#151019" } },
  terminal = { a = { fg = "#0d0a0f", bg = "#8fb3d9", gui = "bold" }, b = { fg = "#e6dee5", bg = "#1f1925" }, c = { fg = "#8c7d8f", bg = "#151019" } },
  inactive = { a = { fg = "#6a5d6b", bg = "#151019" }, b = { fg = "#6a5d6b", bg = "#151019" }, c = { fg = "#6a5d6b", bg = "#151019" } },
}
