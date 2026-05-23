local ok, catppuccin = pcall(require, "catppuccin")

if ok then
  catppuccin.load()
  return
end

vim.cmd.colorscheme("catppuccin")
