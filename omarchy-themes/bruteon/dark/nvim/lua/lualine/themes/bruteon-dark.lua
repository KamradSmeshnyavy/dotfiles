-- Bruteon Dark — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#161110", bg = "#ffb77a", gui = "bold" }, b = { fg = "#f3e6dc", bg = "#4a372c" }, c = { fg = "#c79b7f", bg = "#2a2320" } },
  insert = { a = { fg = "#1d1816", bg = "#dba57d", gui = "bold" }, b = { fg = "#f3e6dc", bg = "#4a372c" }, c = { fg = "#c79b7f", bg = "#2a2320" } },
  visual = { a = { fg = "#1d1816", bg = "#ff8a80", gui = "bold" }, b = { fg = "#f3e6dc", bg = "#4a372c" }, c = { fg = "#c79b7f", bg = "#2a2320" } },
  replace = { a = { fg = "#1d1816", bg = "#ff8a80", gui = "bold" }, b = { fg = "#f3e6dc", bg = "#4a372c" }, c = { fg = "#c79b7f", bg = "#2a2320" } },
  command = { a = { fg = "#1d1816", bg = "#f3e6dc", gui = "bold" }, b = { fg = "#f3e6dc", bg = "#4a372c" }, c = { fg = "#c79b7f", bg = "#2a2320" } },
  terminal = { a = { fg = "#1d1816", bg = "#f2d4bb", gui = "bold" }, b = { fg = "#f3e6dc", bg = "#4a372c" }, c = { fg = "#c79b7f", bg = "#2a2320" } },
  inactive = { a = { fg = "#947460", bg = "#2a2320" }, b = { fg = "#947460", bg = "#2a2320" }, c = { fg = "#947460", bg = "#2a2320" } },
}
