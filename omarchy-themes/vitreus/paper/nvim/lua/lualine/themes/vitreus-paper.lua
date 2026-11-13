-- Paper (Vitreus) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#fffaf0", bg = "#6a90c9", gui = "bold" }, b = { fg = "#3b3631", bg = "#e7dfcf" }, c = { fg = "#6c6457", bg = "#f6eedd" } },
  insert = { a = { fg = "#efe4cd", bg = "#526f2e", gui = "bold" }, b = { fg = "#3b3631", bg = "#e7dfcf" }, c = { fg = "#6c6457", bg = "#f6eedd" } },
  visual = { a = { fg = "#efe4cd", bg = "#b04038", gui = "bold" }, b = { fg = "#3b3631", bg = "#e7dfcf" }, c = { fg = "#6c6457", bg = "#f6eedd" } },
  replace = { a = { fg = "#efe4cd", bg = "#bd3429", gui = "bold" }, b = { fg = "#3b3631", bg = "#e7dfcf" }, c = { fg = "#6c6457", bg = "#f6eedd" } },
  command = { a = { fg = "#efe4cd", bg = "#7a6420", gui = "bold" }, b = { fg = "#3b3631", bg = "#e7dfcf" }, c = { fg = "#6c6457", bg = "#f6eedd" } },
  terminal = { a = { fg = "#efe4cd", bg = "#1f6a70", gui = "bold" }, b = { fg = "#3b3631", bg = "#e7dfcf" }, c = { fg = "#6c6457", bg = "#f6eedd" } },
  inactive = { a = { fg = "#857b6c", bg = "#f6eedd" }, b = { fg = "#857b6c", bg = "#f6eedd" }, c = { fg = "#857b6c", bg = "#f6eedd" } },
}
