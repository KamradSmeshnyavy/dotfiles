-- Nothing CMF — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#0d0b09", bg = "#ff6b1a", gui = "bold" }, b = { fg = "#ece4da", bg = "#221e1a" }, c = { fg = "#b3a99e", bg = "#141210" } },
  insert = { a = { fg = "#0d0b09", bg = "#b5cc7a", gui = "bold" }, b = { fg = "#ece4da", bg = "#221e1a" }, c = { fg = "#b3a99e", bg = "#141210" } },
  visual = { a = { fg = "#0d0b09", bg = "#c9a2f0", gui = "bold" }, b = { fg = "#ece4da", bg = "#221e1a" }, c = { fg = "#b3a99e", bg = "#141210" } },
  replace = { a = { fg = "#0d0b09", bg = "#ff5a4f", gui = "bold" }, b = { fg = "#ece4da", bg = "#221e1a" }, c = { fg = "#b3a99e", bg = "#141210" } },
  command = { a = { fg = "#0d0b09", bg = "#e8a7c8", gui = "bold" }, b = { fg = "#ece4da", bg = "#221e1a" }, c = { fg = "#b3a99e", bg = "#141210" } },
  terminal = { a = { fg = "#0d0b09", bg = "#7fbfd4", gui = "bold" }, b = { fg = "#ece4da", bg = "#221e1a" }, c = { fg = "#b3a99e", bg = "#141210" } },
  inactive = { a = { fg = "#7a7065", bg = "#141210" }, b = { fg = "#7a7065", bg = "#141210" }, c = { fg = "#7a7065", bg = "#141210" } },
}
