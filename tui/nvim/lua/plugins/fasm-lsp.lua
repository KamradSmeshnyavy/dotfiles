return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        asm_lsp = {
          filetypes = { "asm", "fasm" },
          settings = {
            asm = {
              -- Выбираем диалект FASM
              assembler = "fasm",
              -- Можно указать путь к бинарнику, если он не в PATH
              -- path = "/usr/bin/fasm",
            },
          },
        },
      },
    },
  },
}
