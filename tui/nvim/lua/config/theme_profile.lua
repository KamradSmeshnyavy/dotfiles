local M = {}

M.profile = "pink"

M.profiles = {
  current = {
    flavour = "mocha",
  },
  pink = {
    flavour = "mocha",
    color_overrides = {
      mocha = {
        mauve = "#f5c2e7",
        blue = "#f5c2e7",
        lavender = "#f5c2e7",
      },
    },
  },
}

M.catppuccin = M.profiles[M.profile] or M.profiles.current

return M
