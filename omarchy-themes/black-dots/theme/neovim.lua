-- Глобальная автокоманда: срабатывает КАЖДЫЙ РАЗ при загрузке любой цветовой схемы
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Устанавливаем принудительный цвет для Visual (выделения)
    -- bg: цвет фона (замените на свой HEX), fg: цвет букв (опционально)
    vim.api.nvim_set_hl(0, "Visual", { bg = "#3a3f54", fg = "#f0f2f5" })
  end,
})

return {
  {
    "bjarneo/vantablack.nvim",
    priority = 1000,
    opts = {
      colors = {
        -- God Is In The Rain: Vantablack with subtle steel-blue, brick-red, and amber tints.
        -- Vantablack defines syntax/UI hues by role; we keep the role mapping and just
        -- swap the hex values to match our omarchy colors.toml palette.

        -- Pure black backgrounds (matches our omarchy desktop bg)
        bg = "#000000",
        bg_dark = "#000000",
        bg_dark1 = "#000000",
        bg_highlight = "#1a1f24", -- subtle blue-black for cursor line / selection

        -- Cool near-white foregrounds
        fg = "#f0f2f5",
        fg_dark = "#cdd6e4",
        fg_gutter = "#404040",

        -- Comments: dim with a faint cool cast
        comment = "#7a8090",

        -- Warm accents
        red = "#c47878", -- tags, errors-low
        red1 = "#dc8a8a", -- error, git delete
        orange = "#d6a06b", -- numbers, booleans
        yellow = "#e8b87a", -- types, parameters, warnings

        -- Subtle olive green (kept near-monochrome since green is not a wishlist accent)
        green = "#a8b0a8", -- strings
        green1 = "#b6c0b6", -- properties, members
        green2 = "#b6c0b6", -- git add

        -- Cool blues: the dominant tint
        blue = "#9bb0d4", -- statements, titles, directories
        blue0 = "#2a2a30", -- selection bg
        blue1 = "#7a8da8", -- borders, pmenu match (our accent)
        blue2 = "#9bb0d4", -- info diagnostic
        blue5 = "#7a95c2", -- operators, punctuation
        blue6 = "#a4b8c4", -- string.regexp
        blue7 = "#1a1f24", -- diff change bg

        cyan = "#a4b8c4", -- preprocessor, macros
        teal = "#a4b8c4", -- hints, markup links

        -- Keywords: cool gray with a whisper of blue
        purple = "#c0c0c8",

        -- Magenta stays grayscale (not in the accent palette)
        magenta = "#b0b0b0",
        magenta2 = "#b0b0b0",

        terminal_black = "#5c5c5c",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vantablack",
    },
  },
}
