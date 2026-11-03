-- Nothing Steel — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d71921", gui = "bold" }, b = { fg = "#dde3e8", bg = "#171b1f" }, c = { fg = "#97a1aa", bg = "#0a0c0e" } },
  insert = { a = { fg = "#000000", bg = "#93b6d2", gui = "bold" }, b = { fg = "#dde3e8", bg = "#171b1f" }, c = { fg = "#97a1aa", bg = "#0a0c0e" } },
  visual = { a = { fg = "#000000", bg = "#b8cfe2", gui = "bold" }, b = { fg = "#dde3e8", bg = "#171b1f" }, c = { fg = "#97a1aa", bg = "#0a0c0e" } },
  replace = { a = { fg = "#000000", bg = "#ff4d55", gui = "bold" }, b = { fg = "#dde3e8", bg = "#171b1f" }, c = { fg = "#97a1aa", bg = "#0a0c0e" } },
  command = { a = { fg = "#000000", bg = "#ff8a8a", gui = "bold" }, b = { fg = "#dde3e8", bg = "#171b1f" }, c = { fg = "#97a1aa", bg = "#0a0c0e" } },
  terminal = { a = { fg = "#000000", bg = "#d2e6f6", gui = "bold" }, b = { fg = "#dde3e8", bg = "#171b1f" }, c = { fg = "#97a1aa", bg = "#0a0c0e" } },
  inactive = { a = { fg = "#5f6a74", bg = "#0a0c0e" }, b = { fg = "#5f6a74", bg = "#0a0c0e" }, c = { fg = "#5f6a74", bg = "#0a0c0e" } },
}
