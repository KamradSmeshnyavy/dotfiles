-- return {
--   -- 1. Обеспечиваем корректную подсветку через Tree-sitter
--   {
--     "nvim-treesitter/nvim-treesitter",
--     opts = function(_, opts)
--       if type(opts.ensure_installed) == "table" then
--         vim.list_extend(opts.ensure_installed, { "asm" })
--       end
--     end,
--   },
--
--   -- 2. Настраиваем работу LSP через внутренний словарь settings
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         asm_lsp = {
--           filetypes = { "asm", "vmasm", "S" },
--           -- Передаем параметры конфигурации напрямую через LSP-протокол
--           settings = {
--             default_config = {
--               assembler = "nasm",
--               instruction_set = "x86/x86-64",
--               compiler = "nasm",
--               diagnostics = true,
--             },
--           },
--         },
--       },
--     },
--   },
-- }

-- то что работало
-- return {
--   -- 1. Корректируем поведение Treesitter для ASM
--   {
--     "nvim-treesitter/nvim-treesitter",
--     opts = function(_, opts)
--       if not opts.highlight then
--         opts.highlight = {}
--       end
--       opts.highlight.disable = function(lang, buf)
--         return lang == "asm"
--       end
--     end,
--   },
--
--   -- 2. Настраиваем EFM-сервер для вызова fasm
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       -- Гарантируем, что старый asm_lsp не запустится
--       setup = {
--         asm_lsp = function()
--           return true
--         end,
--       },
--       servers = {
--         efm = {
--           filetypes = { "asm" },
--           settings = {
--             rootMarkers = { ".git", "Makefile" },
--             languages = {
--               asm = {
--                 {
--                   -- Запускаем FASM в режиме компиляции во временный файл
--                   lintCommand = "fasm ${INPUT} /tmp/efm_fasm_check.o",
--                   lintStdin = false,
--                   lintIsStderr = true,
--                   -- Формат строки ошибки, которую выдает FASM
--                   -- Пример: error: illegal instruction [main.asm:12]
--                   lintFormats = {
--                     "error: %m [%f:%l]",
--                     "error: %m",
--                   },
--                   lintSource = "fasm",
--                 },
--               },
--             },
--           },
--         },
--       },
--     },
--   },
-- }
--

-- return {
--   -- Плагин для синтаксиса FASM
--   {
--     "fedorenchik/fasm.vim",
--     ft = "fasm",
--   },
--
--   -- Интеграция fasm-lsp в nvim-lspconfig (стандартный для LazyVim)
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         asm_lsp = {
--           filetypes = { "fasm", "asm" },
--         },
--       },
--     },
--   },
-- }

return {
  -- Встроенная подсветка через файл fasm.vim (ничего дополнительно ставить не нужно)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Можно оставить стандартный asm для деревьев, но для подсветки FASM
      -- просто включим нужную переменную
      vim.g.asmsyntax = "fasm"
    end,
  },
  -- Автоматически задаём filetype=asm (c подсветкой fasm) для файлов .asm
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.asm",
        command = "set filetype=asm",
      })
    end,
  },
}
