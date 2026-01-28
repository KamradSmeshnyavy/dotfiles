local map = LazyVim.safe_keymap_set

-- go to line start/end
map("", "<A-Left>", "^", { noremap = true, silent = true })
map("", "<A-Right>", "$", { noremap = true, silent = true })
-- move line up/down
map("", "<A-Up>", ":m .-2<CR>==", { noremap = true, silent = true })
map("", "<A-Down>", ":m .+1<CR>==", { noremap = true, silent = true })
-- word move
-- map("", "<C-H>", "db", { noremap = true, silent = true })
map("", "<C-delete>", "dw", { noremap = true, silent = true })
map("", "<C-Left>", "b", { noremap = true, silent = true })
map("", "<C-Right>", "w", { noremap = true, silent = true })

map("", "<C-a>", "ggVG", { noremap = true, silent = true })
map("", "<C-c>", '"+yy', { noremap = true, silent = true })
map("", "<C-x>", '"+dd', { noremap = true, silent = true })
map("", "<C-v>", '"+p', { noremap = true, silent = true })
map("", "<C-s>", ":x<CR>", { noremap = true, silent = true })
map("", "<C-z>", ":undo<CR>", { noremap = true, silent = true })
map("v", "y", '"+y')
map("v", "d", '"+d')
map("n", "yy", '"+yy', { noremap = true, silent = true })
map("n", "dd", '"+dd', { noremap = true, silent = true })
map("n", "p", '"+p', { noremap = true, silent = true })

vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })
vim.api.nvim_set_keymap("i", "оо", "<Esc>", { noremap = false })

-- [ Группа управления файлами и интерфейсом ]
map("n", "<leader><C-l>d", function()
  Snacks.dashboard.open()
end, { desc = "Открыть Dashboard" })
map("n", "<leader><C-l>f", function()
  vim.lsp.buf.format()
end, { desc = "Форматировать код (LSP)" })

-- [ Группа управления плагинами ]
map("n", "<leader><C-l>l", ":Lazy<CR>", { desc = "Меню плагинов (Lazy)" })
map("n", "<leader><C-l>m", ":Mason<CR>", { desc = "Менеджер серверов (Mason)" })

vim.keymap.set("n", "<leader>bx", function()
  local bufnr = 0
  local is_enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
  vim.diagnostic.enable(not is_enabled, { bufnr = bufnr })

  -- Необязательно: уведомление о статусе
  local status = is_enabled and "OFF" or "ON"
  print("Diagnostics " .. status)
end, { desc = "Toggle diagnostics in buffer" })
