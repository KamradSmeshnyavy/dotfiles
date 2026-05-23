local ok, catppuccin = pcall(require, "yatline-catppuccin")

if not ok then
  return nil
end

return catppuccin:setup("mocha")
