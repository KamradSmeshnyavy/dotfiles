-- NIHIL base16 для Neovim (порт home/nvim.nix из poligle/Nihil-Shell, MIT).
-- Красный (#d71921) зарезервирован для ошибок и удалений, поэтому идентификаторы
-- и теги используют основной цвет текста (#e6e6e6), а ключевые слова — жирный #b5b5b5.
return {
	{
		"bjarneo/aether.nvim",
		branch = "v3",
		name = "aether",
		priority = 1000,
		opts = {
			colors = {
				bg = "#000000",
				dark_bg = "#0e0e0e",
				darker_bg = "#000000",
				lighter_bg = "#1a1a1a",

				fg = "#e6e6e6",
				dark_fg = "#7a7a7a",
				light_fg = "#a3a3a3",
				bright_fg = "#f2f2f2",
				muted = "#5e5e5e",

				red = "#d71921",
				yellow = "#ffffff",
				orange = "#cfcfcf",
				green = "#9e9e9e",
				cyan = "#8a8a8a",
				blue = "#f2f2f2",
				magenta = "#b5b5b5",
				brown = "#6e6e6e",

				bright_red = "#d71921",
				bright_yellow = "#ffffff",
				bright_green = "#b5b5b5",
				bright_cyan = "#a3a3a3",
				bright_blue = "#ffffff",
				bright_magenta = "#cfcfcf",

				accent = "#f2f2f2",
				cursor = "#f2f2f2",
				foreground = "#e6e6e6",
				background = "#000000",
				selection = "#1a1a1a",
				selection_foreground = "#ffffff",
				selection_background = "#2a2a2a",
			},
		},
		init = function()
			local function nihil_highlights()
				local fg = "#e6e6e6"
				for _, group in ipairs({
					"Identifier",
					"@variable",
					"@variable.member",
					"@variable.parameter",
					"@property",
					"@field",
					"@parameter",
					"@tag",
					"@tag.attribute",
				}) do
					vim.api.nvim_set_hl(0, group, { fg = fg })
				end
				vim.api.nvim_set_hl(0, "Keyword", { fg = "#b5b5b5", bold = true })
				vim.api.nvim_set_hl(0, "@keyword", { fg = "#b5b5b5", bold = true })
			end

			vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
				group = vim.api.nvim_create_augroup("NihilHighlights", { clear = true }),
				callback = nihil_highlights,
			})
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "aether",
		},
	},
}
