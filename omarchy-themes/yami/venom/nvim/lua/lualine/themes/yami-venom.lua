-- Venom (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#5fae34", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  insert = { a = { fg = "#0b0d09", bg = "#9cbf7c", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  visual = { a = { fg = "#0b0d09", bg = "#53972d", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  replace = { a = { fg = "#0b0d09", bg = "#e5484d", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  command = { a = { fg = "#0b0d09", bg = "#d6c27a", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  terminal = { a = { fg = "#0b0d09", bg = "#8fb3d9", gui = "bold" }, b = { fg = "#e4e2db", bg = "#1c1f16" }, c = { fg = "#878779", bg = "#12150e" } },
  inactive = { a = { fg = "#66655a", bg = "#12150e" }, b = { fg = "#66655a", bg = "#12150e" }, c = { fg = "#66655a", bg = "#12150e" } },
}
