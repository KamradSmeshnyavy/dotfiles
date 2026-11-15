-- Venom (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#5fae34", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  insert = { a = { fg = "#0b0d09", bg = "#b1ce9c", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  visual = { a = { fg = "#ffffff", bg = "#5fae34", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  replace = { a = { fg = "#0b0d09", bg = "#7be244", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  command = { a = { fg = "#0b0d09", bg = "#e4e2db", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  terminal = { a = { fg = "#0b0d09", bg = "#cae2b5", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  inactive = { a = { fg = "#66655a", bg = "#12150e" }, b = { fg = "#66655a", bg = "#12150e" }, c = { fg = "#66655a", bg = "#12150e" } },
}
