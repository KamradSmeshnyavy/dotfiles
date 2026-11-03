-- Nothing Ash Light — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d71921", gui = "bold" }, b = { fg = "#262524", bg = "#ffffff" }, c = { fg = "#4f4d4b", bg = "#e9e9e6" } },
  insert = { a = { fg = "#f4f4f2", bg = "#5e574f", gui = "bold" }, b = { fg = "#262524", bg = "#ffffff" }, c = { fg = "#4f4d4b", bg = "#e9e9e6" } },
  visual = { a = { fg = "#f4f4f2", bg = "#c4283f", gui = "bold" }, b = { fg = "#262524", bg = "#ffffff" }, c = { fg = "#4f4d4b", bg = "#e9e9e6" } },
  replace = { a = { fg = "#f4f4f2", bg = "#c41e24", gui = "bold" }, b = { fg = "#262524", bg = "#ffffff" }, c = { fg = "#4f4d4b", bg = "#e9e9e6" } },
  command = { a = { fg = "#f4f4f2", bg = "#9b1c2c", gui = "bold" }, b = { fg = "#262524", bg = "#ffffff" }, c = { fg = "#4f4d4b", bg = "#e9e9e6" } },
  terminal = { a = { fg = "#f4f4f2", bg = "#000000", gui = "bold" }, b = { fg = "#262524", bg = "#ffffff" }, c = { fg = "#4f4d4b", bg = "#e9e9e6" } },
  inactive = { a = { fg = "#86837f", bg = "#e9e9e6" }, b = { fg = "#86837f", bg = "#e9e9e6" }, c = { fg = "#86837f", bg = "#e9e9e6" } },
}
