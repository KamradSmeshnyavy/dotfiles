-- Ash (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#0b0909", bg = "#a8a29c", gui = "bold" }, b = { fg = "#e8e2e0", bg = "#221e1e" }, c = { fg = "#8f8685", bg = "#161414" } },
  insert = { a = { fg = "#0e0c0c", bg = "#d0cac6", gui = "bold" }, b = { fg = "#e8e2e0", bg = "#221e1e" }, c = { fg = "#8f8685", bg = "#161414" } },
  visual = { a = { fg = "#0b0909", bg = "#a8a29c", gui = "bold" }, b = { fg = "#e8e2e0", bg = "#221e1e" }, c = { fg = "#8f8685", bg = "#161414" } },
  replace = { a = { fg = "#0e0c0c", bg = "#dad3cb", gui = "bold" }, b = { fg = "#e8e2e0", bg = "#221e1e" }, c = { fg = "#8f8685", bg = "#161414" } },
  command = { a = { fg = "#0e0c0c", bg = "#e8e2e0", gui = "bold" }, b = { fg = "#e8e2e0", bg = "#221e1e" }, c = { fg = "#8f8685", bg = "#161414" } },
  terminal = { a = { fg = "#0e0c0c", bg = "#e4dedb", gui = "bold" }, b = { fg = "#e8e2e0", bg = "#221e1e" }, c = { fg = "#8f8685", bg = "#161414" } },
  inactive = { a = { fg = "#6d6463", bg = "#161414" }, b = { fg = "#6d6463", bg = "#161414" }, c = { fg = "#6d6463", bg = "#161414" } },
}
