require("config.remote_clipboard").setup()
vim.o.winborder = "rounded"

-- Python: basedpyright (типы, дополнение) + ruff (линт, формат, импорты)
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
