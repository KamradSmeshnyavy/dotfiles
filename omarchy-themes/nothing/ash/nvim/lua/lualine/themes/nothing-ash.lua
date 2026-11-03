-- Nothing Ash — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d71921", gui = "bold" }, b = { fg = "#d6d3cf", bg = "#1a1a1a" }, c = { fg = "#9c9894", bg = "#0b0b0b" } },
  insert = { a = { fg = "#000000", bg = "#b9b0a6", gui = "bold" }, b = { fg = "#d6d3cf", bg = "#1a1a1a" }, c = { fg = "#9c9894", bg = "#0b0b0b" } },
  visual = { a = { fg = "#000000", bg = "#e8636b", gui = "bold" }, b = { fg = "#d6d3cf", bg = "#1a1a1a" }, c = { fg = "#9c9894", bg = "#0b0b0b" } },
  replace = { a = { fg = "#000000", bg = "#ff4d55", gui = "bold" }, b = { fg = "#d6d3cf", bg = "#1a1a1a" }, c = { fg = "#9c9894", bg = "#0b0b0b" } },
  command = { a = { fg = "#000000", bg = "#ff8a8a", gui = "bold" }, b = { fg = "#d6d3cf", bg = "#1a1a1a" }, c = { fg = "#9c9894", bg = "#0b0b0b" } },
  terminal = { a = { fg = "#000000", bg = "#ffffff", gui = "bold" }, b = { fg = "#d6d3cf", bg = "#1a1a1a" }, c = { fg = "#9c9894", bg = "#0b0b0b" } },
  inactive = { a = { fg = "#686664", bg = "#0b0b0b" }, b = { fg = "#686664", bg = "#0b0b0b" }, c = { fg = "#686664", bg = "#0b0b0b" } },
}
