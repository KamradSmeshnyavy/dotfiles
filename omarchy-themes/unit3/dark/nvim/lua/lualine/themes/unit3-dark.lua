-- Unit-3 — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#0b0a09", bg = "#c8b89a", gui = "bold" }, b = { fg = "#c8b89a", bg = "#1a1814" }, c = { fg = "#8a7f6a", bg = "#111008" } },
  insert = { a = { fg = "#0b0a09", bg = "#60a880", gui = "bold" }, b = { fg = "#c8b89a", bg = "#1a1814" }, c = { fg = "#8a7f6a", bg = "#111008" } },
  visual = { a = { fg = "#0b0a09", bg = "#c87060", gui = "bold" }, b = { fg = "#c8b89a", bg = "#1a1814" }, c = { fg = "#8a7f6a", bg = "#111008" } },
  replace = { a = { fg = "#0b0a09", bg = "#c87060", gui = "bold" }, b = { fg = "#c8b89a", bg = "#1a1814" }, c = { fg = "#8a7f6a", bg = "#111008" } },
  command = { a = { fg = "#0b0a09", bg = "#c8b89a", gui = "bold" }, b = { fg = "#c8b89a", bg = "#1a1814" }, c = { fg = "#8a7f6a", bg = "#111008" } },
  terminal = { a = { fg = "#0b0a09", bg = "#6090c8", gui = "bold" }, b = { fg = "#c8b89a", bg = "#1a1814" }, c = { fg = "#8a7f6a", bg = "#111008" } },
  inactive = { a = { fg = "#6d6658", bg = "#111008" }, b = { fg = "#6d6658", bg = "#111008" }, c = { fg = "#6d6658", bg = "#111008" } },
}
