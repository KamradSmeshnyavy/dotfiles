-- return {
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         -- Заменяем pyright на basedpyright
--         basedpyright = {
--           settings = {
--             basedpyright = {
--               analysis = {
--                 -- Идеальное отображение docstrings в Neovim из коробки
--                 diagnosticMode = "openFilesOnly",
--               },
--             },
--           },
--         },
--       },
--     },
--   },
-- }
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Настраиваем новый форк
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                -- "all" для максимальной строгости или "recommended"
                -- typeCheckingMode = "recommended",
                typeCheckingMode = "off",
                -- Включаем inlay hints (подсказки типов в самом коде)
                inlayHints = {
                  variableTypes = true,
                  callArgumentNames = true,
                  functionReturnTypes = true,
                },
              },
            },
          },
        },
      },
    },
  },
}
