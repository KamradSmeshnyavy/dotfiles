-- Efterklang/dotfiles: tui_cli/yazi/init.lua — yatline-catppuccin, mocha
return {
	setup = function()
		return require("yatline-catppuccin"):setup("mocha")
	end,
}
