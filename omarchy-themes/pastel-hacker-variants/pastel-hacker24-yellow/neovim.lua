local M = {
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				vim.cmd("set termguicolors")
				vim.cmd("highlight clear")

				local colors = {
					bg = "#0d0e1a",
					fg = "#dcd7e6",
					muted = "#4a4d6a",
					dark = "#151726",
					darker = "#0a0b14",
					border = "#151726",
					selection = "#151726",

					primary = "#f5cba7",
					secondary = "#8dd4cc",
					success = "#f5cba7",
					warning = "#f5cba7",
					danger = "#f1948a",
					accent = "#c9a0dc",
					info = "#8dd4cc",
					purple = "#c9a0dc",
					subtle = "#151726",
				}

				local function set_hl(group, opts)
					vim.api.nvim_set_hl(0, group, opts)
				end

				set_hl("Normal", { fg = colors.fg, bg = colors.bg })
				set_hl("NormalNC", { fg = colors.fg, bg = colors.bg })
				set_hl("Comment", { fg = colors.muted, italic = true })
				set_hl("NonText", { fg = colors.muted })
				set_hl("Whitespace", { fg = colors.muted })
				set_hl("EndOfBuffer", { fg = colors.bg })

				set_hl("CursorLine", { bg = colors.dark })
				set_hl("CursorColumn", { bg = colors.dark })
				set_hl("CursorLineNr", { fg = colors.primary, bold = true })
				set_hl("LineNr", { fg = colors.muted })

				set_hl("Visual", { bg = colors.selection })
				set_hl("Search", { fg = colors.bg, bg = colors.primary })
				set_hl("IncSearch", { fg = colors.bg, bg = colors.accent })

				set_hl("VertSplit", { fg = colors.border })
				set_hl("WinSeparator", { fg = colors.border })

				set_hl("StatusLine", { fg = colors.fg, bg = colors.dark })
				set_hl("StatusLineNC", { fg = colors.muted, bg = colors.dark })

				set_hl("TabLine", { fg = colors.muted, bg = colors.dark })
				set_hl("TabLineFill", { bg = colors.darker })
				set_hl("TabLineSel", { fg = colors.primary, bg = colors.bg, bold = true })

				set_hl("Constant", { fg = colors.purple })
				set_hl("String", { fg = colors.primary })
				set_hl("Character", { fg = colors.primary })
				set_hl("Number", { fg = colors.purple })
				set_hl("Boolean", { fg = colors.secondary, bold = true })

				set_hl("Identifier", { fg = colors.fg })
				set_hl("Function", { fg = colors.secondary, bold = true })

				set_hl("Statement", { fg = colors.primary, bold = true })
				set_hl("Conditional", { fg = colors.primary })
				set_hl("Repeat", { fg = colors.primary })
				set_hl("Keyword", { fg = colors.primary, bold = true })
				set_hl("Operator", { fg = colors.accent })
				set_hl("Exception", { fg = colors.danger })

				set_hl("Type", { fg = colors.warning, italic = true })
				set_hl("StorageClass", { fg = colors.danger })
				set_hl("Structure", { fg = colors.secondary })
				set_hl("Typedef", { fg = colors.secondary })

				set_hl("PreProc", { fg = colors.secondary })
				set_hl("Include", { fg = colors.primary })
				set_hl("Define", { fg = colors.primary })
				set_hl("Macro", { fg = colors.warning })

				set_hl("Special", { fg = colors.accent })
				set_hl("Delimiter", { fg = colors.fg })

				set_hl("DiagnosticError", { fg = colors.danger })
				set_hl("DiagnosticWarn", { fg = colors.warning })
				set_hl("DiagnosticInfo", { fg = colors.info })
				set_hl("DiagnosticHint", { fg = colors.muted })

				set_hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.danger })
				set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.warning })
				set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.info })

				set_hl("@comment", { link = "Comment" })
				set_hl("@string", { link = "String" })
				set_hl("@number", { link = "Number" })
				set_hl("@boolean", { link = "Boolean" })
				set_hl("@constant", { link = "Constant" })

				set_hl("@function", { link = "Function" })
				set_hl("@function.builtin", { fg = colors.accent, bold = true })

				set_hl("@keyword", { link = "Keyword" })
				set_hl("@keyword.function", { link = "Keyword" })
				set_hl("@keyword.operator", { link = "Operator" })

				set_hl("@type", { link = "Type" })
				set_hl("@type.builtin", { fg = colors.warning, bold = true })

				set_hl("@variable", { fg = colors.fg })
				set_hl("@variable.builtin", { fg = colors.danger, italic = true })

				set_hl("@parameter", { fg = colors.warning, italic = true })
				set_hl("@property", { fg = colors.info })
				set_hl("@field", { fg = colors.info })

				set_hl("@punctuation.delimiter", { link = "Delimiter" })
				set_hl("@punctuation.bracket", { link = "Delimiter" })

				set_hl("SpellBad", { undercurl = true, sp = colors.danger })
				set_hl("SpellCap", { undercurl = true, sp = colors.warning })

				vim.g.colors_name = "pastel-hacker"
			end,
		},
	},
}

return M
