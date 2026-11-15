-- Milkbox (Vitreus) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#7f8cff", gui = "bold" }, b = { fg = "#45495c", bg = "#dce0ea" }, c = { fg = "#5b6482", bg = "#e6eaf2" } },
  insert = { a = { fg = "#e0e5ee", bg = "#525eb9", gui = "bold" }, b = { fg = "#45495c", bg = "#dce0ea" }, c = { fg = "#5b6482", bg = "#e6eaf2" } },
  visual = { a = { fg = "#e0e5ee", bg = "#c7173c", gui = "bold" }, b = { fg = "#45495c", bg = "#dce0ea" }, c = { fg = "#5b6482", bg = "#e6eaf2" } },
  replace = { a = { fg = "#e0e5ee", bg = "#c7173c", gui = "bold" }, b = { fg = "#45495c", bg = "#dce0ea" }, c = { fg = "#5b6482", bg = "#e6eaf2" } },
  command = { a = { fg = "#e0e5ee", bg = "#5f657f", gui = "bold" }, b = { fg = "#45495c", bg = "#dce0ea" }, c = { fg = "#5b6482", bg = "#e6eaf2" } },
  terminal = { a = { fg = "#e0e5ee", bg = "#5862a2", gui = "bold" }, b = { fg = "#45495c", bg = "#dce0ea" }, c = { fg = "#5b6482", bg = "#e6eaf2" } },
  inactive = { a = { fg = "#7982a1", bg = "#e6eaf2" }, b = { fg = "#7982a1", bg = "#e6eaf2" }, c = { fg = "#7982a1", bg = "#e6eaf2" } },
}
