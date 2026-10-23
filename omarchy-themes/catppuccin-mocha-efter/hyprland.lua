-- Catppuccin Mocha: lavender → mauve border, as kitty's active_border_color in Efterklang/dotfiles
local active_border_color = { colors = { "rgba(b4befeee)", "rgba(cba6f7ee)" }, angle = 45 }
local inactive_border_color = "rgba(45475aaa)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})

-- Fullscreen windows get a red border, as in rose-pine-hacker24
hl.window_rule({
  match = { fullscreen = true },
  border_color = "rgba(f38ba8ee)",
})
