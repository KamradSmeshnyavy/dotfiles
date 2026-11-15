-- Sakura (yami) — lualine: NORMAL в сигнальном цвете, остальные режимы — роли палитры.
return {
  normal = { a = { fg = "#ffffff", bg = "#d9577c", gui = "bold" }, b = { fg = "#eadedf", bg = "#26181b" }, c = { fg = "#957d81", bg = "#191012" } },
  insert = { a = { fg = "#0f0a0b", bg = "#9cbf7c", gui = "bold" }, b = { fg = "#eadedf", bg = "#26181b" }, c = { fg = "#957d81", bg = "#191012" } },
  visual = { a = { fg = "#0f0a0b", bg = "#c15775", gui = "bold" }, b = { fg = "#eadedf", bg = "#26181b" }, c = { fg = "#957d81", bg = "#191012" } },
  replace = { a = { fg = "#0f0a0b", bg = "#e5484d", gui = "bold" }, b = { fg = "#eadedf", bg = "#26181b" }, c = { fg = "#957d81", bg = "#191012" } },
  command = { a = { fg = "#0f0a0b", bg = "#d6c27a", gui = "bold" }, b = { fg = "#eadedf", bg = "#26181b" }, c = { fg = "#957d81", bg = "#191012" } },
  terminal = { a = { fg = "#0f0a0b", bg = "#8fb3d9", gui = "bold" }, b = { fg = "#eadedf", bg = "#26181b" }, c = { fg = "#957d81", bg = "#191012" } },
  inactive = { a = { fg = "#715c60", bg = "#191012" }, b = { fg = "#715c60", bg = "#191012" }, c = { fg = "#715c60", bg = "#191012" } },
}
