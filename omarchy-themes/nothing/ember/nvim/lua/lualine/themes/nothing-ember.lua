-- Nothing Ember — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#0d0b09", bg = "#ff6b1a", gui = "bold" }, b = { fg = "#e3d9cc", bg = "#221e1a" }, c = { fg = "#a99d90", bg = "#141210" } },
  insert = { a = { fg = "#0d0b09", bg = "#d4bb98", gui = "bold" }, b = { fg = "#e3d9cc", bg = "#221e1a" }, c = { fg = "#a99d90", bg = "#141210" } },
  visual = { a = { fg = "#0d0b09", bg = "#ff9450", gui = "bold" }, b = { fg = "#e3d9cc", bg = "#221e1a" }, c = { fg = "#a99d90", bg = "#141210" } },
  replace = { a = { fg = "#0d0b09", bg = "#ff4a3d", gui = "bold" }, b = { fg = "#e3d9cc", bg = "#221e1a" }, c = { fg = "#a99d90", bg = "#141210" } },
  command = { a = { fg = "#0d0b09", bg = "#ffab78", gui = "bold" }, b = { fg = "#e3d9cc", bg = "#221e1a" }, c = { fg = "#a99d90", bg = "#141210" } },
  terminal = { a = { fg = "#0d0b09", bg = "#fff4e6", gui = "bold" }, b = { fg = "#e3d9cc", bg = "#221e1a" }, c = { fg = "#a99d90", bg = "#141210" } },
  inactive = { a = { fg = "#766b60", bg = "#141210" }, b = { fg = "#766b60", bg = "#141210" }, c = { fg = "#766b60", bg = "#141210" } },
}
