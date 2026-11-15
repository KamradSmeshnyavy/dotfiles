-- Doodle (Vitreus) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#fffdf6", bg = "#e0457b", gui = "bold" }, b = { fg = "#22202e", bg = "#edebe6" }, c = { fg = "#6b6577", bg = "#fffdf6" } },
  insert = { a = { fg = "#fbf5e8", bg = "#813254", gui = "bold" }, b = { fg = "#22202e", bg = "#edebe6" }, c = { fg = "#6b6577", bg = "#fffdf6" } },
  visual = { a = { fg = "#fbf5e8", bg = "#db1f25", gui = "bold" }, b = { fg = "#22202e", bg = "#edebe6" }, c = { fg = "#6b6577", bg = "#fffdf6" } },
  replace = { a = { fg = "#fbf5e8", bg = "#db1f25", gui = "bold" }, b = { fg = "#22202e", bg = "#edebe6" }, c = { fg = "#6b6577", bg = "#fffdf6" } },
  command = { a = { fg = "#fbf5e8", bg = "#22202e", gui = "bold" }, b = { fg = "#22202e", bg = "#edebe6" }, c = { fg = "#6b6577", bg = "#fffdf6" } },
  terminal = { a = { fg = "#fbf5e8", bg = "#5a2541", gui = "bold" }, b = { fg = "#22202e", bg = "#edebe6" }, c = { fg = "#6b6577", bg = "#fffdf6" } },
  inactive = { a = { fg = "#6b6577", bg = "#fffdf6" }, b = { fg = "#6b6577", bg = "#fffdf6" }, c = { fg = "#6b6577", bg = "#fffdf6" } },
}
