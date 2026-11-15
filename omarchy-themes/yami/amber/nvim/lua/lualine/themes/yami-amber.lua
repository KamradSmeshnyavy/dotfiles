-- Amber (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d98e1f", gui = "bold" }, b = { fg = "#eae1da", bg = "#261d14" }, c = { fg = "#958376", bg = "#19130d" } },
  insert = { a = { fg = "#0f0c08", bg = "#e4c193", gui = "bold" }, b = { fg = "#eae1da", bg = "#261d14" }, c = { fg = "#958376", bg = "#19130d" } },
  visual = { a = { fg = "#ffffff", bg = "#d98e1f", gui = "bold" }, b = { fg = "#eae1da", bg = "#261d14" }, c = { fg = "#958376", bg = "#19130d" } },
  replace = { a = { fg = "#0f0c08", bg = "#ffa724", gui = "bold" }, b = { fg = "#eae1da", bg = "#261d14" }, c = { fg = "#958376", bg = "#19130d" } },
  command = { a = { fg = "#0f0c08", bg = "#eae1da", gui = "bold" }, b = { fg = "#eae1da", bg = "#261d14" }, c = { fg = "#958376", bg = "#19130d" } },
  terminal = { a = { fg = "#0f0c08", bg = "#efd2ac", gui = "bold" }, b = { fg = "#eae1da", bg = "#261d14" }, c = { fg = "#958376", bg = "#19130d" } },
  inactive = { a = { fg = "#716258", bg = "#19130d" }, b = { fg = "#716258", bg = "#19130d" }, c = { fg = "#716258", bg = "#19130d" } },
}
