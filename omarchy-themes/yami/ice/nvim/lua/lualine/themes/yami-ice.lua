-- Ice (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#3a9fd0", gui = "bold" }, b = { fg = "#e2e2e3", bg = "#191e22" }, c = { fg = "#82858b", bg = "#101417" } },
  insert = { a = { fg = "#0a0c0e", bg = "#a2c9dc", gui = "bold" }, b = { fg = "#e2e2e3", bg = "#191e22" }, c = { fg = "#82858b", bg = "#101417" } },
  visual = { a = { fg = "#ffffff", bg = "#3a9fd0", gui = "bold" }, b = { fg = "#e2e2e3", bg = "#191e22" }, c = { fg = "#82858b", bg = "#101417" } },
  replace = { a = { fg = "#0a0c0e", bg = "#47c3ff", gui = "bold" }, b = { fg = "#e2e2e3", bg = "#191e22" }, c = { fg = "#82858b", bg = "#101417" } },
  command = { a = { fg = "#0a0c0e", bg = "#e2e2e3", gui = "bold" }, b = { fg = "#e2e2e3", bg = "#191e22" }, c = { fg = "#82858b", bg = "#101417" } },
  terminal = { a = { fg = "#0a0c0e", bg = "#bbdaea", gui = "bold" }, b = { fg = "#e2e2e3", bg = "#191e22" }, c = { fg = "#82858b", bg = "#101417" } },
  inactive = { a = { fg = "#636469", bg = "#101417" }, b = { fg = "#636469", bg = "#101417" }, c = { fg = "#636469", bg = "#101417" } },
}
