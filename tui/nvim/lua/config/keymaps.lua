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

if vim.g.neovide then
  -- Функция для корректной вставки из системного буфера ("+ регистр)
  local function paste()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
  end

  -- Привязываем Cmd+V для всех основных режимов
  vim.keymap.set({ "n", "i", "v", "c", "t" }, "<D-v>", paste, { silent = true, desc = "Paste from system clipboard" })

  -- Опционально: привязываем Cmd+C для копирования в визуальном режиме
  vim.keymap.set("v", "<D-c>", [["+y]], { desc = "Copy to system clipboard" })
end

local last_float_buf = nil -- Запоминаем буфер, который мы "флоатили"

local function toggle_float_window()
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_get_current_buf()
  local config = vim.api.nvim_win_get_config(curr_win)

  -- 1. Если мы уже в плавающем окне — СКРЫВАЕМ его
  if config.relative ~= "" then
    last_float_buf = curr_buf -- Запоминаем, что именно мы скрыли
    vim.api.nvim_win_close(curr_win, false)
    return
  end

  -- 2. Если мы в обычном окне и есть ранее скрытый буфер — ВОССТАНАВЛИВАЕМ его во float
  if last_float_buf and vim.api.nvim_buf_is_valid(last_float_buf) then
    -- Проверяем, не открыт ли этот буфер уже где-то (чтобы не дублировать)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    vim.api.nvim_open_win(last_float_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      style = "minimal",
      border = "rounded",
    })
    last_float_buf = nil -- Сбрасываем, так как окно теперь открыто
    return
  end

  -- 3. Если скрытых окон нет — берем ТЕКУЩЕЕ окно и делаем его плавающим
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  vim.api.nvim_win_close(curr_win, false)
  vim.api.nvim_open_win(curr_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })
end

vim.keymap.set("n", "<leader>wf", toggle_float_window, { desc = "Toggle/Hide/Restore Float Window" })

-- Бинд для переключения (открыть во float / скрыть если float)
vim.keymap.set("n", "<leader>wf", toggle_float_window, { desc = "Toggle/Hide Float Window" })

-- Дополнительный бинд: вернуть плавающее окно обратно в сплит
vim.keymap.set("n", "<leader>w<C-f>", function()
  local win = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(win)
  if config.relative ~= "" then
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_close(win, false)
    vim.cmd("vsplit")
    vim.api.nvim_set_current_buf(buf)
  end
end, { desc = "Unfloat (Return to split)" })
