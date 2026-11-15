-- Bruteon — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#161110", bg = "#ffb77a", gui = "bold" }, b = { fg = "#161110", bg = "#e3c0a5" }, c = { fg = "#885643", bg = "#f5ebe6" } },
  insert = { a = { fg = "#efe0d6", bg = "#83583f", gui = "bold" }, b = { fg = "#161110", bg = "#e3c0a5" }, c = { fg = "#885643", bg = "#f5ebe6" } },
  visual = { a = { fg = "#efe0d6", bg = "#a93f34", gui = "bold" }, b = { fg = "#161110", bg = "#e3c0a5" }, c = { fg = "#885643", bg = "#f5ebe6" } },
  replace = { a = { fg = "#efe0d6", bg = "#a93f34", gui = "bold" }, b = { fg = "#161110", bg = "#e3c0a5" }, c = { fg = "#885643", bg = "#f5ebe6" } },
  command = { a = { fg = "#efe0d6", bg = "#161110", gui = "bold" }, b = { fg = "#161110", bg = "#e3c0a5" }, c = { fg = "#885643", bg = "#f5ebe6" } },
  terminal = { a = { fg = "#efe0d6", bg = "#40260a", gui = "bold" }, b = { fg = "#161110", bg = "#e3c0a5" }, c = { fg = "#885643", bg = "#f5ebe6" } },
  inactive = { a = { fg = "#9d7768", bg = "#f5ebe6" }, b = { fg = "#9d7768", bg = "#f5ebe6" }, c = { fg = "#9d7768", bg = "#f5ebe6" } },
}
