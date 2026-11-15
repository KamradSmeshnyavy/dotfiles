-- Surface Light Color — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#f0ece6", bg = "#4f6b5b", gui = "bold" }, b = { fg = "#252e33", bg = "#d8d2c8" }, c = { fg = "#546670", bg = "#e3ded6" } },
  insert = { a = { fg = "#f0ece6", bg = "#4f6e3e", gui = "bold" }, b = { fg = "#252e33", bg = "#d8d2c8" }, c = { fg = "#546670", bg = "#e3ded6" } },
  visual = { a = { fg = "#f0ece6", bg = "#9a4880", gui = "bold" }, b = { fg = "#252e33", bg = "#d8d2c8" }, c = { fg = "#546670", bg = "#e3ded6" } },
  replace = { a = { fg = "#f0ece6", bg = "#bb3c3e", gui = "bold" }, b = { fg = "#252e33", bg = "#d8d2c8" }, c = { fg = "#546670", bg = "#e3ded6" } },
  command = { a = { fg = "#f0ece6", bg = "#886200", gui = "bold" }, b = { fg = "#252e33", bg = "#d8d2c8" }, c = { fg = "#546670", bg = "#e3ded6" } },
  terminal = { a = { fg = "#f0ece6", bg = "#2b6d91", gui = "bold" }, b = { fg = "#252e33", bg = "#d8d2c8" }, c = { fg = "#546670", bg = "#e3ded6" } },
  inactive = { a = { fg = "#848584", bg = "#e3ded6" }, b = { fg = "#848584", bg = "#e3ded6" }, c = { fg = "#848584", bg = "#e3ded6" } },
}
