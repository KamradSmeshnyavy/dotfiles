-- Своя colorscheme vitreus-paper: лежит в каталоге темы (nvim/colors, nvim/lua/lualine/themes),
-- omarchy копирует тему в ~/.local/state/omarchy/current/theme — оттуда её и грузим.
return {
	{
		dir = vim.fn.expand("~/.local/state/omarchy/current/theme/nvim"),
		name = "vitreus-paper",
		lazy = false,
		priority = 1000,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "vitreus-paper",
		},
	},
}
