-- Surface Dark — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#232a2e", bg = "#a7c080", gui = "bold" }, b = { fg = "#e5dfc5", bg = "#2d353b" }, c = { fg = "#9da9a0", bg = "#1e2326" } },
  insert = { a = { fg = "#141719", bg = "#c3ce9f", gui = "bold" }, b = { fg = "#e5dfc5", bg = "#2d353b" }, c = { fg = "#9da9a0", bg = "#1e2326" } },
  visual = { a = { fg = "#141719", bg = "#e67e80", gui = "bold" }, b = { fg = "#e5dfc5", bg = "#2d353b" }, c = { fg = "#9da9a0", bg = "#1e2326" } },
  replace = { a = { fg = "#141719", bg = "#e67e80", gui = "bold" }, b = { fg = "#e5dfc5", bg = "#2d353b" }, c = { fg = "#9da9a0", bg = "#1e2326" } },
  command = { a = { fg = "#141719", bg = "#e5dfc5", gui = "bold" }, b = { fg = "#e5dfc5", bg = "#2d353b" }, c = { fg = "#9da9a0", bg = "#1e2326" } },
  terminal = { a = { fg = "#141719", bg = "#d2d6b0", gui = "bold" }, b = { fg = "#e5dfc5", bg = "#2d353b" }, c = { fg = "#9da9a0", bg = "#1e2326" } },
  inactive = { a = { fg = "#727166", bg = "#1e2326" }, b = { fg = "#727166", bg = "#1e2326" }, c = { fg = "#727166", bg = "#1e2326" } },
}
